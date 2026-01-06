# Multi-Tenant SaaS Platform Architecture

## 1. High-Level Architecture

This platform follows a **Multi-Tenant with Logical Isolation** strategy. All tenants share the same infrastructure (Firestore, Cloud Functions, Hosting), but data is strictly isolated via **Tenant IDs** at the application and database level.

### Tech Stack
- **Frontend**: Flutter (Mobile + Web)
- **State Management**: GetX
- **Backend**: Firebase (Auth, Firestore, Functions)
- **Architecture**: Clean Architecture (Presentation, Domain, Data layers)

### Core Components
1.  **Tenant Context**: A global state that determines the "current" active tenant.
2.  **Auth Service**: Handles user login and retrieves the user's accessible tenants.
3.  **RBAC System**: Enforces permissions based on `(TenantID, Role)`.
4.  **Cloud Functions**: Handles privileged operations (e.g., creating tenants, changing roles, billing).

---

## 2. Firestore Data Model (Schema)

The schema is designed for scalability and strict isolation. We avoid sub-collections for high-traffic data to prevent write-hotspots and nesting limits, preferring root-level collections with composite keys or indexed fields.

### Root Collections

#### `tenants` (Collection)
Metadata for each organization.
- `id`: string (UUID)
- `name`: string
- `subscriptionPlan`: 'free' | 'pro' | 'enterprise'
- `createdAt`: timestamp
- `settings`: map (feature flags, branding)

#### `users` (Collection)
Global user profiles (linked to Firebase Auth UID).
- `id`: string (uid)
- `email`: string
- `displayName`: string
- `tenants`: map (cache of `{ tenantId: role }` for quick client-side checks)

#### `tenant_users` (Collection)
The junction table linking Users to Tenants with roles.
- `id`: string (composite `tenantId_uid` or auto-id)
- `tenantId`: string (Partition Key)
- `uid`: string
- `role`: 'admin' | 'member' | 'viewer'
- `joinedAt`: timestamp

#### `domain_data` (Collection - Example)
Actual business data (e.g., "Tickets", "Projects").
**CRITICAL**: Every document MUST have a `tenantId` field.
- `id`: string
- `tenantId`: string (Indexed)
- `title`: string
- `status`: string
- `assignedTo`: string

#### `subscriptions` (Collection)
Stripe/Billing info, strictly accessible only by Cloud Functions or Admin SDK.
- `id`: string (tenantId)
- `stripeCustomerId`: string
- `status`: 'active' | 'past_due'
- `currentPeriodEnd`: timestamp

---

## 3. Tenant Isolation Strategy

Isolation is enforced at three levels:

1.  **UI Level**: The app requires a `currentTenant` to be selected. All repositories inject this `tenantId` into queries automatically.
2.  **Security Rules (Firestore)**: Rules check `request.auth.token.tenantId` (if using custom claims) or look up the `tenant_users` collection to verify access.
3.  **Backend (Cloud Functions)**: All sensitive writes verify the user's role within the specific tenant before executing.

### Zero-Trust Policy
We do **not** trust the client to send the correct `tenantId` for writes. Security rules must validate that the `resource.data.tenantId` matches the claimed scope.

---

## 4. RBAC Implementation (Role-Based Access Control)

Roles are scoped to tenants. A user can be an `admin` in Tenant A and a `viewer` in Tenant B.

### Roles
- **Owner/Admin**: Full access, billing, user management.
- **Member**: Read/Write domain data, cannot manage users/billing.
- **Viewer**: Read-only access.

### Custom Claims approach (Recommended)
To reduce Firestore reads, we sync the active tenant permissions to the user's ID token via Cloud Functions when they switch contexts or login.

`auth.token.customClaims`:
```json
{
  "activeTenantId": "tenant_123",
  "role": "admin"
}
```

*Note: Due to token size limits (1000 bytes), we only store the **current active** tenant info in the claim, or check Firestore directly in Security Rules if the user belongs to many tenants.*

---

## 5. Subscription & Feature Gating

Features are gated via a `SubscriptionService`.

- **Logic**: Check `tenant.subscriptionPlan` against a feature map.
- **Enforcement**:
  - **Client**: Hide UI elements (e.g., "Export to CSV").
  - **Server**: Cloud Functions reject actions if limits are exceeded (e.g., "Max 5 users on Free tier").

---
