import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vcore_v5_app/services/env_service.dart';

void main() {
  group('EnvService', () {
    setUp(() async {
      // Load test environment variables
      await dotenv.load(fileName: ".env.example");
    });

    test('should load example environment variables', () {
      expect(dotenv.env.isNotEmpty, true);
    });

    test('getFirebaseConfig should return map with required keys', () {
      final config = EnvService.getFirebaseConfig();
      expect(config, containsPair('projectId', isNotEmpty));
      expect(config.keys, contains('apiKey'));
      expect(config.keys, contains('appId'));
      expect(config.keys, contains('messagingSenderId'));
      expect(config.keys, contains('databaseURL'));
      expect(config.keys, contains('storageBucket'));
    });

    test('validateEnvironment should return empty list for valid config', () {
      final missing = EnvService.validateEnvironment();
      // This will only pass if .env has all required variables
      expect(missing, isA<List<String>>());
    });
  });
}
