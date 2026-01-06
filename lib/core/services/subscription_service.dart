import 'package:get/get.dart';
import '../services/tenant_service.dart';

class SubscriptionService extends GetxService {
  final TenantService _tenantService;

  SubscriptionService(this._tenantService);

  bool get canAddMembers {
    final plan = _tenantService.tenant?.subscriptionPlan;
    if (plan == 'enterprise') return true;
    if (plan == 'pro') {
      // Logic to check current count vs limit would go here.
      // For now, returning true as simplified check.
      return true;
    }
    // Free plan limit
    return false; 
  }

  bool get canExportData {
    return _tenantService.tenant?.isPro == true || _tenantService.tenant?.isEnterprise == true;
  }

  bool get canAccessAuditLogs {
    return _tenantService.tenant?.isEnterprise == true;
  }
  
  int get maxStorageGB {
    switch (_tenantService.tenant?.subscriptionPlan) {
      case 'enterprise': return 1000;
      case 'pro': return 100;
      default: return 5;
    }
  }
}
