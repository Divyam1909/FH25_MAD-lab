import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class EncryptionService {
  final Random _random = Random.secure();

  /// Encrypt a message using the specified algorithm
  Future<String> encrypt(
    String message,
    String algorithm,
    String? customCode,
  ) async {
    switch (algorithm) {
      case 'AES':
        return _encryptAES(message);
      case 'Hybrid AES + ECC':
        return _encryptHybridAESECC(message);
      case 'Homomorphic':
        return _encryptHomomorphic(message);
      case 'ABE':
        return _encryptABE(message);
      case 'RSA':
        return _encryptRSA(message);
      case 'Custom':
        return _encryptCustom(message, customCode);
      default:
        return _encryptAES(message);
    }
  }

  /// Decrypt a message using the specified algorithm
  Future<String> decrypt(
    String encryptedMessage,
    String algorithm,
    String? customCode,
  ) async {
    switch (algorithm) {
      case 'AES':
        return _decryptAES(encryptedMessage);
      case 'Hybrid AES + ECC':
        return _decryptHybridAESECC(encryptedMessage);
      case 'Homomorphic':
        return _decryptHomomorphic(encryptedMessage);
      case 'ABE':
        return _decryptABE(encryptedMessage);
      case 'RSA':
        return _decryptRSA(encryptedMessage);
      case 'Custom':
        return _decryptCustom(encryptedMessage, customCode);
      default:
        return _decryptAES(encryptedMessage);
    }
  }

  /// AES Encryption Implementation
  String _encryptAES(String message) {
    try {
      final key = _generateRandomBytes(32); // 256-bit key
      final iv = _generateRandomBytes(16); // 128-bit IV
      
      final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

      final keyParam = KeyParameter(key);
      final params = PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(keyParam, iv),
        null,
      );

      paddedCipher.init(true, params);

      final messageBytes = utf8.encode(message);
      final encryptedBytes = paddedCipher.process(Uint8List.fromList(messageBytes));
      
      // Combine IV + encrypted data for storage
      final combined = Uint8List(iv.length + encryptedBytes.length);
      combined.setRange(0, iv.length, iv);
      combined.setRange(iv.length, combined.length, encryptedBytes);
      
      return base64.encode(combined);
    } catch (e) {
      return 'AES_ENCRYPT_ERROR: $e';
    }
  }

  String _decryptAES(String encryptedMessage) {
    try {
      final combined = base64.decode(encryptedMessage);
      
      final iv = combined.sublist(0, 16);
      final encryptedBytes = combined.sublist(16);
      
      // For demo, use a fixed key (in real scenarios, key management is crucial)
      final key = _generateFixedKey();
      
      final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

      final keyParam = KeyParameter(key);
      final params = PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(keyParam, iv),
        null,
      );

      paddedCipher.init(false, params);

      final decryptedBytes = paddedCipher.process(encryptedBytes);
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      return 'AES_DECRYPT_ERROR: $e';
    }
  }

  /// Hybrid AES + ECC Encryption
  String _encryptHybridAESECC(String message) {
    try {
      // Simulate ECC key exchange for AES key derivation
      final eccPrivateKey = _generateRandomBytes(32);
      final aesKey = sha256.convert(eccPrivateKey).bytes.sublist(0, 32);
      
      final iv = _generateRandomBytes(16);
      
      final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

      final keyParam = KeyParameter(Uint8List.fromList(aesKey));
      final params = PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(keyParam, iv),
        null,
      );

      paddedCipher.init(true, params);

      final messageBytes = utf8.encode(message);
      final encryptedBytes = paddedCipher.process(Uint8List.fromList(messageBytes));
      
      // Combine ECC public key simulation + IV + encrypted data
      final combined = Uint8List(64 + iv.length + encryptedBytes.length);
      combined.setRange(0, 32, eccPrivateKey); // Simulated public key part 1
      combined.setRange(32, 64, _generateRandomBytes(32)); // Simulated public key part 2
      combined.setRange(64, 64 + iv.length, iv);
      combined.setRange(64 + iv.length, combined.length, encryptedBytes);
      
      return 'HYBRID:${base64.encode(combined)}';
    } catch (e) {
      return 'HYBRID_ENCRYPT_ERROR: $e';
    }
  }

  String _decryptHybridAESECC(String encryptedMessage) {
    try {
      final data = encryptedMessage.replaceFirst('HYBRID:', '');
      final combined = base64.decode(data);
      
      final eccKey = combined.sublist(0, 32);
      final iv = combined.sublist(64, 80);
      final encryptedBytes = combined.sublist(80);
      
      final aesKey = sha256.convert(eccKey).bytes.sublist(0, 32);
      
      final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

      final keyParam = KeyParameter(Uint8List.fromList(aesKey));
      final params = PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(keyParam, iv),
        null,
      );

      paddedCipher.init(false, params);

      final decryptedBytes = paddedCipher.process(encryptedBytes);
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      return 'HYBRID_DECRYPT_ERROR: $e';
    }
  }

  /// Homomorphic Encryption (Simplified Paillier-like)
  String _encryptHomomorphic(String message) {
    try {
      // Simplified homomorphic encryption for demonstration
      final messageBytes = utf8.encode(message);
      final n = BigInt.from(65537); // Small public key for demo
      final g = n + BigInt.one;
      
      final encrypted = <String>[];
      for (final byte in messageBytes) {
        final m = BigInt.from(byte);
        final r = BigInt.from(_random.nextInt(1000) + 1);
        
        // Simplified Paillier: c = g^m * r^n mod n^2
        final gPowM = g.modPow(m, n * n);
        final rPowN = r.modPow(n, n * n);
        final c = (gPowM * rPowN) % (n * n);
        
        encrypted.add(c.toString());
      }
      
      return 'HOMOMORPHIC:${encrypted.join(',')}';
    } catch (e) {
      return 'HOMOMORPHIC_ENCRYPT_ERROR: $e';
    }
  }

  String _decryptHomomorphic(String encryptedMessage) {
    try {
      final data = encryptedMessage.replaceFirst('HOMOMORPHIC:', '');
      final encryptedValues = data.split(',');
      
      final n = BigInt.from(65537);
      final lambda = n - BigInt.one; // Simplified lambda
      
      final decrypted = <int>[];
      for (final encVal in encryptedValues) {
        final c = BigInt.parse(encVal);
        
        // Simplified Paillier decryption
        final u = c.modPow(lambda, n * n);
        final l = (u - BigInt.one) ~/ n;
        final m = (l * lambda.modInverse(n)) % n;
        
        decrypted.add(m.toInt());
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      return 'HOMOMORPHIC_DECRYPT_ERROR: $e';
    }
  }

  /// Attribute-Based Encryption (Simplified)
  String _encryptABE(String message) {
    try {
      // Simplified ABE with attributes
      final attributes = ['role:admin', 'dept:security', 'level:high'];
      final policy = 'role:admin AND dept:security';
      
      // Use attribute hash as key derivation
      final attributeHash = sha256.convert(utf8.encode(attributes.join('|'))).bytes;
      final key = attributeHash.sublist(0, 32);
      final iv = _generateRandomBytes(16);
      
      final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

      final keyParam = KeyParameter(Uint8List.fromList(key));
      final params = PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(keyParam, iv),
        null,
      );

      paddedCipher.init(true, params);

      final messageBytes = utf8.encode(message);
      final encryptedBytes = paddedCipher.process(Uint8List.fromList(messageBytes));
      
      final policyBytes = utf8.encode(policy);
      final combined = Uint8List(policyBytes.length + 1 + iv.length + encryptedBytes.length);
      combined[0] = policyBytes.length;
      combined.setRange(1, 1 + policyBytes.length, policyBytes);
      combined.setRange(1 + policyBytes.length, 1 + policyBytes.length + iv.length, iv);
      combined.setRange(1 + policyBytes.length + iv.length, combined.length, encryptedBytes);
      
      return 'ABE:${base64.encode(combined)}';
    } catch (e) {
      return 'ABE_ENCRYPT_ERROR: $e';
    }
  }

  String _decryptABE(String encryptedMessage) {
    try {
      final data = encryptedMessage.replaceFirst('ABE:', '');
      final combined = base64.decode(data);
      
      final policyLength = combined[0];
      final policy = utf8.decode(combined.sublist(1, 1 + policyLength));
      final iv = combined.sublist(1 + policyLength, 1 + policyLength + 16);
      final encryptedBytes = combined.sublist(1 + policyLength + 16);
      
      // Simulate attribute verification
      final userAttributes = ['role:admin', 'dept:security', 'level:high'];
      if (!_checkPolicy(policy, userAttributes)) {
        return 'ABE_ACCESS_DENIED: Insufficient attributes';
      }
      
      final attributeHash = sha256.convert(utf8.encode(userAttributes.join('|'))).bytes;
      final key = attributeHash.sublist(0, 32);
      
      final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

      final keyParam = KeyParameter(Uint8List.fromList(key));
      final params = PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(keyParam, iv),
        null,
      );

      paddedCipher.init(false, params);

      final decryptedBytes = paddedCipher.process(encryptedBytes);
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      return 'ABE_DECRYPT_ERROR: $e';
    }
  }

  /// RSA Encryption
  String _encryptRSA(String message) {
    try {
      // Generate RSA key pair (simplified for demo)
      final keyGen = RSAKeyGenerator();
      final secureRandom = FortunaRandom();
      secureRandom.seed(KeyParameter(_generateRandomBytes(32)));
      
      keyGen.init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
        secureRandom,
      ));
      
      final keyPair = keyGen.generateKeyPair();
      final publicKey = keyPair.publicKey as RSAPublicKey;
      
      final cipher = RSAEngine();
      cipher.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
      
      final messageBytes = utf8.encode(message);
      
      // RSA can only encrypt data smaller than key size, so we'll use chunks
      final encryptedChunks = <String>[];
      const chunkSize = 245; // For 2048-bit RSA
      
      for (int i = 0; i < messageBytes.length; i += chunkSize) {
        final end = (i + chunkSize < messageBytes.length) 
            ? i + chunkSize 
            : messageBytes.length;
        final chunk = messageBytes.sublist(i, end);
        final encryptedChunk = cipher.process(Uint8List.fromList(chunk));
        encryptedChunks.add(base64.encode(encryptedChunk));
      }
      
      // Store public key with encrypted data for decryption
      final pubKeyData = '${publicKey.modulus}:${publicKey.exponent}';
      
      return 'RSA:$pubKeyData|${encryptedChunks.join('|')}';
    } catch (e) {
      return 'RSA_ENCRYPT_ERROR: $e';
    }
  }

  String _decryptRSA(String encryptedMessage) {
    try {
      final parts = encryptedMessage.replaceFirst('RSA:', '').split('|');
  final encryptedChunks = parts.sublist(1);
      
      // For demo, generate a matching private key (in practice, this would be stored securely)
  // parsed key parts are available if needed for real decryption
  // final modulus = BigInt.parse(keyParts[0]);
  // final publicExponent = BigInt.parse(keyParts[1]);
      
      // This is a simplified approach - in reality, you'd need the actual private key
      return 'RSA_DECRYPT_SIMULATED: ${encryptedChunks.length} chunks processed';
    } catch (e) {
      return 'RSA_DECRYPT_ERROR: $e';
    }
  }

  /// Custom Algorithm Encryption
  String _encryptCustom(String message, String? customCode) {
    if (customCode == null) {
      return 'CUSTOM_ERROR: No custom code provided';
    }
    
    try {
      // Simple custom encryption for demo (Caesar cipher variant)
      const shift = 13;
      final encrypted = message.split('').map((char) {
        final code = char.codeUnitAt(0);
        return String.fromCharCode((code + shift) % 256);
      }).join('');
      
      return 'CUSTOM:${base64.encode(utf8.encode(encrypted))}';
    } catch (e) {
      return 'CUSTOM_ENCRYPT_ERROR: $e';
    }
  }

  String _decryptCustom(String encryptedMessage, String? customCode) {
    if (customCode == null) {
      return 'CUSTOM_ERROR: No custom code provided';
    }
    
    try {
      final data = encryptedMessage.replaceFirst('CUSTOM:', '');
      final encrypted = utf8.decode(base64.decode(data));
      
      const shift = 13;
      final decrypted = encrypted.split('').map((char) {
        final code = char.codeUnitAt(0);
        return String.fromCharCode((code - shift) % 256);
      }).join('');
      
      return decrypted;
    } catch (e) {
      return 'CUSTOM_DECRYPT_ERROR: $e';
    }
  }

  // Helper methods
  Uint8List _generateRandomBytes(int length) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  Uint8List _generateFixedKey() {
    // Fixed key for demo purposes - in production, use proper key management
    return Uint8List.fromList(List.generate(32, (i) => i * 7 % 256));
  }

  bool _checkPolicy(String policy, List<String> attributes) {
    // Simplified policy check - supports AND operations
    final requiredAttribs = policy.split(' AND ').map((s) => s.trim()).toList();
    return requiredAttribs.every((required) => attributes.contains(required));
  }
}
