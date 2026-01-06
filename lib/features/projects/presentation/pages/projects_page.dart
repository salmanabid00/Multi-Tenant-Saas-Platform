import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_controller.dart';
import '../../../../core/services/tenant_service.dart';

class ProjectsPage extends GetView<ProjectController> {
  final TextEditingController _nameController = TextEditingController();

  ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.folder_off_outlined, size: 64, color: Colors.blue),
                ),
                const SizedBox(height: 24),
                Text(
                  'No projects yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a project to get started',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                if (Get.find<TenantService>().isMember)
                   ElevatedButton.icon(
                    onPressed: () => _showCreateProjectDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Project'),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.projects.length,
          itemBuilder: (context, index) {
            final project = controller.projects[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_outlined, color: Colors.blue),
                ),
                title: Text(
                  project.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          project.status.toUpperCase(),
                          style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ID: ${project.id.substring(0, 6)}...',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            );
          },
        );
      }),
      floatingActionButton: Get.find<TenantService>().isMember
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateProjectDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New Project'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a name for your new project.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'e.g. Q4 Marketing Campaign',
                prefixIcon: Icon(Icons.drive_file_rename_outline),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                controller.createProject(_nameController.text);
                Get.back();
                _nameController.clear();
              }
            },
            child: const Text('Create Project'),
          ),
        ],
      ),
    );
  }
}
