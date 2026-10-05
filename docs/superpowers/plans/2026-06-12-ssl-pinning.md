# SSL Pinning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire certificate-based SSL pinning for `api.themoviedb.org` API traffic via a factory abstraction, satisfying Dicoding submission requirements with a migration path to SPKI pinning.

**Architecture:** A thin `PinningConfig` abstraction feeds into `HttpClientFactory`, which delegates to refactored `SslPinning.createClient()`. The pinned `IOClient` is registered in GetIt during async `init()`, consumed transparently by `MovieRemoteDataSourceImpl`. `HandshakeException` from failed pin validation maps to `ConnectionFailure` in the repository layer.

**Tech Stack:** Flutter/Dart 3.5+, `http` package (`IOClient`), `get_it` DI, `mockito`/`flutter_test`

**Spec:** `docs/superpowers/specs/2026-06-12-ssl-pinning-design.md`

---

## File Map

| File | Responsibility |
|------|----------------|
| `lib/common/pinning_config.dart` | Pinning strategy config types |
| `lib/common/sslpinning.dart` | Creates pinned `IOClient` from asset cert |
| `lib/common/http_client_factory.dart` | Selects pinning strategy, returns `http.Client` |
| `lib/injection.dart` | Async DI bootstrap with pinned client |
| `lib/main.dart` | Async app entry with binding init |
| `lib/data/repositories/movie_repository_impl.dart` | `HandshakeException` → `ConnectionFailure` |
| `certificates/certificates.crt` | Pinned leaf cert for `api.themoviedb.org` |
| `test/common/sslpinning_test.dart` | Pinning client creation tests |
| `test/common/http_client_factory_test.dart` | Factory dispatch tests |
| `test/data/repositories/movie_repository_impl_test.dart` | HandshakeException handler test |

---

### Task 1: PinningConfig abstraction

**Files:**
- Create: `lib/common/pinning_config.dart`

- [ ] **Step 1: Create pinning config file**

```dart
abstract class PinningConfig {}

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
```

- [ ] **Step 2: Verify file compiles**

Run: `dart analyze lib/common/pinning_config.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/common/pinning_config.dart
git commit -m "feat: add PinningConfig abstraction for SSL pinning strategies"
```

---

### Task 2: Refactor SslPinning

**Files:**
- Modify: `lib/common/sslpinning.dart`

- [ ] **Step 1: Write the failing test**

Create `test/common/sslpinning_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/common/sslpinning_test.dart`
Expected: FAIL — `createClient` method not defined on `SslPinning`

- [ ] **Step 3: Refactor SslPinning implementation**

Replace entire contents of `lib/common/sslpinning.dart`:

```dart
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/io_client.dart';

class SslPinning {
  static Future<IOClient> createClient({required String assetPath}) async {
    final sslCert = await rootBundle.load(assetPath);
    final securityContext = SecurityContext(withTrustedRoots: false);
    securityContext.setTrustedCertificatesBytes(sslCert.buffer.asInt8List());

    final httpClient = HttpClient(context: securityContext);
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;

    return IOClient(httpClient);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/common/sslpinning_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/common/sslpinning.dart test/common/sslpinning_test.dart
git commit -m "feat: refactor SslPinning to accept asset path parameter"
```

---

### Task 3: HttpClientFactory

**Files:**
- Create: `lib/common/http_client_factory.dart`
- Create: `test/common/http_client_factory_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/common/http_client_factory_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/common/http_client_factory_test.dart`
Expected: FAIL — `HttpClientFactory` not defined

- [ ] **Step 3: Implement HttpClientFactory**

Create `lib/common/http_client_factory.dart`:

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/common/http_client_factory_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/common/http_client_factory.dart test/common/http_client_factory_test.dart
git commit -m "feat: add HttpClientFactory with certificate pinning support"
```

---

### Task 4: Replace certificate for api.themoviedb.org

**Files:**
- Replace: `certificates/certificates.crt`

- [ ] **Step 1: Extract current certificate from TMDB API**

Run (requires network):

```bash
openssl s_client -connect api.themoviedb.org:443 \
  -servername api.themoviedb.org </dev/null 2>/dev/null \
  | openssl x509 -outform PEM > certificates/certificates.crt
```

- [ ] **Step 2: Verify certificate subject**

Run: `openssl x509 -in certificates/certificates.crt -noout -subject`
Expected: Subject contains `api.themoviedb.org` (NOT `developer.themoviedb.org`)

- [ ] **Step 3: Re-run pinning tests with new cert**

Run: `flutter test test/common/sslpinning_test.dart test/common/http_client_factory_test.dart`
Expected: PASS (4 tests total)

- [ ] **Step 4: Commit**

```bash
git add certificates/certificates.crt
git commit -m "fix: replace certificate with api.themoviedb.org leaf cert"
```

---

### Task 5: Wire pinned client into DI

**Files:**
- Modify: `lib/injection.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Update injection.dart**

Add imports at top:

```dart
import 'package:ditonton/common/http_client_factory.dart';
import 'package:ditonton/common/pinning_config.dart';
```

Change `void init()` to `Future<void> init()` and replace the external registration at the bottom:

```dart
  // external
  final client = await HttpClientFactory.create(
    const CertificatePinningConfig(
      assetPath: 'certificates/certificates.crt',
    ),
  );
  locator.registerLazySingleton<http.Client>(() => client);
```

Remove the old line:
```dart
  locator.registerLazySingleton(() => http.Client());
```

- [ ] **Step 2: Update main.dart**

Replace:

```dart
void main() {
  di.init();
  runApp(MyApp());
}
```

With:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(MyApp());
}
```

- [ ] **Step 3: Verify project compiles**

Run: `flutter analyze lib/injection.dart lib/main.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/injection.dart lib/main.dart
git commit -m "feat: wire SSL pinned client into dependency injection"
```

---

### Task 6: HandshakeException error handling

**Files:**
- Modify: `lib/data/repositories/movie_repository_impl.dart`
- Modify: `test/data/repositories/movie_repository_impl_test.dart`

- [ ] **Step 1: Write the failing test**

Add this test inside the `getNowPlayingMovies` group in `test/data/repositories/movie_repository_impl_test.dart`, after the existing SocketException test:

```dart
    test(
        'should return ConnectionFailure when HandshakeException is thrown',
        () async {
      // arrange
      when(mockRemoteDataSource.getNowPlayingMovies())
          .thenThrow(const HandshakeException('CERTIFICATE_VERIFY_FAILED'));
      // act
      final result = await repository.getNowPlayingMovies();
      // assert
      verify(mockRemoteDataSource.getNowPlayingMovies());
      expect(
          result,
          equals(Left(ConnectionFailure(
              'Failed to verify server certificate'))));
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/repositories/movie_repository_impl_test.dart --name "HandshakeException"`
Expected: FAIL — exception not caught, test throws `HandshakeException`

- [ ] **Step 3: Add HandshakeException handler to all remote methods**

In `lib/data/repositories/movie_repository_impl.dart`, add this catch block **before** every existing `on SocketException` in these 12 methods:

- `getNowPlayingMovies`
- `getMovieDetail`
- `getMovieRecommendations`
- `getPopularMovies`
- `getTopRatedMovies`
- `searchMovies`
- `getNowPlayingTv`
- `getPopularTv`
- `getTopRatedTv`
- `getTvDetails`
- `searchTv`
- `getTvRecommendations`

Handler to insert:

```dart
    } on HandshakeException {
      return Left(ConnectionFailure('Failed to verify server certificate'));
```

Resulting pattern per method:

```dart
    } on ServerException {
      return Left(ServerFailure(''));
    } on HandshakeException {
      return Left(ConnectionFailure('Failed to verify server certificate'));
    } on SocketException {
      return Left(ConnectionFailure('Failed to connect to the network'));
    }
```

Note: `HandshakeException` is already available via `import 'dart:io';` at the top of the file.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/repositories/movie_repository_impl_test.dart --name "HandshakeException"`
Expected: PASS

- [ ] **Step 5: Run full test suite**

Run: `flutter test`
Expected: All tests PASS

- [ ] **Step 6: Commit**

```bash
git add lib/data/repositories/movie_repository_impl.dart test/data/repositories/movie_repository_impl_test.dart
git commit -m "feat: handle HandshakeException from SSL pinning failures"
```

---

### Task 7: End-to-end verification

**Files:** None (verification only)

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: All tests PASS with no failures

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 3: Manual smoke test**

Run: `flutter run` (on simulator or device with network)

Verify:
- Home page loads now playing movies
- Popular movies page loads data
- TV section loads data
- No SSL/certificate errors in console

- [ ] **Step 4: Verify pinning is active (optional negative test)**

Temporarily corrupt `certificates/certificates.crt` (e.g. delete last line), hot restart app.
Expected: API calls fail with connection/certificate error in UI.
Restore the correct certificate afterward.

---

## Self-Review Checklist

| Spec Requirement | Task |
|-----------------|------|
| PinningConfig abstraction | Task 1 |
| SslPinning refactor | Task 2 |
| HttpClientFactory | Task 3 |
| Correct api.themoviedb.org cert | Task 4 |
| Async init in injection + main | Task 5 |
| HandshakeException handling | Task 6 |
| Unit tests for pinning + factory | Tasks 2, 3 |
| Existing tests unchanged | Task 6 Step 5 verifies |
| Manual E2E verification | Task 7 |
| SPKI placeholder (UnimplementedError) | Task 3 |
| Image CDN out of scope | Not in any task (correct) |
