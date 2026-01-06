import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/tenant_service.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectController extends GetxController {
  final ProjectRepository _projectRepository;
  final TenantService _tenantService;

  ProjectController(this._projectRepository, this._tenantService);

  final RxList<ProjectEntity> projects = <ProjectEntity>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    final tenantId = _tenantService.tenantId;
    if (tenantId == null) return;

    isLoading.value = true;
    final result = await _projectRepository.getProjects(tenantId);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (data) => projects.assignAll(data),
    );
  }

  Future<void> createProject(String name) async {
    final tenantId = _tenantService.tenantId;
    if (tenantId == null) return;

    // Check permission logic here or in UI
    if (!_tenantService.isMember) {
        Get.snackbar('Error', 'You do not have permission to create projects');
        return;
    }

    isLoading.value = true;
    final result = await _projectRepository.createProject(name, tenantId);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (id) {
        Get.snackbar('Success', 'Project created');
        fetchProjects();
      },
    );
  }
}
