import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._auth, this._firestore);

  @override
  Future<Either<Failure, AppUser>> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) return Left(ServerFailure('User is null'));
      return Right(AppUser(id: user.uid, email: user.email!, displayName: user.displayName));
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> registerWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) return Left(ServerFailure('User is null'));
      
      // We rely on the Cloud Function `onUserCreated` to create the Firestore document, 
      // but we can return the AppUser immediately.
      return Right(AppUser(id: user.uid, email: user.email!, displayName: user.displayName));
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Registration failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    // Implementation omitted for brevity, usually involves GoogleSignIn package
    return Left(ServerFailure('Google Sign In not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser(id: user.uid, email: user.email!, displayName: user.displayName);
    });
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser(id: user.uid, email: user.email!, displayName: user.displayName);
  }
}
