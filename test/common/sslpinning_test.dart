import 'package:ditonton/common/sslpinning.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SslPinning', () {
    test('createClient should return IOClient', () async {
      final client = await SslPinning.createClient(
        assetPath: 'certificates/certificates.crt',
      );

      expect(client, isA<IOClient>());
      client.close();
    });

    test('createClient should load certificate from assets without error',
        () async {
      expect(
        () => SslPinning.createClient(
          assetPath: 'certificates/certificates.crt',
        ),
        returnsNormally,
      );
    });
  });
}
