import 'package:get/get.dart';
import '../../features/tenant/domain/entities/tenant_entity.dart';

class TenantService extends GetxService {
  final Rxn<TenantEntity> _currentTenant = Rxn<TenantEntity>();
  final RxnString _currentRole = RxnString();

  TenantEntity? get tenant => _currentTenant.value;
  String? get tenantId => _currentTenant.value?.id;
  String? get role => _currentRole.value;

  bool get isAdmin => _currentRole.value == 'admin';
  bool get isMember => _currentRole.value == 'member' || isAdmin;

  void switchTenant(TenantEntity tenant, String role) {
    _currentTenant.value = tenant;
    _currentRole.value = role;
    // Persist to shared preferences if needed
  }

  void clearTenant() {
    _currentTenant.value = null;
    _currentRole.value = null;
  }
}
