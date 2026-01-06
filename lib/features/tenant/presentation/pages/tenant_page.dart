import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tenant_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class TenantPage extends GetView<TenantController> {
  final TextEditingController _nameController = TextEditingController();

  TenantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Organization'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().signOut(),
          ),
        ],
      ),
      // resizeToAvoidBottomInset: false prevents the whole scaffold from shrinking
      // We will handle the keyboard manually with padding/scrolling
      resizeToAvoidBottomInset: false,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.business, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Organizations',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Select an organization to continue',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.myTenants.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No organizations found',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text('Create your first organization below'),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.myTenants.length,
                      itemBuilder: (context, index) {
                        final tenant = controller.myTenants[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => controller.selectTenant(tenant),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        tenant.name.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.primaries[index % Colors.primaries.length],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tenant.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                tenant.subscriptionPlan.toUpperCase(),
                                                style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // We use padding at the bottom based on keyboard visibility
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Important: minimizes height
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Create New Organization', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Organization Name',
                        hintText: 'e.g. Acme Corp',
                        prefixIcon: Icon(Icons.domain_add),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.isNotEmpty) {
                          controller.createTenant(_nameController.text, 'free');
                          _nameController.clear();
                          // Dismiss keyboard
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: const Text('Create Free Organization'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
