import 'dart:math';
import '../models/app_state.dart';

/// Lightweight demo data helper used by the app UI and tests.
class DemoData {
  /// Short sample code used only for display in the UI (kept intentionally simple).
  static const String sampleEncryptionCode =
      'void encryptDemo() { /* sample encryption code omitted for brevity */ }';

  static const String sampleAttackCode =
      'void attackDemo() { /* sample attack code omitted for brevity */ }';

  /// Generate sample benchmark results for testing
  static List<BenchmarkResult> generateSampleResults() {
    final results = <BenchmarkResult>[];
    final algorithms = ['AES', 'RSA', 'Hybrid AES + ECC', 'Homomorphic'];
    final attacks = ['MITM', 'Brute Force', 'Replay', 'DoS'];
    final random = Random();

    for (int i = 0; i < 8; i++) {
      final algorithm = algorithms[random.nextInt(algorithms.length)];
      final attack = attacks[random.nextInt(attacks.length)];

      // Generate realistic performance data based on algorithm
      double encTime, decTime, attackSuccess;

      switch (algorithm) {
        case 'AES':
          encTime = 50 + random.nextDouble() * 100;
          decTime = 40 + random.nextDouble() * 80;
          attackSuccess = random.nextDouble() * 20;
          break;
        case 'RSA':
          encTime = 200 + random.nextDouble() * 500;
          decTime = 150 + random.nextDouble() * 300;
          attackSuccess = random.nextDouble() * 15;
          break;
        case 'Hybrid AES + ECC':
          encTime = 100 + random.nextDouble() * 200;
          decTime = 80 + random.nextDouble() * 150;
          attackSuccess = random.nextDouble() * 10;
          break;
        case 'Homomorphic':
          encTime = 800 + random.nextDouble() * 1200;
          decTime = 600 + random.nextDouble() * 800;
          attackSuccess = random.nextDouble() * 25;
          break;
        default:
          encTime = 100;
          decTime = 90;
          attackSuccess = 20;
      }

      results.add(BenchmarkResult(
        encryptionAlgorithm: algorithm,
        attackType: attack,
        encryptionTime: encTime,
        decryptionTime: decTime,
        transmissionSpeed: 1000 + random.nextDouble() * 500,
        dataLossRate: random.nextDouble() * 5,
        attackSuccessRate: attackSuccess,
        securityScore: 100 - attackSuccess - (encTime > 500 ? 10 : 0),
        timestamp: DateTime.now().subtract(Duration(minutes: i * 5)),
      ));
    }

    return results;
  }

  /// Test cases for the cybersecurity lab
  static final List<String> testMessages = [
    'Hello, World!',
    'This is a secret message for encryption testing.',
    'The quick brown fox jumps over the lazy dog. 1234567890',
    '''Multi-line message
with various characters:
!@#\$%^&*()_+-=[]{}|;':",./<>?
Special chars: àáâãäåæçèéêë''',
    'Short',
    // Long message: repeat 'A' 1000 times
    String.fromCharCodes(List.generate(1000, (i) => 65)),
    '{"json": "data", "number": 12345, "boolean": true}',
    'Base64 test: SGVsbG8gV29ybGQ=',
  ];
}