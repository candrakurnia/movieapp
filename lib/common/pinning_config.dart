sealed class PinningConfig {}

class CertificatePinningConfig implements PinningConfig {
  final String assetPath;
  const CertificatePinningConfig({required this.assetPath});
}

class SpkiPinningConfig implements PinningConfig {
  final String host;
  final List<String> allowedSpkiHashes;
  const SpkiPinningConfig({
    required this.host,
    required this.allowedSpkiHashes,
  });
}
