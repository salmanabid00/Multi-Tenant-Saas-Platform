import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../../../../core/services/tenant_service.dart';
import '../../domain/entities/tenant_entity.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:cloud_functions/cloud_functions.dart';

class TenantController extends GetxController {
  final TenantRepository _tenantRepository;
  final TenantService _tenantService;
  final AuthController _authController;

  TenantController(
      this._tenantRepository, this._tenantService, this._authController);

  final RxList<TenantEntity> myTenants = <TenantEntity>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch tenants when user is logged in
    ever(_authController.currentUser, (user) {
      if (user != null) {
        fetchMyTenants();
      }
    });
  }

  Future<void> fetchMyTenants() async {
    final user = _authController.currentUser.value;
    if (user == null) return;

    isLoading.value = true;
    final result = await _tenantRepository.getMyTenants(user.id);
    isLoading.value = false;

    result.fold(
      (failure) => toastification.show(
        title: const Text('Error'),
        description: Text(failure.message),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.topCenter,
      ),
      (tenants) => myTenants.assignAll(tenants),
    );
  }

  Future<void> createTenant(String name, String plan) async {
    isLoading.value = true;
    final result = await _tenantRepository.createTenant(name, plan);
    isLoading.value = false;

    result.fold(
      (failure) => toastification.show(
        title: const Text('Error'),
        description: Text(failure.message),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.topCenter,
      ),
      (tenantId) async {
        toastification.show(
          title: const Text('Success'),
          description: const Text('Organization created successfully!'),
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 4),
          alignment: Alignment.topCenter,
        );
        await fetchMyTenants();
      },
    );
  }

  Future<void> selectTenant(TenantEntity tenant) async {
    isLoading.value = true;
    try {
      // Try Cloud Function first
      final callable = FirebaseFunctions.instance.httpsCallable('switchTenant');
      final result = await callable.call(<String, dynamic>{
        'tenantId': tenant.id,
      });

      final role = result.data['role'] as String;
      _tenantService.switchTenant(tenant, role);
      
      Get.offAllNamed('/dashboard');

    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'not-found' || e.code == 'unavailable') {
          // FALLBACK: Use local lookup if Cloud Function is missing
          // In real production, we might force the error, but for development
          // with undeployed functions, we fallback to Firestore read.
          try {
             final uid = FirebaseAuth.instance.currentUser?.uid;
             if (uid == null) throw Exception('User not logged in');
             
             final membershipDoc = await FirebaseFirestore.instance
                 .collection('tenant_users')
                 .doc('${tenant.id}_$uid')
                 .get();
                 
             if (membershipDoc.exists) {
                 final role = membershipDoc.data()?['role'] ?? 'viewer';
                 _tenantService.switchTenant(tenant, role);
                 Get.offAllNamed('/dashboard');
                 return;
             }
          } catch (innerError) {
             toastification.show(
                title: const Text('Error'),
                description: Text('Failed to switch tenant (Fallback): $innerError'),
                type: ToastificationType.error,
                style: ToastificationStyle.flat,
                autoCloseDuration: const Duration(seconds: 4),
                alignment: Alignment.topCenter,
             );
          }
      } else {
        toastification.show(
          title: const Text('Error'),
          description: Text('Failed to switch tenant: ${e.message}'),
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 4),
          alignment: Alignment.topCenter,
        );
      }
    } catch (e) {
      toastification.show(
        title: const Text('Error'),
        description: Text('Failed to switch tenant: $e'),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.topCenter,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
