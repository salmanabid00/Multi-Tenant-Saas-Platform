import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/tenant_entity.dart';

abstract class TenantRepository {
  Future<Either<Failure, String>> createTenant(String name, String plan);
  Future<Either<Failure, List<TenantEntity>>> getMyTenants(String userId);
}
