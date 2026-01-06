class TenantEntity {
  final String id;
  final String name;
  final String subscriptionPlan;
  final String ownerId;
  final DateTime createdAt;

  const TenantEntity({
    required this.id,
    required this.name,
    required this.subscriptionPlan,
    required this.ownerId,
    required this.createdAt,
  });

  bool get isFree => subscriptionPlan == 'free';
  bool get isPro => subscriptionPlan == 'pro';
  bool get isEnterprise => subscriptionPlan == 'enterprise';
}
