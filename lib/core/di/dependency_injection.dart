import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/tenant/data/repositories/tenant_repository_impl.dart';
import '../../features/tenant/domain/repositories/tenant_repository.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../services/subscription_service.dart';
import '../services/tenant_service.dart';

class DependencyInjection {
  static void init() {
    // External
    Get.put<FirebaseAuth>(FirebaseAuth.instance);
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance);
    Get.put<FirebaseFunctions>(FirebaseFunctions.instance);

    // Core Services
    Get.put<TenantService>(TenantService());
    Get.put<SubscriptionService>(SubscriptionService(Get.find()));

    // Repositories
    Get.put<AuthRepository>(AuthRepositoryImpl(Get.find(), Get.find()));
    Get.put<TenantRepository>(TenantRepositoryImpl(Get.find(), Get.find()));
    Get.put<ProjectRepository>(ProjectRepositoryImpl(Get.find()));

    // Controllers
    Get.put<AuthController>(AuthController(Get.find(), Get.find()));
  }
}
