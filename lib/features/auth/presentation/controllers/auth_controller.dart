import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/tenant_service.dart';
import '../../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final TenantService _tenantService;

  AuthController(this._authRepository, this._tenantService);

  final Rxn<AppUser> currentUser = Rxn<AppUser>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(_authRepository.authStateChanges);
    // Removed automatic 'ever' navigation to allow Splash Screen to control startup flow
  }

  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    final result = await _authRepository.signInWithEmailAndPassword(email, password);
    isLoading.value = false;
    
    result.fold(
      (failure) {
        toastification.show(
          title: const Text('Login Failed'),
          description: Text(failure.message),
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 4),
          alignment: Alignment.topCenter,
        );
      },
      (user) {
        toastification.show(
          title: const Text('Welcome Back'),
          description: const Text('Successfully logged in!'),
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );
        Get.offAllNamed(Routes.TENANTS);
      },
    );
  }

  Future<void> register(String email, String password) async {
    isLoading.value = true;
    final result = await _authRepository.registerWithEmailAndPassword(email, password);
    isLoading.value = false;

    result.fold(
      (failure) {
        toastification.show(
          title: const Text('Registration Failed'),
          description: Text(failure.message),
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 4),
          alignment: Alignment.topCenter,
        );
      },
      (user) {
         toastification.show(
          title: const Text('Welcome'),
          description: const Text('Account created successfully!'),
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );
        Get.offAllNamed(Routes.TENANTS);
      },
    );
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _tenantService.clearTenant();
    Get.offAllNamed(Routes.LOGIN);
    
    toastification.show(
      title: const Text('Signed Out'),
      description: const Text('You have been logged out.'),
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
    );
  }
}
