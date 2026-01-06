import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, AppUser>> registerWithEmailAndPassword(String email, String password);
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Stream<AppUser?> get authStateChanges;
  Future<AppUser?> getCurrentUser();
}
