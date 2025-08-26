import 'dart:math';

class BenchmarkService {
  /// Calculate security score based on various metrics
  double calculateSecurityScore(
    double encryptionTime,
    double decryptionTime,
    double attackSuccessRate,
  ) {
    // Base score starts at 100
    double score = 100.0;
    
    // Penalize for attack success
    score -= attackSuccessRate;
    
    // Slight penalty for very fast encryption (might indicate weak encryption)
    if (encryptionTime < 10) {
      score -= 5;
    }
    
    // Slight penalty for very slow encryption (usability concern)
    if (encryptionTime > 1000) {
      score -= 10;
    }
    
    // Bonus for reasonable encryption time (10-500ms)
    if (encryptionTime >= 10 && encryptionTime <= 500) {
      score += 5;
    }
    
    // Ensure score stays within 0-100 range
    return max(0, min(100, score));
  }

  /// Calculate performance metrics
  Map<String, double> calculatePerformanceMetrics({
    required double encryptionTime,
    required double decryptionTime,
    required double dataSize,
  }) {
    final throughputEncryption = dataSize / (encryptionTime / 1000); // bytes/sec
    final throughputDecryption = dataSize / (decryptionTime / 1000); // bytes/sec
    final totalTime = encryptionTime + decryptionTime;
    final efficiency = dataSize / totalTime; // bytes/ms
    
    return {
      'throughputEncryption': throughputEncryption,
      'throughputDecryption': throughputDecryption,
      'totalTime': totalTime,
      'efficiency': efficiency,
    };
  }

  /// Generate benchmark report
  BenchmarkReport generateReport(List<dynamic> results) {
    if (results.isEmpty) {
      return BenchmarkReport.empty();
    }

    // Calculate averages
    final avgEncryptionTime = results
        .map((r) => r.encryptionTime as double)
        .reduce((a, b) => a + b) / results.length;
    
    final avgDecryptionTime = results
        .map((r) => r.decryptionTime as double)
        .reduce((a, b) => a + b) / results.length;
    
    final avgSecurityScore = results
        .map((r) => r.securityScore as double)
        .reduce((a, b) => a + b) / results.length;
    
    final avgAttackSuccessRate = results
        .map((r) => r.attackSuccessRate as double)
        .reduce((a, b) => a + b) / results.length;

    // Find best and worst performing algorithms
    final bestSecurity = results.reduce((a, b) => 
        a.securityScore > b.securityScore ? a : b);
    final fastestEncryption = results.reduce((a, b) => 
        a.encryptionTime < b.encryptionTime ? a : b);

    return BenchmarkReport(
      totalTests: results.length,
      averageEncryptionTime: avgEncryptionTime,
      averageDecryptionTime: avgDecryptionTime,
      averageSecurityScore: avgSecurityScore,
      averageAttackSuccessRate: avgAttackSuccessRate,
      bestSecurityAlgorithm: bestSecurity.encryptionAlgorithm,
      fastestAlgorithm: fastestEncryption.encryptionAlgorithm,
      recommendations: _generateRecommendations(
        avgEncryptionTime,
        avgDecryptionTime,
        avgSecurityScore,
        avgAttackSuccessRate,
      ),
    );
  }

  /// Generate security recommendations
  List<String> _generateRecommendations(
    double avgEncTime,
    double avgDecTime,
    double avgSecScore,
    double avgAttackRate,
  ) {
    final recommendations = <String>[];

    if (avgSecScore < 70) {
      recommendations.add('⚠️ Security Score Below 70: Consider stronger encryption algorithms');
    }

    if (avgAttackRate > 30) {
      recommendations.add('🔴 High Attack Success Rate: Review encryption implementation and add additional security layers');
    }

    if (avgEncTime > 1000) {
      recommendations.add('⏱️ High Encryption Time: Consider optimizing encryption performance for better user experience');
    }

    if (avgEncTime < 10) {
      recommendations.add('🔍 Very Fast Encryption: Verify encryption strength - extremely fast encryption may indicate weak security');
    }

    if (avgSecScore >= 90 && avgAttackRate < 10) {
      recommendations.add('✅ Excellent Security: Your encryption implementation shows strong resistance to attacks');
    }

    if (avgEncTime >= 10 && avgEncTime <= 100 && avgSecScore >= 80) {
      recommendations.add('⚡ Optimal Balance: Good balance between security and performance');
    }

    if (recommendations.isEmpty) {
      recommendations.add('📊 Results within normal parameters. Continue monitoring security metrics.');
    }

    return recommendations;
  }

  /// Analyze encryption algorithm strengths
  AlgorithmAnalysis analyzeAlgorithm(String algorithm) {
    switch (algorithm) {
      case 'AES':
        return AlgorithmAnalysis(
          algorithm: algorithm,
          securityLevel: 'High',
          performance: 'Excellent',
          strengths: ['Industry standard', 'Fast', 'Well-tested', 'Hardware acceleration'],
          weaknesses: ['Symmetric key management', 'Key distribution'],
          recommendedUse: 'General purpose encryption, file encryption, secure communications',
          keySize: '128/192/256 bits',
        );
      
      case 'Hybrid AES + ECC':
        return AlgorithmAnalysis(
          algorithm: algorithm,
          securityLevel: 'Very High',
          performance: 'Good',
          strengths: ['Combines symmetric and asymmetric', 'Forward secrecy', 'Key exchange security'],
          weaknesses: ['More complex', 'Slower than pure AES'],
          recommendedUse: 'Secure messaging, key exchange, high-security applications',
          keySize: 'AES 256-bit + ECC 256-bit',
        );
      
      case 'Homomorphic':
        return AlgorithmAnalysis(
          algorithm: algorithm,
          securityLevel: 'High',
          performance: 'Poor',
          strengths: ['Computation on encrypted data', 'Privacy preserving'],
          weaknesses: ['Very slow', 'Large ciphertext', 'Complex implementation'],
          recommendedUse: 'Privacy-preserving computation, cloud computing',
          keySize: 'Variable (typically 2048+ bits)',
        );
      
      case 'ABE':
        return AlgorithmAnalysis(
          algorithm: algorithm,
          securityLevel: 'High',
          performance: 'Moderate',
          strengths: ['Fine-grained access control', 'Policy-based encryption'],
          weaknesses: ['Complex key management', 'Computational overhead'],
          recommendedUse: 'Access control systems, document protection',
          keySize: 'Variable based on attributes',
        );
      
      case 'RSA':
        return AlgorithmAnalysis(
          algorithm: algorithm,
          securityLevel: 'High',
          performance: 'Poor',
          strengths: ['Asymmetric', 'Digital signatures', 'Key exchange'],
          weaknesses: ['Slow', 'Large keys needed', 'Quantum vulnerable'],
          recommendedUse: 'Digital signatures, key exchange, small data encryption',
          keySize: '2048/3072/4096 bits',
        );
      
      case 'Custom':
        return AlgorithmAnalysis(
          algorithm: algorithm,
          securityLevel: 'Unknown',
          performance: 'Variable',
          strengths: ['Tailored to specific needs', 'Potentially fast'],
          weaknesses: ['Unproven security', 'Implementation errors possible'],
          recommendedUse: 'Experimental, educational purposes',
          keySize: 'Variable',
        );
      
      default:
        return AlgorithmAnalysis(
          algorithm: algorithm,
          securityLevel: 'Unknown',
          performance: 'Unknown',
          strengths: ['Analysis not available'],
          weaknesses: ['Analysis not available'],
          recommendedUse: 'Analysis not available',
          keySize: 'Unknown',
        );
    }
  }

  /// Calculate risk assessment
  RiskAssessment calculateRisk({
    required double attackSuccessRate,
    required String encryptionAlgorithm,
    required double encryptionTime,
  }) {
    String riskLevel;
    List<String> riskFactors = [];
    List<String> mitigations = [];

    // Determine risk level
    if (attackSuccessRate >= 70) {
      riskLevel = 'Critical';
      riskFactors.add('High attack success rate (${attackSuccessRate.toInt()}%)');
    } else if (attackSuccessRate >= 40) {
      riskLevel = 'High';
      riskFactors.add('Moderate attack success rate (${attackSuccessRate.toInt()}%)');
    } else if (attackSuccessRate >= 20) {
      riskLevel = 'Medium';
      riskFactors.add('Some attack vulnerability detected');
    } else {
      riskLevel = 'Low';
    }

    // Algorithm-specific risks
    if (encryptionAlgorithm == 'Custom') {
      riskFactors.add('Custom encryption algorithm (unverified security)');
      mitigations.add('Have custom algorithm reviewed by security experts');
    }

    if (encryptionTime < 10) {
      riskFactors.add('Unusually fast encryption may indicate weak security');
      mitigations.add('Verify encryption algorithm strength and key size');
    }

    if (encryptionAlgorithm == 'RSA' && encryptionTime < 100) {
      riskFactors.add('RSA encryption completed too quickly (possible weak key)');
      mitigations.add('Ensure RSA key size is at least 2048 bits');
    }

    // General mitigations
    if (attackSuccessRate > 0) {
      mitigations.addAll([
        'Implement additional security layers (authentication, integrity checks)',
        'Use secure key management practices',
        'Regular security audits and penetration testing',
        'Monitor for attack patterns in production',
      ]);
    }

    return RiskAssessment(
      riskLevel: riskLevel,
      riskFactors: riskFactors,
      mitigations: mitigations,
      overallScore: _calculateRiskScore(attackSuccessRate, encryptionAlgorithm),
    );
  }

  double _calculateRiskScore(double attackSuccessRate, String algorithm) {
    double score = 100 - attackSuccessRate;
    
    // Adjust based on algorithm
    switch (algorithm) {
      case 'AES':
        score += 10; // Bonus for proven algorithm
        break;
      case 'Custom':
        score -= 20; // Penalty for unproven algorithm
        break;
      case 'RSA':
        score -= 5; // Small penalty for quantum vulnerability
        break;
    }
    
    return max(0, min(100, score));
  }
}

class BenchmarkReport {
  final int totalTests;
  final double averageEncryptionTime;
  final double averageDecryptionTime;
  final double averageSecurityScore;
  final double averageAttackSuccessRate;
  final String bestSecurityAlgorithm;
  final String fastestAlgorithm;
  final List<String> recommendations;

  BenchmarkReport({
    required this.totalTests,
    required this.averageEncryptionTime,
    required this.averageDecryptionTime,
    required this.averageSecurityScore,
    required this.averageAttackSuccessRate,
    required this.bestSecurityAlgorithm,
    required this.fastestAlgorithm,
    required this.recommendations,
  });

  factory BenchmarkReport.empty() {
    return BenchmarkReport(
      totalTests: 0,
      averageEncryptionTime: 0,
      averageDecryptionTime: 0,
      averageSecurityScore: 0,
      averageAttackSuccessRate: 0,
      bestSecurityAlgorithm: 'N/A',
      fastestAlgorithm: 'N/A',
      recommendations: ['No test data available'],
    );
  }
}

class AlgorithmAnalysis {
  final String algorithm;
  final String securityLevel;
  final String performance;
  final List<String> strengths;
  final List<String> weaknesses;
  final String recommendedUse;
  final String keySize;

  AlgorithmAnalysis({
    required this.algorithm,
    required this.securityLevel,
    required this.performance,
    required this.strengths,
    required this.weaknesses,
    required this.recommendedUse,
    required this.keySize,
  });
}

class RiskAssessment {
  final String riskLevel;
  final List<String> riskFactors;
  final List<String> mitigations;
  final double overallScore;

  RiskAssessment({
    required this.riskLevel,
    required this.riskFactors,
    required this.mitigations,
    required this.overallScore,
  });
}