import 'package:ditonton/common/pinning_config.dart';
import 'package:ditonton/common/sslpinning.dart';
import 'package:http/http.dart' as http;

class HttpClientFactory {
  static Future<http.Client> create(PinningConfig config) async {
    switch (config) {
      case CertificatePinningConfig(:final assetPath):
        return SslPinning.createClient(assetPath: assetPath);
      case SpkiPinningConfig():
        throw UnimplementedError('SPKI pinning not yet implemented');
    }
  }
}
