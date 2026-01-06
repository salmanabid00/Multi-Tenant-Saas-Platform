import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.status,
    required super.tenantId,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      status: data['status'] ?? 'active',
      tenantId: data['tenantId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'tenantId': tenantId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
