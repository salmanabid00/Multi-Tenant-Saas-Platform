import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/project_entity.dart';

abstract class ProjectRepository {
  Future<Either<Failure, String>> createProject(String name, String tenantId);
  Future<Either<Failure, List<ProjectEntity>>> getProjects(String tenantId);
}
