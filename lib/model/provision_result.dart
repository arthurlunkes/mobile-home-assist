class ProvisionResult {
  final bool success;
  final String? message;
  final String? macAddress;

  ProvisionResult({
    required this.success,
    this.message,
    this.macAddress,
  });
}
