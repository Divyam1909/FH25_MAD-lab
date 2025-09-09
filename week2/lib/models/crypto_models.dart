import 'dart:typed_data';
// ...existing code...

/// Advanced cryptographic algorithm types
enum CryptoAlgorithm {
  // Symmetric
  aes256gcm,
  chacha20poly1305,
  aes256ctr,
  // Asymmetric
  rsa4096,
  eccP521,
  ed25519,
  // Post-Quantum
  kyber1024,
  dilithium5,
  falcon1024,
  ntru,
  // Advanced
  homomorphicFHE,
  zeroKnowledgeProof,
  attributeBasedEncryption,
  identityBasedEncryption,
  // Hybrid
  hybridPQC,
  multiLayerEncryption,
}

/// Security levels based on NIST standards
enum SecurityLevel {
  level1(128), // AES-128 equivalent
  level2(192), // AES-192 equivalent
  level3(256), // AES-256 equivalent
  level4(384), // Beyond AES-256
  level5(512); // Quantum-resistant

  const SecurityLevel(this.bits);
  final int bits;
}

/// Advanced cryptographic parameters
class CryptoParameters {
  final CryptoAlgorithm algorithm;
  final SecurityLevel securityLevel;
  final int keySize;
  final String mode;
  final Map<String, dynamic> algorithmParams;
  final Duration keyRotationInterval;
  final bool isQuantumResistant;

  const CryptoParameters({
    required this.algorithm,
    required this.securityLevel,
    required this.keySize,
    required this.mode,
    this.algorithmParams = const {},
    this.keyRotationInterval = const Duration(hours: 24),
    this.isQuantumResistant = false,
  });
}

/// Cryptographic key material with advanced properties
class CryptoKey {
  final String id;
  final Uint8List keyMaterial;
  final CryptoAlgorithm algorithm;
  final SecurityLevel securityLevel;
  final DateTime createdAt;
  final DateTime expiresAt;
  final Map<String, dynamic> metadata;
  final bool isCompromised;
  final int usageCount;
  final int maxUsages;

  CryptoKey({
    required this.id,
    required this.keyMaterial,
    required this.algorithm,
    required this.securityLevel,
    required this.createdAt,
    required this.expiresAt,
    this.metadata = const {},
    this.isCompromised = false,
    this.usageCount = 0,
    this.maxUsages = -1, // -1 means unlimited
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid =>
      !isCompromised &&
      !isExpired &&
      (maxUsages == -1 || usageCount < maxUsages);

  CryptoKey incrementUsage() {
    return CryptoKey(
      id: id,
      keyMaterial: keyMaterial,
      algorithm: algorithm,
      securityLevel: securityLevel,
      createdAt: createdAt,
      expiresAt: expiresAt,
      metadata: metadata,
      isCompromised: isCompromised,
      usageCount: usageCount + 1,
      maxUsages: maxUsages,
    );
  }
}

/// Advanced encryption result with comprehensive metadata
class EncryptionResult {
  final Uint8List ciphertext;
  final Uint8List? nonce;
  final Uint8List? authTag;
  final Uint8List? salt;
  final CryptoParameters parameters;
  final String keyId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final double encryptionTime;
  final int plaintextSize;
  final int ciphertextSize;
  final double compressionRatio;

  EncryptionResult({
    required this.ciphertext,
    this.nonce,
    this.authTag,
    this.salt,
    required this.parameters,
    required this.keyId,
    required this.timestamp,
    this.metadata = const {},
    required this.encryptionTime,
    required this.plaintextSize,
    required this.ciphertextSize,
    required this.compressionRatio,
  });

  double get overhead => (ciphertextSize - plaintextSize) / plaintextSize;
  double get throughput => plaintextSize / encryptionTime; // bytes per second
}

/// Zero-Knowledge Proof structures
class ZKProof {
  final String proofType;
  final Uint8List proof;
  final Uint8List publicInputs;
  final Uint8List verificationKey;
  final Map<String, dynamic> circuitParams;
  final DateTime generatedAt;
  final bool isValid;

  ZKProof({
    required this.proofType,
    required this.proof,
    required this.publicInputs,
    required this.verificationKey,
    required this.circuitParams,
    required this.generatedAt,
    required this.isValid,
  });
}

/// Homomorphic Encryption Operations
enum HomomorphicOperation {
  addition,
  multiplication,
  comparison,
  bitwiseAnd,
  bitwiseOr,
  bitwiseXor,
  rotation,
  negation,
}

class HomomorphicCiphertext {
  final Uint8List data;
  final CryptoParameters parameters;
  final int noiseLevel;
  final int maxOperations;
  final int operationsPerformed;
  final List<HomomorphicOperation> operationHistory;

  HomomorphicCiphertext({
    required this.data,
    required this.parameters,
    required this.noiseLevel,
    required this.maxOperations,
    this.operationsPerformed = 0,
    this.operationHistory = const [],
  });

  bool get canPerformOperation => operationsPerformed < maxOperations;
  double get noiseGrowthRate => operationsPerformed / maxOperations;
}

/// Quantum-resistant lattice-based structures
class LatticeParameters {
  final int dimension;
  final int modulus;
  final double standardDeviation;
  final int hammingWeight;
  final String latticeType; // LWE, RLWE, MLWE

  LatticeParameters({
    required this.dimension,
    required this.modulus,
    required this.standardDeviation,
    required this.hammingWeight,
    required this.latticeType,
  });
}

/// Attribute-Based Encryption structures
class ABEPolicy {
  final String policyString;
  final Map<String, dynamic> attributes;
  final int threshold;
  final List<String> requiredAttributes;
  final DateTime validFrom;
  final DateTime validUntil;

  ABEPolicy({
    required this.policyString,
    required this.attributes,
    required this.threshold,
    required this.requiredAttributes,
    required this.validFrom,
    required this.validUntil,
  });

  bool isValidAt(DateTime time) {
    return time.isAfter(validFrom) && time.isBefore(validUntil);
  }
}

/// Advanced security metrics and analysis
class SecurityMetrics {
  final double entropyScore;
  final double avalancheEffect;
  final double correlationCoefficient;
  final double frequencyAnalysisScore;
  final double randomnessScore;
  final Map<String, double> statisticalTests;
  final double quantumResistanceScore;
  final DateTime analyzedAt;

  SecurityMetrics({
    required this.entropyScore,
    required this.avalancheEffect,
    required this.correlationCoefficient,
    required this.frequencyAnalysisScore,
    required this.randomnessScore,
    required this.statisticalTests,
    required this.quantumResistanceScore,
    required this.analyzedAt,
  });

  double get overallSecurityScore {
    final scores = [
      entropyScore,
      avalancheEffect,
      correlationCoefficient,
      frequencyAnalysisScore,
      randomnessScore,
      quantumResistanceScore,
    ];
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}

/// Multi-party computation structures
class MPCParty {
  final String id;
  final String publicKey;
  final String role;
  final Map<String, dynamic> capabilities;
  final bool isOnline;
  final DateTime lastSeen;

  MPCParty({
    required this.id,
    required this.publicKey,
    required this.role,
    required this.capabilities,
    required this.isOnline,
    required this.lastSeen,
  });
}

class MPCProtocol {
  final String protocolType;
  final List<MPCParty> parties;
  final int threshold;
  final Map<String, dynamic> parameters;
  final SecurityLevel securityLevel;
  final bool supportsPreprocessing;
  final bool supportsOnlinePhase;

  MPCProtocol({
    required this.protocolType,
    required this.parties,
    required this.threshold,
    required this.parameters,
    required this.securityLevel,
    required this.supportsPreprocessing,
    required this.supportsOnlinePhase,
  });
}
