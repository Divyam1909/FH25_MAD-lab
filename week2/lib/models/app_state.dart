import 'package:flutter/foundation.dart';
import 'crypto_models.dart';
import 'attack_models.dart';
import 'network_models.dart';

class AppState extends ChangeNotifier {
  int _currentIndex = 0;
  String? _uploadedEncryptionCode;
  String? _uploadedAttackCode;
  CryptoAlgorithm _selectedEncryption = CryptoAlgorithm.aes256gcm;
  AttackType _selectedAttack = AttackType.manInTheMiddle;
  bool _isRunningTest = false;
  List<AdvancedBenchmarkResult> _benchmarkResults = [];
  List<String> _logs = [];
  SecurityLevel _selectedSecurityLevel = SecurityLevel.level3;
  String _selectedNetworkTopology = 'mesh';
  bool _enableQuantumResistance = false;
  bool _enableMLDetection = true;
  bool _enableBlockchainAnalysis = false;
  Map<String, dynamic> _advancedSettings = {};

  // New enhanced properties
  bool _isDarkMode = true;
  bool _enableAnimations = true;
  bool _enableGlowEffects = true;
  bool _autoClearSensitiveData = true;
  Duration _sessionTimeout = const Duration(hours: 2);
  String _validationStrictness = 'moderate';
  int _maxSimulationSteps = 1000;
  bool _enablePerformanceMonitoring = true;
  bool _aggressiveMemoryManagement = false;
  bool _enableRealTimeMonitoring = true;
  String _currentScreen = 'dashboard';
  DateTime? _lastActivity;

  // Getters
  int get currentIndex => _currentIndex;
  String? get uploadedEncryptionCode => _uploadedEncryptionCode;
  String? get uploadedAttackCode => _uploadedAttackCode;
  CryptoAlgorithm get selectedEncryption => _selectedEncryption;
  AttackType get selectedAttack => _selectedAttack;
  bool get isRunningTest => _isRunningTest;
  List<AdvancedBenchmarkResult> get benchmarkResults => _benchmarkResults;
  List<String> get logs => _logs;
  SecurityLevel get selectedSecurityLevel => _selectedSecurityLevel;
  String get selectedNetworkTopology => _selectedNetworkTopology;
  bool get enableQuantumResistance => _enableQuantumResistance;
  bool get enableMLDetection => _enableMLDetection;
  bool get enableBlockchainAnalysis => _enableBlockchainAnalysis;
  Map<String, dynamic> get advancedSettings => _advancedSettings;

  // New enhanced getters
  bool get isDarkMode => _isDarkMode;
  bool get enableAnimations => _enableAnimations;
  bool get enableGlowEffects => _enableGlowEffects;
  bool get autoClearSensitiveData => _autoClearSensitiveData;
  Duration get sessionTimeout => _sessionTimeout;
  String get validationStrictness => _validationStrictness;
  int get maxSimulationSteps => _maxSimulationSteps;
  bool get enablePerformanceMonitoring => _enablePerformanceMonitoring;
  bool get aggressiveMemoryManagement => _aggressiveMemoryManagement;
  bool get enableRealTimeMonitoring => _enableRealTimeMonitoring;
  String get currentScreen => _currentScreen;
  DateTime? get lastActivity => _lastActivity;

  // Label helpers for legacy UI/services compatibility
  String get selectedEncryptionLabel => _encryptionAlgorithmToLabel(_selectedEncryption);
  String get selectedAttackLabel => _attackTypeToLabel(_selectedAttack);
  List<String> get encryptionOptionLabels => [
    'AES',
    'Hybrid AES + ECC',
    'Homomorphic',
    'ABE',
    'RSA',
    'Custom',
  ];
  List<String> get attackOptionLabels => [
    'No Attack',
    'MITM',
    'Replay',
    'Brute Force',
    'DoS',
    'Ciphertext Manipulation',
    'Custom',
  ];

  // Available options for advanced algorithms
  final List<CryptoAlgorithm> encryptionOptions = [
    CryptoAlgorithm.aes256gcm,
    CryptoAlgorithm.chacha20poly1305,
    CryptoAlgorithm.rsa4096,
    CryptoAlgorithm.eccP521,
    CryptoAlgorithm.ed25519,
    CryptoAlgorithm.kyber1024,
    CryptoAlgorithm.dilithium5,
    CryptoAlgorithm.falcon1024,
    CryptoAlgorithm.ntru,
    CryptoAlgorithm.homomorphicFHE,
    CryptoAlgorithm.zeroKnowledgeProof,
    CryptoAlgorithm.attributeBasedEncryption,
    CryptoAlgorithm.identityBasedEncryption,
    CryptoAlgorithm.hybridPQC,
    CryptoAlgorithm.multiLayerEncryption,
  ];

  final List<AttackType> attackOptions = [
    AttackType.noAttack,
    AttackType.manInTheMiddle,
    AttackType.replayAttack,
    AttackType.differentialCryptanalysis,
    AttackType.linearCryptanalysis,
    AttackType.algebraicAttack,
    AttackType.meetInTheMiddle,
    AttackType.bruteForceOptimized,
    AttackType.timingAttack,
    AttackType.powerAnalysis,
    AttackType.electromagneticAttack,
    AttackType.acousticAttack,
    AttackType.cacheAttack,
    AttackType.speculativeExecution,
    AttackType.shorsAlgorithm,
    AttackType.groversAlgorithm,
    AttackType.quantumAnnealing,
    AttackType.adversarialExamples,
    AttackType.modelInversion,
    AttackType.membershipInference,
    AttackType.poisoningAttack,
    AttackType.backdoorAttack,
    AttackType.gradientLeakage,
    AttackType.sessionHijacking,
    AttackType.downgradeAttack,
    AttackType.protocolConfusion,
    AttackType.crossProtocolAttack,
  ];

  final List<SecurityLevel> securityLevels = [
    SecurityLevel.level1,
    SecurityLevel.level2,
    SecurityLevel.level3,
    SecurityLevel.level4,
    SecurityLevel.level5,
  ];

  final List<String> networkTopologies = [
    'star',
    'mesh',
    'tree',
    'hybrid',
    'quantum_mesh',
    'blockchain_network',
  ];

  // Setters
  void setCurrentIndex(int index) {
    _currentIndex = index;
    _updateActivity();
    notifyListeners();
  }

  void setUploadedEncryptionCode(String? code) {
    _uploadedEncryptionCode = code;
    _updateActivity();
    notifyListeners();
  }

  void setUploadedAttackCode(String? code) {
    _uploadedAttackCode = code;
    _updateActivity();
    notifyListeners();
  }

  // Accept enum or label
  void setSelectedEncryption(CryptoAlgorithm algorithm) {
    _selectedEncryption = algorithm;
    _updateActivity();
    notifyListeners();
  }

  // Accept enum or label
  void setSelectedAttack(AttackType attack) {
    _selectedAttack = attack;
    _updateActivity();
    notifyListeners();
  }

  void setSelectedSecurityLevel(SecurityLevel level) {
    _selectedSecurityLevel = level;
    _updateActivity();
    notifyListeners();
  }

  void setSelectedNetworkTopology(String topology) {
    _selectedNetworkTopology = topology;
    _updateActivity();
    notifyListeners();
  }

  void setQuantumResistance(bool enabled) {
    _enableQuantumResistance = enabled;
    _updateActivity();
    notifyListeners();
  }

  void setMLDetection(bool enabled) {
    _enableMLDetection = enabled;
    _updateActivity();
    notifyListeners();
  }

  void setBlockchainAnalysis(bool enabled) {
    _enableBlockchainAnalysis = enabled;
    _updateActivity();
    notifyListeners();
  }

  void updateAdvancedSetting(String key, dynamic value) {
    _advancedSettings[key] = value;
    _updateActivity();
    notifyListeners();
  }

  void setRunningTest(bool isRunning) {
    _isRunningTest = isRunning;
    _updateActivity();
    notifyListeners();
  }

  // Accept legacy or advanced results
  void addBenchmarkResult(AdvancedBenchmarkResult result) {
    _benchmarkResults.add(result);
    // Keep only recent results
    if (_benchmarkResults.length > 100) {
      _benchmarkResults.removeAt(0);
    }
    _updateActivity();
    notifyListeners();
  }

  void clearBenchmarkResults() {
    _benchmarkResults.clear();
    _updateActivity();
    notifyListeners();
  }

  void addLog(String log) {
    _logs.add('${DateTime.now().toIso8601String()}: $log');
    // Keep only recent logs
    if (_logs.length > 1000) {
      _logs.removeAt(0);
    }
    _updateActivity();
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    _updateActivity();
    notifyListeners();
  }

  // Advanced analysis methods
  List<AdvancedBenchmarkResult> getResultsByAlgorithm(CryptoAlgorithm algorithm) {
    return _benchmarkResults.where((r) => r.cryptoParameters.algorithm == algorithm).toList();
  }

  List<AdvancedBenchmarkResult> getResultsBySecurityLevel(SecurityLevel level) {
    return _benchmarkResults.where((r) => r.cryptoParameters.securityLevel == level).toList();
  }

  List<AdvancedBenchmarkResult> getResultsByAttackType(AttackType attackType) {
    return _benchmarkResults.where((r) => r.attackParameters.attackType == attackType).toList();
  }

  double getAverageSecurityScore() {
    if (_benchmarkResults.isEmpty) return 0.0;
    return _benchmarkResults.map((r) => r.securityMetrics.overallSecurityScore).reduce((a, b) => a + b) / _benchmarkResults.length;
  }

  double getAveragePerformanceScore() {
    if (_benchmarkResults.isEmpty) return 0.0;
    return _benchmarkResults.map((r) => r.performanceMetrics.throughput).reduce((a, b) => a + b) / _benchmarkResults.length;
  }

  Map<CryptoAlgorithm, double> getAlgorithmSuccessRates() {
    final Map<CryptoAlgorithm, double> rates = {};
    for (final algorithm in encryptionOptions) {
      final results = getResultsByAlgorithm(algorithm);
      if (results.isNotEmpty) {
        final successRate = results.where((r) => !r.attackResult.successful).length / results.length;
        rates[algorithm] = successRate;
      }
    }
    return rates;
  }

  Map<AttackType, double> getAttackSuccessRates() {
    final Map<AttackType, double> rates = {};
    for (final attackType in attackOptions) {
      final results = getResultsByAttackType(attackType);
      if (results.isNotEmpty) {
        final successRate = results.where((r) => r.attackResult.successful).length / results.length;
        rates[attackType] = successRate;
      }
    }
    return rates;
  }

  // Export and import functionality
  Map<String, dynamic> exportResults() {
    return {
      'benchmark_results': _benchmarkResults.map((r) => r.toJson()).toList(),
      'settings': {
        'selected_encryption': _selectedEncryption.name,
        'selected_attack': _selectedAttack.name,
        'security_level': _selectedSecurityLevel.name,
        'network_topology': _selectedNetworkTopology,
        'quantum_resistance': _enableQuantumResistance,
        'ml_detection': _enableMLDetection,
        'blockchain_analysis': _enableBlockchainAnalysis,
        'advanced_settings': _advancedSettings,
      },
      'logs': _logs,
      'export_timestamp': DateTime.now().toIso8601String(),
    };
  }

  void importResults(Map<String, dynamic> data) {
    addLog('Results imported successfully');
    notifyListeners();
  }

  void resetLegacyToDefaults() {
    _selectedEncryption = CryptoAlgorithm.aes256gcm;
    _selectedAttack = AttackType.manInTheMiddle;
    _selectedSecurityLevel = SecurityLevel.level3;
    _selectedNetworkTopology = 'mesh';
    _enableQuantumResistance = false;
    _enableMLDetection = true;
    _enableBlockchainAnalysis = false;
    _advancedSettings.clear();
    addLog('Settings reset to defaults');
    notifyListeners();
  }

  // Mapping helpers
  CryptoAlgorithm _labelToEncryptionAlgorithm(String label) {
    switch (label) {
      case 'AES':
        return CryptoAlgorithm.aes256gcm;
      case 'Hybrid AES + ECC':
        return CryptoAlgorithm.hybridPQC;
      case 'Homomorphic':
        return CryptoAlgorithm.homomorphicFHE;
      case 'ABE':
        return CryptoAlgorithm.attributeBasedEncryption;
      case 'RSA':
        return CryptoAlgorithm.rsa4096;
      case 'Custom':
      default:
        return CryptoAlgorithm.multiLayerEncryption;
    }
  }

  String _encryptionAlgorithmToLabel(CryptoAlgorithm algo) {
    switch (algo) {
      case CryptoAlgorithm.aes256gcm:
        return 'AES';
      case CryptoAlgorithm.hybridPQC:
        return 'Hybrid AES + ECC';
      case CryptoAlgorithm.homomorphicFHE:
        return 'Homomorphic';
      case CryptoAlgorithm.attributeBasedEncryption:
        return 'ABE';
      case CryptoAlgorithm.rsa4096:
        return 'RSA';
      default:
        return 'Custom';
    }
  }

  AttackType _labelToAttackType(String label) {
    switch (label) {
      case 'No Attack':
        return AttackType.noAttack;
      case 'MITM':
        return AttackType.manInTheMiddle;
      case 'Replay':
        return AttackType.replayAttack;
      case 'Brute Force':
        return AttackType.bruteForceOptimized;
      case 'DoS':
        return AttackType.persistentThreat;
      case 'Ciphertext Manipulation':
        return AttackType.protocolConfusion;
      case 'Custom':
      default:
        return AttackType.manInTheMiddle;
    }
  }

  String _attackTypeToLabel(AttackType type) {
    switch (type) {
      case AttackType.noAttack:
        return 'No Attack';
      case AttackType.manInTheMiddle:
        return 'MITM';
      case AttackType.replayAttack:
        return 'Replay';
      case AttackType.bruteForceOptimized:
        return 'Brute Force';
      case AttackType.persistentThreat:
        return 'DoS';
      case AttackType.protocolConfusion:
        return 'Ciphertext Manipulation';
      default:
        return 'Custom';
    }
  }

  // New enhanced setters
  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    _updateActivity();
    notifyListeners();
  }

  void setEnableAnimations(bool enable) {
    _enableAnimations = enable;
    _updateActivity();
    notifyListeners();
  }

  void setEnableGlowEffects(bool enable) {
    _enableGlowEffects = enable;
    _updateActivity();
    notifyListeners();
  }

  void setAutoClearSensitiveData(bool enable) {
    _autoClearSensitiveData = enable;
    _updateActivity();
    notifyListeners();
  }

  void setSessionTimeout(Duration? timeout) {
    if (timeout != null) {
      _sessionTimeout = timeout;
      _updateActivity();
      notifyListeners();
    }
  }

  void setValidationStrictness(String? strictness) {
    if (strictness != null) {
      _validationStrictness = strictness;
      _updateActivity();
      notifyListeners();
    }
  }

  void setMaxSimulationSteps(int steps) {
    _maxSimulationSteps = steps;
    _updateActivity();
    notifyListeners();
  }

  void setEnablePerformanceMonitoring(bool enable) {
    _enablePerformanceMonitoring = enable;
    _updateActivity();
    notifyListeners();
  }

  void setAggressiveMemoryManagement(bool enable) {
    _aggressiveMemoryManagement = enable;
    _updateActivity();
    notifyListeners();
  }

  void setEnableRealTimeMonitoring(bool enable) {
    _enableRealTimeMonitoring = enable;
    _updateActivity();
    notifyListeners();
  }

  void setCurrentScreen(String screen) {
    _currentScreen = screen;
    _updateActivity();
    notifyListeners();
  }

  // Utility methods
  void _updateActivity() {
    _lastActivity = DateTime.now();
  }

  bool get isSessionExpired {
    if (_lastActivity == null) return false;
    return DateTime.now().difference(_lastActivity!) > _sessionTimeout;
  }

  void resetToDefaults() {
    _isDarkMode = true;
    _enableAnimations = true;
    _enableGlowEffects = true;
    _autoClearSensitiveData = true;
    _sessionTimeout = const Duration(hours: 2);
    _validationStrictness = 'moderate';
    _maxSimulationSteps = 1000;
    _enablePerformanceMonitoring = true;
    _aggressiveMemoryManagement = false;
    _enableRealTimeMonitoring = true;
    _enableQuantumResistance = false;
    _enableMLDetection = true;
    _enableBlockchainAnalysis = false;
    _selectedSecurityLevel = SecurityLevel.level3;
    _selectedNetworkTopology = 'mesh';
    _advancedSettings.clear();
    _updateActivity();
    notifyListeners();
  }

  // Clear sensitive data
  void clearSensitiveData() {
    _uploadedEncryptionCode = null;
    _uploadedAttackCode = null;
    _logs.clear();
    _benchmarkResults.clear();
    _updateActivity();
    notifyListeners();
  }

  // Auto-clear based on settings
  void performAutoCleanup() {
    if (_autoClearSensitiveData && isSessionExpired) {
      clearSensitiveData();
    }
    
    if (_aggressiveMemoryManagement) {
      // Keep only recent logs and results
      if (_logs.length > 500) {
        _logs.removeRange(0, _logs.length - 500);
      }
      if (_benchmarkResults.length > 50) {
        _benchmarkResults.removeRange(0, _benchmarkResults.length - 50);
      }
      notifyListeners();
    }
  }

  // Enhanced compatibility methods (replacing duplicates)

  // Advanced settings management
  void setAdvancedSetting(String key, dynamic value) {
    _advancedSettings[key] = value;
    _updateActivity();
    notifyListeners();
  }

  T? getAdvancedSetting<T>(String key) {
    return _advancedSettings[key] as T?;
  }

  void removeAdvancedSetting(String key) {
    _advancedSettings.remove(key);
    _updateActivity();
    notifyListeners();
  }

  // Export app state
  Map<String, dynamic> exportState() {
    return {
      'currentIndex': _currentIndex,
      'selectedEncryption': _selectedEncryption.toString(),
      'selectedAttack': _selectedAttack.toString(),
      'selectedSecurityLevel': _selectedSecurityLevel.toString(),
      'selectedNetworkTopology': _selectedNetworkTopology,
      'enableQuantumResistance': _enableQuantumResistance,
      'enableMLDetection': _enableMLDetection,
      'enableBlockchainAnalysis': _enableBlockchainAnalysis,
      'isDarkMode': _isDarkMode,
      'enableAnimations': _enableAnimations,
      'enableGlowEffects': _enableGlowEffects,
      'autoClearSensitiveData': _autoClearSensitiveData,
      'sessionTimeout': _sessionTimeout.inMilliseconds,
      'validationStrictness': _validationStrictness,
      'maxSimulationSteps': _maxSimulationSteps,
      'enablePerformanceMonitoring': _enablePerformanceMonitoring,
      'aggressiveMemoryManagement': _aggressiveMemoryManagement,
      'enableRealTimeMonitoring': _enableRealTimeMonitoring,
      'advancedSettings': _advancedSettings,
      'exportTimestamp': DateTime.now().toIso8601String(),
    };
  }

  // Import app state
  void importState(Map<String, dynamic> state) {
    try {
      _currentIndex = state['currentIndex'] ?? 0;
      _selectedNetworkTopology = state['selectedNetworkTopology'] ?? 'mesh';
      _enableQuantumResistance = state['enableQuantumResistance'] ?? false;
      _enableMLDetection = state['enableMLDetection'] ?? true;
      _enableBlockchainAnalysis = state['enableBlockchainAnalysis'] ?? false;
      _isDarkMode = state['isDarkMode'] ?? true;
      _enableAnimations = state['enableAnimations'] ?? true;
      _enableGlowEffects = state['enableGlowEffects'] ?? true;
      _autoClearSensitiveData = state['autoClearSensitiveData'] ?? true;
      _validationStrictness = state['validationStrictness'] ?? 'moderate';
      _maxSimulationSteps = state['maxSimulationSteps'] ?? 1000;
      _enablePerformanceMonitoring = state['enablePerformanceMonitoring'] ?? true;
      _aggressiveMemoryManagement = state['aggressiveMemoryManagement'] ?? false;
      _enableRealTimeMonitoring = state['enableRealTimeMonitoring'] ?? true;
      
      if (state['sessionTimeout'] != null) {
        _sessionTimeout = Duration(milliseconds: state['sessionTimeout']);
      }
      
      if (state['advancedSettings'] != null) {
        _advancedSettings = Map<String, dynamic>.from(state['advancedSettings']);
      }
      
      _updateActivity();
      notifyListeners();
    } catch (e) {
      // If import fails, keep current state
      debugPrint('Failed to import state: $e');
    }
  }

  // Session management
  void refreshSession() {
    _updateActivity();
  }

  bool get needsSessionRefresh {
    if (_lastActivity == null) return false;
    final timeSinceActivity = DateTime.now().difference(_lastActivity!);
    return timeSinceActivity > const Duration(minutes: 30);
  }

  // Memory management
  void performMemoryCleanup() {
    if (_aggressiveMemoryManagement) {
      // Clear old logs
      if (_logs.length > 200) {
        _logs.removeRange(0, _logs.length - 200);
      }
      
      // Clear old benchmark results
      if (_benchmarkResults.length > 20) {
        _benchmarkResults.removeRange(0, _benchmarkResults.length - 20);
      }
      
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Perform cleanup
    if (_autoClearSensitiveData) {
      clearSensitiveData();
    }
    super.dispose();
  }
}

/// Legacy benchmark result kept for compatibility with existing screens
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
}

/// Advanced benchmark result with comprehensive metrics
class AdvancedBenchmarkResult {
  final CryptoParameters cryptoParameters;
  final AttackParameters attackParameters;
  final EncryptionResult encryptionResult;
  final AttackResult attackResult;
  final SecurityMetrics securityMetrics;
  final PerformanceMetrics performanceMetrics;
  final NetworkMetrics networkMetrics;
  final DateTime timestamp;
  final Duration totalTestTime;
  final Map<String, dynamic> additionalData;

  AdvancedBenchmarkResult({
    required this.cryptoParameters,
    required this.attackParameters,
    required this.encryptionResult,
    required this.attackResult,
    required this.securityMetrics,
    required this.performanceMetrics,
    required this.networkMetrics,
    required this.timestamp,
    required this.totalTestTime,
    this.additionalData = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'crypto_algorithm': cryptoParameters.algorithm.name,
      'security_level': cryptoParameters.securityLevel.name,
      'attack_type': attackParameters.attackType.name,
      'attack_complexity': attackParameters.complexity.name,
      'encryption_time': encryptionResult.encryptionTime,
      'throughput': encryptionResult.throughput,
      'attack_successful': attackResult.successful,
      'attack_confidence': attackResult.confidenceScore,
      'security_score': securityMetrics.overallSecurityScore,
      'performance_score': performanceMetrics.throughput,
      'network_latency': networkMetrics.latency,
      'timestamp': timestamp.toIso8601String(),
      'total_test_time': totalTestTime.inMilliseconds,
      'additional_data': additionalData,
    };
  }
}

/// Performance metrics for comprehensive analysis
class PerformanceMetrics {
  final double throughput; // bytes per second
  final double latency; // milliseconds
  final double cpuUsage; // percentage
  final double memoryUsage; // MB
  final double energyConsumption; // watts
  final double scalabilityScore;
  final Map<String, double> customMetrics;

  PerformanceMetrics({
    required this.throughput,
    required this.latency,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.energyConsumption,
    required this.scalabilityScore,
    this.customMetrics = const {},
  });
}

/// Network performance metrics
class NetworkMetrics {
  final double latency; // milliseconds
  final double jitter; // milliseconds
  final double packetLoss; // percentage
  final double bandwidth; // Mbps
  final int hopCount;
  final double reliability;
  final Map<String, double> qosMetrics;

  NetworkMetrics({
    required this.latency,
    required this.jitter,
    required this.packetLoss,
    required this.bandwidth,
    required this.hopCount,
    required this.reliability,
    this.qosMetrics = const {},
  });
}