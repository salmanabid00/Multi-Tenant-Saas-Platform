import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/tenant_entity.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../models/tenant_model.dart';
import 'package:uuid/uuid.dart';

class TenantRepositoryImpl implements TenantRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  TenantRepositoryImpl(this._firestore, this._functions);

  @override
  Future<Either<Failure, String>> createTenant(String name, String plan) async {
    // FALLBACK APPROACH: Direct Firestore write if Cloud Functions are not deployed or failing.
    // In a strict production environment, we would ONLY use Cloud Functions.
    // However, for this MVP/Demo to work immediately without deploying functions:
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return const Left(ServerFailure('User not authenticated'));

      // 1. Generate IDs
      final tenantId = const Uuid().v4();
      final membershipId = '${tenantId}_${user.uid}';

      final batch = _firestore.batch();

      // 2. Create Tenant Doc
      final tenantRef = _firestore.collection('tenants').doc(tenantId);
      batch.set(tenantRef, {
        'name': name,
        'subscriptionPlan': plan,
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'settings': {
            'maxUsers': plan == 'enterprise' ? 9999 : (plan == 'pro' ? 50 : 5)
        }
      });

      // 3. Add User as Admin in tenant_users
      final memberRef = _firestore.collection('tenant_users').doc(membershipId);
      batch.set(memberRef, {
        'tenantId': tenantId,
        'uid': user.uid,
        'role': 'admin',
        'joinedAt': FieldValue.serverTimestamp()
      });

      await batch.commit();

      return Right(tenantId);

    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TenantEntity>>> getMyTenants(String userId) async {
    try {
      // 1. Query tenant_users to find where the user is a member
      final membershipQuery = await _firestore
          .collection('tenant_users')
          .where('uid', isEqualTo: userId)
          .get();

      if (membershipQuery.docs.isEmpty) {
        return const Right([]);
      }

      final tenantIds = membershipQuery.docs
          .map((doc) => doc.data()['tenantId'] as String)
          .toList();

      if (tenantIds.isEmpty) return const Right([]);

      // 2. Fetch the actual tenant documents
      if (tenantIds.length > 10) {
          return const Left(ServerFailure('User belongs to too many tenants for this simple query.')); 
      }

      final tenantsQuery = await _firestore
          .collection('tenants')
          .where(FieldPath.documentId, whereIn: tenantIds)
          .get();

      final tenants = tenantsQuery.docs
          .map((doc) => TenantModel.fromFirestore(doc))
          .toList();

      return Right(tenants);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
