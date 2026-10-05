import 'package:ditonton/common/http_client_factory.dart';
import 'package:ditonton/common/pinning_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HttpClientFactory', () {
    test('create with CertificatePinningConfig should return IOClient',
        () async {
      final client = await HttpClientFactory.create(
        const CertificatePinningConfig(
          assetPath: 'certificates/certificates.crt',
        ),
      );

      expect(client, isA<IOClient>());
      client.close();
    });

    test('create with SpkiPinningConfig should throw UnimplementedError',
        () async {
      expect(
        () => HttpClientFactory.create(
          const SpkiPinningConfig(
            host: 'api.themoviedb.org',
            allowedSpkiHashes: ['dummy-hash'],
          ),
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
