import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tenant_entity.dart';

class TenantModel extends TenantEntity {
  const TenantModel({
    required super.id,
    required super.name,
    required super.subscriptionPlan,
    required super.ownerId,
    required super.createdAt,
  });

  factory TenantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TenantModel(
      id: doc.id,
      name: data['name'] ?? '',
      subscriptionPlan: data['subscriptionPlan'] ?? 'free',
      ownerId: data['ownerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subscriptionPlan': subscriptionPlan,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
