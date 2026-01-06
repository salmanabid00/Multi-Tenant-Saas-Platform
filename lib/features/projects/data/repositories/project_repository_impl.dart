import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final FirebaseFirestore _firestore;

  ProjectRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, String>> createProject(String name, String tenantId) async {
    try {
      final docRef = _firestore.collection('projects').doc();
      final model = ProjectModel(
        id: docRef.id,
        name: name,
        status: 'active',
        tenantId: tenantId,
      );
      
      await docRef.set(model.toMap());
      return Right(docRef.id);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects(String tenantId) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('tenantId', isEqualTo: tenantId)
          .get();

      final projects = querySnapshot.docs
          .map((doc) => ProjectModel.fromFirestore(doc))
          .toList();

      return Right(projects);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
