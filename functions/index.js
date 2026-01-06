const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

// ==========================================================
// 1. TENANT MANAGEMENT
// ==========================================================

/**
 * Creates a new tenant organization.
 * - Creates 'tenants' document
 * - Creates 'tenant_users' entry for the owner (admin)
 * - Updates user's custom claims to immediately log them in
 */
exports.createTenant = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');

  const { name, plan = 'free' } = data;
  const uid = context.auth.uid;
  const tenantId = db.collection('tenants').doc().id;

  const batch = db.batch();

  // 1. Create Tenant Doc
  const tenantRef = db.collection('tenants').doc(tenantId);
  batch.set(tenantRef, {
    name,
    subscriptionPlan: plan,
    ownerId: uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    settings: {
        maxUsers: plan === 'enterprise' ? 9999 : (plan === 'pro' ? 50 : 5)
    }
  });

  // 2. Add User as Admin
  const membershipId = `${tenantId}_${uid}`;
  const memberRef = db.collection('tenant_users').doc(membershipId);
  batch.set(memberRef, {
    tenantId,
    uid,
    role: 'admin',
    joinedAt: admin.firestore.FieldValue.serverTimestamp()
  });

  await batch.commit();

  // 3. Set Custom Claims immediately so they can access it
  await admin.auth().setCustomUserClaims(uid, {
    activeTenantId: tenantId,
    role: 'admin'
  });

  return { tenantId };
});

// ==========================================================
// 2. CONTEXT SWITCHING (CRITICAL)
// ==========================================================

/**
 * Switches the active tenant context for the user.
 * Verifies membership in Firestore before issuing the claim.
 */
exports.switchTenant = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');

  const { tenantId } = data;
  const uid = context.auth.uid;

  // 1. Verify membership
  const membershipId = `${tenantId}_${uid}`;
  const membershipDoc = await db.collection('tenant_users').doc(membershipId).get();

  if (!membershipDoc.exists) {
    throw new functions.https.HttpsError('permission-denied', 'User is not a member of this tenant.');
  }

  const role = membershipDoc.data().role;

  // 2. Update Custom Claims
  // This allows Firestore Security Rules to use `request.auth.token.activeTenantId`
  await admin.auth().setCustomUserClaims(uid, {
    activeTenantId: tenantId,
    role: role
  });

  return { success: true, tenantId, role };
});


// ==========================================================
// 3. USER MANAGEMENT
// ==========================================================

/**
 * Syncs new Auth users to the 'users' collection for profile data.
 */
exports.onUserCreated = functions.auth.user().onCreate((user) => {
  return db.collection('users').doc(user.uid).set({
    email: user.email,
    displayName: user.displayName || '',
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
});

/**
 * Invites a user to a tenant (Admin only).
 * - Creates a 'tenant_users' entry
 * - Could send an email (SendGrid/Postmark) - omitted for brevity
 */
exports.inviteUser = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
    
    // Check if caller is admin of the tenant
    const callerTenantId = context.auth.token.activeTenantId;
    const callerRole = context.auth.token.role;
    
    if (callerRole !== 'admin') {
         throw new functions.https.HttpsError('permission-denied', 'Only admins can invite users.');
    }

    const { email, role } = data;
    // Look up user by email
    let userRecord;
    try {
        userRecord = await admin.auth().getUserByEmail(email);
    } catch (e) {
        // Handle case where user doesn't exist (would need to create invitation doc instead)
        throw new functions.https.HttpsError('not-found', 'User not found. Implement invitation flow for non-users.');
    }

    const membershipId = `${callerTenantId}_${userRecord.uid}`;
    await db.collection('tenant_users').doc(membershipId).set({
        tenantId: callerTenantId,
        uid: userRecord.uid,
        role: role,
        joinedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { success: true };
});
