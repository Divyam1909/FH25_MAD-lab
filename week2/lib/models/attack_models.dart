// ...existing code...
import 'dart:math';
import 'crypto_models.dart';

/// Advanced attack categories
enum AttackCategory {
  cryptanalytic,
  sideChannel,
  quantumComputing,
  machineLearning,
  socialEngineering,
  physical,
  protocol,
  implementation,
  postQuantum,
  adversarialML,
}

/// Specific attack types with advanced implementations
enum AttackType {
  // None
  noAttack,

  // Cryptanalytic
  differentialCryptanalysis,
  linearCryptanalysis,
  algebraicAttack,
  meetInTheMiddle,
  bruteForceOptimized,
  dictionaryAttack,
  birthdayAttack,
  collisionAttack,

  // Side-channel
  timingAttack,
  powerAnalysis,
  electromagneticAttack,
  acousticAttack,
  cacheAttack,
  speculativeExecution,

  // Quantum
  shorsAlgorithm,
  groversAlgorithm,
  quantumAnnealing,
  adiabticQuantumComputing,

  // Machine Learning
  adversarialExamples,
  modelInversion,
  membershipInference,
  poisoningAttack,
  backdoorAttack,
  gradientLeakage,

  // Protocol
  manInTheMiddle,
  replayAttack,
  sessionHijacking,
  downgradeAttack,
  protocolConfusion,
  crossProtocolAttack,

  // Advanced
  zeroDay,
  supplychainAttack,
  firmwareAttack,
  hardwareBackdoor,
  rootkitAttack,
  persistentThreat,
}

/// Attack complexity levels
enum AttackComplexity {
  trivial(1),
  low(2),
  medium(3),
  high(4),
  expert(5),
  nationState(6);

  const AttackComplexity(this.level);
  final int level;
}

/// Advanced attack parameters
class AttackParameters {
  final AttackType attackType;
  final AttackCategory category;
  final AttackComplexity complexity;
  final Duration estimatedTime;
  final double successProbability;
  final int requiredResources; // Computational units
  final List<String> prerequisites;
  final Map<String, dynamic> algorithmParams;
  final SecurityLevel targetSecurityLevel;
  final bool requiresInteraction;
  final bool isQuantumEnhanced;

  AttackParameters({
    required this.attackType,
    required this.category,
    required this.complexity,
    required this.estimatedTime,
    required this.successProbability,
    required this.requiredResources,
    this.prerequisites = const [],
    this.algorithmParams = const {},
    required this.targetSecurityLevel,
    this.requiresInteraction = false,
    this.isQuantumEnhanced = false,
  });
}

/// Attack execution context
class AttackContext {
  final String targetId;
  final String targetType;
  final Map<String, dynamic> targetProperties;
  final Map<String, dynamic> environmentParams;
  final List<String> availableResources;
  final DateTime startTime;
  final Duration timeLimit;
  final bool isSimulated;
  final String attackerId;

  AttackContext({
    required this.targetId,
    required this.targetType,
    required this.targetProperties,
    required this.environmentParams,
    required this.availableResources,
    required this.startTime,
    required this.timeLimit,
    this.isSimulated = true,
    required this.attackerId,
  });
}

/// Attack execution result
class AttackResult {
  final String attackId;
  final AttackType attackType;
  final bool successful;
  final double confidenceScore;
  final Duration executionTime;
  final int resourcesUsed;
  final Map<String, dynamic> extractedData;
  final List<String> vulnerabilitiesFound;
  final List<AttackStep> executionSteps;
  final Map<String, double> metrics;
  final DateTime completedAt;
  final String? errorMessage;

  AttackResult({
    required this.attackId,
    required this.attackType,
    required this.successful,
    required this.confidenceScore,
    required this.executionTime,
    required this.resourcesUsed,
    this.extractedData = const {},
    this.vulnerabilitiesFound = const [],
    this.executionSteps = const [],
    this.metrics = const {},
    required this.completedAt,
    this.errorMessage,
  });

  double get successRate => successful ? 1.0 : 0.0;
  double get efficiency =>
      resourcesUsed > 0 ? confidenceScore / resourcesUsed : 0.0;
}

/// Individual attack step for detailed analysis
class AttackStep {
  final int stepNumber;
  final String description;
  final String operation;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> outputs;
  final Duration stepTime;
  final bool successful;
  final double confidence;
  final String? errorDetails;
  AttackStep({
    required this.stepNumber,
    required this.description,
    required this.operation,
    required this.inputs,
    required this.outputs,
    required this.stepTime,
    required this.successful,
    required this.confidence,
    this.errorDetails,
  });
}

/// Machine Learning Attack Models
class MLAttackModel {
  final String modelType; // CNN, RNN, Transformer, etc.
  final Map<String, dynamic> hyperparameters;
  final List<String> targetModels;
  final double adversarialBudget;
  final String perturbationMethod;
  final int maxIterations;
  final double learningRate;
  final bool useGradientMasking;

  MLAttackModel({
    required this.modelType,
    required this.hyperparameters,
    required this.targetModels,
    required this.adversarialBudget,
    required this.perturbationMethod,
    required this.maxIterations,
    required this.learningRate,
    this.useGradientMasking = false,
  });
}

/// Side-channel attack measurements
class SideChannelMeasurement {
  final String channelType; // timing, power, EM, acoustic
  final List<double> measurements;
  final double samplingRate;
  final Duration measurementPeriod;
  final Map<String, dynamic> instrumentConfig;
  final double noiseLevel;
  final List<String> filteredSignals;

  SideChannelMeasurement({
    required this.channelType,
    required this.measurements,
    required this.samplingRate,
    required this.measurementPeriod,
    required this.instrumentConfig,
    required this.noiseLevel,
    this.filteredSignals = const [],
  });

  double get signalToNoiseRatio {
    if (measurements.isEmpty) return 0.0;
    final mean = measurements.reduce((a, b) => a + b) / measurements.length;
    final variance =
        measurements.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
            measurements.length;
    final signal = mean.abs();
    final noise = sqrt(variance);
    return noise > 0 ? signal / noise : double.infinity;
  }
}

/// Quantum attack simulation parameters
class QuantumAttackParams {
  final int qubits;
  final double coherenceTime;
  final double gateErrorRate;
  final double measurementErrorRate;
  final String quantumAlgorithm;
  final Map<String, dynamic> circuitParams;
  final bool useQuantumCorrection;
  final int shotCount;

  QuantumAttackParams({
    required this.qubits,
    required this.coherenceTime,
    required this.gateErrorRate,
    required this.measurementErrorRate,
    required this.quantumAlgorithm,
    required this.circuitParams,
    this.useQuantumCorrection = true,
    this.shotCount = 1024,
  });
}

/// Advanced threat intelligence
class ThreatIntelligence {
  final String threatId;
  final AttackType primaryAttack;
  final List<AttackType> attackChain;
  final Map<String, double> targetProbabilities;
  final List<String> indicators;
  final Map<String, dynamic> attribution;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final String severity; // Critical, High, Medium, Low
  final List<String> mitigations;
  final double confidence;

  ThreatIntelligence({
    required this.threatId,
    required this.primaryAttack,
    required this.attackChain,
    required this.targetProbabilities,
    required this.indicators,
    required this.attribution,
    required this.firstSeen,
    required this.lastSeen,
    required this.severity,
    required this.mitigations,
    required this.confidence,
  });
}

/// Attack pattern for advanced simulation
class AttackPattern {
  final String patternId;
  final String name;
  final List<AttackStep> steps;
  final Map<String, dynamic> conditions;
  final double baseProbability;
  final Map<String, double> adaptiveProbabilities;
  final List<String> countermeasures;
  final bool isAdaptive;
  final String difficultyLevel;

  AttackPattern({
    required this.patternId,
    required this.name,
    required this.steps,
    required this.conditions,
    required this.baseProbability,
    this.adaptiveProbabilities = const {},
    this.countermeasures = const [],
    this.isAdaptive = false,
    required this.difficultyLevel,
  });
}

/// Multi-vector attack coordination
class AttackVector {
  final String vectorId;
  final AttackType attackType;
  final String entryPoint;
  final List<String> propagationPath;
  final Map<String, dynamic> payload;
  final double persistence;
  final bool isStealthy;
  final List<String> coverTechniques;

  AttackVector({
    required this.vectorId,
    required this.attackType,
    required this.entryPoint,
    required this.propagationPath,
    required this.payload,
    required this.persistence,
    this.isStealthy = false,
    this.coverTechniques = const [],
  });
}

class MultiVectorAttack {
  final String campaignId;
  final List<AttackVector> vectors;
  final Map<String, dynamic> coordination;
  final DateTime startTime;
  final Duration duration;
  final Map<String, double> successThresholds;
  final bool useAI;
  final String orchestrationStrategy;

  MultiVectorAttack({
    required this.campaignId,
    required this.vectors,
    required this.coordination,
    required this.startTime,
    required this.duration,
    required this.successThresholds,
    this.useAI = false,
    required this.orchestrationStrategy,
  });
}
