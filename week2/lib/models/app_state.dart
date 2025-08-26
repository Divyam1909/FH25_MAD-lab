import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  int _currentIndex = 0;
  String? _uploadedEncryptionCode;
  String? _uploadedAttackCode;
  String _selectedEncryption = 'AES';
  String _selectedAttack = 'MITM';
  bool _isRunningTest = false;
  List<BenchmarkResult> _benchmarkResults = [];
  List<String> _logs = [];

  // Getters
  int get currentIndex => _currentIndex;
  String? get uploadedEncryptionCode => _uploadedEncryptionCode;
  String? get uploadedAttackCode => _uploadedAttackCode;
  String get selectedEncryption => _selectedEncryption;
  String get selectedAttack => _selectedAttack;
  bool get isRunningTest => _isRunningTest;
  List<BenchmarkResult> get benchmarkResults => _benchmarkResults;
  List<String> get logs => _logs;

  // Available options
  final List<String> encryptionOptions = [
    'AES',
    'Hybrid AES + ECC',
    'Homomorphic',
    'ABE',
    'RSA',
    'Custom'
  ];

  final List<String> attackOptions = [
    'MITM',
    'Replay',
    'Brute Force',
    'DoS',
    'Ciphertext Manipulation',
    'Custom'
  ];

  // Setters
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setUploadedEncryptionCode(String code) {
    _uploadedEncryptionCode = code;
    notifyListeners();
  }

  void setUploadedAttackCode(String code) {
    _uploadedAttackCode = code;
    notifyListeners();
  }

  void setSelectedEncryption(String encryption) {
    _selectedEncryption = encryption;
    notifyListeners();
  }

  void setSelectedAttack(String attack) {
    _selectedAttack = attack;
    notifyListeners();
  }

  void setRunningTest(bool isRunning) {
    _isRunningTest = isRunning;
    notifyListeners();
  }

  void addBenchmarkResult(BenchmarkResult result) {
    _benchmarkResults.add(result);
    notifyListeners();
  }

  void clearBenchmarkResults() {
    _benchmarkResults.clear();
    notifyListeners();
  }

  void addLog(String log) {
    _logs.add('[${DateTime.now().toIso8601String()}] $log');
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}

class BenchmarkResult {
  final String encryptionAlgorithm;
  final String attackType;
  final double encryptionTime;
  final double decryptionTime;
  final double transmissionSpeed;
  final double dataLossRate;
  final double attackSuccessRate;
  final double securityScore;
  final DateTime timestamp;

  BenchmarkResult({
    required this.encryptionAlgorithm,
    required this.attackType,
    required this.encryptionTime,
    required this.decryptionTime,
    required this.transmissionSpeed,
    required this.dataLossRate,
    required this.attackSuccessRate,
    required this.securityScore,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'encryptionAlgorithm': encryptionAlgorithm,
      'attackType': attackType,
      'encryptionTime': encryptionTime,
      'decryptionTime': decryptionTime,
      'transmissionSpeed': transmissionSpeed,
      'dataLossRate': dataLossRate,
      'attackSuccessRate': attackSuccessRate,
      'securityScore': securityScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}