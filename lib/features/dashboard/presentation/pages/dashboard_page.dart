import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/tenant_service.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';

class DashboardPage extends GetView<AuthController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tenantService = Get.find<TenantService>();
    final subscriptionService = Get.find<SubscriptionService>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(tenantService.tenant?.name ?? 'Dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch Organization',
            onPressed: () => Get.offAllNamed(Routes.TENANTS),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => controller.signOut(),
          ),
        ],
      ),
      body: Obx(() {
        final tenant = tenantService.tenant;
        if (tenant == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to ${tenant.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Plan: ${tenant.subscriptionPlan.toUpperCase()}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.business, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Text('Overview', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              // Info Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildStatCard(
                        context,
                        title: 'Role',
                        value: tenantService.role?.toUpperCase() ?? 'N/A',
                        icon: Icons.badge,
                        color: Colors.purple,
                        width: (constraints.maxWidth - 16) / 2,
                      ),
                      _buildStatCard(
                        context,
                        title: 'Storage',
                        value: '${subscriptionService.maxStorageGB} GB',
                        icon: Icons.storage,
                        color: Colors.orange,
                        width: (constraints.maxWidth - 16) / 2,
                      ),
                    ],
                  );
                }
              ),

              const SizedBox(height: 32),
              Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              // Action Cards
              Card(
                child: InkWell(
                  onTap: () => Get.toNamed(Routes.PROJECTS),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.folder_copy, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage Projects',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'View and create tenant-scoped projects',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Features List
               Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subscription Features',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Divider(height: 24),
                      _buildFeatureRow('Add Members', subscriptionService.canAddMembers),
                      _buildFeatureRow('Export Data', subscriptionService.canExportData),
                      _buildFeatureRow('Audit Logs', subscriptionService.canAccessAuditLogs),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // Data Isolation Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Environment Scoped: ${tenant.id.substring(0, 8)}...',
                          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String label, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEnabled ? Icons.check : Icons.close,
              color: isEnabled ? Colors.green : Colors.red,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isEnabled ? Colors.black87 : Colors.grey,
              decoration: isEnabled ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}
