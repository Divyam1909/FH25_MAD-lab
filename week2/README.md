# Cybersecurity Lab - Flutter Web Application

A comprehensive Flutter web application designed for cybersecurity education and testing. This lab provides a platform for experimenting with various encryption algorithms, simulating cyberattacks, and analyzing security metrics.

## Features

### 🔐 Encryption Algorithms
- **AES (Advanced Encryption Standard)** - Industry standard symmetric encryption
- **Hybrid AES + ECC** - Combines symmetric and elliptic curve cryptography
- **Homomorphic Encryption** - Allows computation on encrypted data
- **Attribute-Based Encryption (ABE)** - Policy-based access control
- **RSA** - Asymmetric encryption for digital signatures and key exchange
- **Custom Algorithms** - Upload and test your own encryption implementations

### 🎯 Cyberattack Simulations
- **Man-in-the-Middle (MITM)** - Network interception attacks
- **Replay Attack** - Message replay vulnerabilities
- **Brute Force Attack** - Key space exhaustion attacks
- **Denial of Service (DoS)** - System overload simulation
- **Ciphertext Manipulation** - Padding oracle and bit-flipping attacks
- **Custom Attacks** - Upload and test your own attack algorithms

### 📊 Advanced Analytics
- **Real-time Metrics** - Performance and security scoring
- **Benchmark Reports** - Comprehensive analysis of test results
- **Risk Assessment** - Security vulnerability evaluation
- **Multi-Agent Simulation** - Network transmission with intermediate nodes
- **Interactive Visualizations** - Charts and graphs for data analysis

## Screenshots

### Dashboard Overview
Modern, dark-themed interface with cybersecurity aesthetic featuring neon green accents.

### Upload Section
- Upload custom encryption algorithms (Dart files)
- Upload custom attack scripts
- Code validation and preview
- Syntax highlighting for better readability

### Testing Environment
- Multi-agent network simulation
- Real-time attack execution
- Detailed logging and monitoring
- Performance benchmarking

### Metrics & Analytics
- Security score tracking
- Performance comparison charts
- Algorithm analysis
- Risk assessment reports

## Architecture

```
lib/
├── main.dart                 # Application entry point
├── models/
│   └── app_state.dart       # Application state management
├── screens/
│   ├── dashboard_screen.dart # Main dashboard
│   ├── upload_screen.dart   # Code upload interface
│   ├── test_screen.dart     # Testing environment
│   └── metrics_screen.dart  # Analytics dashboard
├── services/
│   ├── encryption_service.dart # Encryption algorithms
│   ├── attack_service.dart    # Attack simulations
│   └── benchmark_service.dart # Performance metrics
├── widgets/
│   ├── cyber_card.dart       # Styled card component
│   ├── code_viewer.dart      # Code display widget
│   ├── sidebar_navigation.dart # Navigation menu
│   └── simulation_visualizer.dart # Network visualization
└── utils/
    └── demo_data.dart        # Sample data and test cases
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Web browser (Chrome, Firefox, Safari, Edge)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd cybersecurity-lab
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the application**
```bash
flutter run -d chrome
```

The application will open in your default web browser at `http://localhost:8080`.

### Building for Production

```bash
flutter build web
```

The built files will be available in the `build/web/` directory.

## Usage Guide

### 1. Upload Custom Code

#### Encryption Algorithm Format
Your custom encryption Dart file should export a class with `encrypt()` and `decrypt()` methods:

```dart
class CustomEncryption {
  static String encrypt(String message) {
    // Your encryption logic
    return encryptedMessage;
  }
  
  static String decrypt(String encryptedMessage) {
    // Your decryption logic
    return originalMessage;
  }
}
```

#### Attack Algorithm Format
Your custom attack Dart file should export a class with an `attack()` method:

```dart
class CustomAttack {
  static AttackResult attack(String encryptedData) {
    // Your attack logic
    return AttackResult(
      success: true/false,
      confidence: 0.0-1.0,
      details: ['Attack step 1', 'Attack step 2'],
    );
  }
}
```

### 2. Running Tests

1. Select encryption algorithm (built-in or uploaded custom)
2. Select attack type (built-in or uploaded custom)
3. Enter test message
4. Click "Run Simulation"
5. Monitor real-time logs and network visualization
6. Review results and metrics

### 3. Analyzing Results

The metrics section provides:
- **Performance Charts** - Encryption/decryption time comparisons
- **Security Scores** - Algorithm strength ratings
- **Risk Assessment** - Vulnerability analysis
- **Recommendations** - Security improvement suggestions

## Encryption Algorithms Details

### AES (Advanced Encryption Standard)
- **Key Size**: 256-bit
- **Block Size**: 128-bit
- **Mode**: CBC with PKCS7 padding
- **Strength**: High (industry standard)
- **Performance**: Excellent

### Hybrid AES + ECC
- **Components**: AES-256 + ECC-256
- **Key Exchange**: Elliptic Curve Diffie-Hellman
- **Strength**: Very High
- **Use Case**: Secure messaging, key exchange

### Homomorphic Encryption
- **Type**: Simplified Paillier-like
- **Key Size**: Variable (demo uses smaller keys)
- **Special Feature**: Computation on encrypted data
- **Performance**: Poor (computationally intensive)

### Attribute-Based Encryption (ABE)
- **Type**: Key-Policy ABE
- **Attributes**: Role, department, clearance level
- **Access Control**: Policy-based decryption
- **Use Case**: Document protection, access control

### RSA
- **Key Size**: 2048-bit
- **Type**: Asymmetric encryption
- **Strength**: High (but quantum-vulnerable)
- **Use Case**: Digital signatures, key exchange

## Attack Simulations

### Man-in-the-Middle (MITM)
- **Target**: Network communication
- **Detection**: Pattern analysis, ECB mode weaknesses
- **Success Factors**: Encryption mode, key reuse

### Replay Attack
- **Target**: Message authenticity
- **Protection**: Timestamp, nonce validation
- **Success Factors**: Lack of freshness guarantees

### Brute Force
- **Target**: Encryption keys
- **Method**: Key space exhaustion
- **Success Factors**: Key length, algorithm strength

### Denial of Service (DoS)
- **Target**: System availability
- **Method**: Resource exhaustion
- **Metrics**: Request rate, system capacity

### Ciphertext Manipulation
- **Target**: Data integrity
- **Methods**: Bit flipping, padding oracle
- **Protection**: Message authentication codes

## Security Metrics

### Security Score Calculation
```
Base Score: 100
- Attack Success Rate (0-100)
- Fast Encryption Penalty (if < 10ms): -5
- Slow Encryption Penalty (if > 1000ms): -10
+ Optimal Range Bonus (10-500ms): +5
Final Score: max(0, min(100, calculated_score))
```

### Risk Assessment Levels
- **Low Risk** (0-20% attack success): Green
- **Medium Risk** (21-40% attack success): Yellow
- **High Risk** (41-70% attack success): Orange
- **Critical Risk** (71-100% attack success): Red

## Performance Benchmarks

### Typical Performance (on modern hardware):
- **AES**: 50-150ms encryption, 40-120ms decryption
- **RSA**: 200-700ms encryption, 150-450ms decryption
- **Hybrid AES+ECC**: 100-300ms encryption, 80-230ms decryption
- **Homomorphic**: 800-2000ms encryption, 600-1400ms decryption

## Educational Use Cases

### Cryptography Courses
- Compare different encryption algorithms
- Understand attack vectors and defenses
- Analyze performance vs security trade-offs

### Security Training
- Simulate real-world attack scenarios
- Learn vulnerability assessment
- Practice secure coding principles

### Research Projects
- Test novel encryption algorithms
- Benchmark security implementations
- Analyze attack effectiveness

## Troubleshooting

### Common Issues

1. **File Upload Fails**
   - Ensure file is valid Dart code
   - Check file size (< 1MB recommended)
   - Verify required methods are present

2. **Simulation Errors**
   - Check browser console for detailed errors
   - Ensure message is not empty
   - Try with built-in algorithms first

3. **Performance Issues**
   - Use Chrome for best performance
   - Reduce message size for testing
   - Clear browser cache if needed

### Browser Compatibility
- **Chrome**: Full support (recommended)
- **Firefox**: Full support
- **Safari**: Full support
- **Edge**: Full support

## Contributing

### Development Setup
```bash
# Install Flutter
flutter --version

# Install dependencies
flutter pub get

# Run in development mode
flutter run -d chrome --web-port 8080
```

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex algorithms
- Maintain consistent formatting

## Security Considerations

### Important Notes
⚠️ **This is an educational tool**. The implementations are for learning purposes and should not be used in production environments without proper security review.

### What This Tool Does NOT Do
- Provide production-ready encryption
- Replace professional security audits
- Guarantee security of custom algorithms
- Protect against all attack vectors

### Best Practices Demonstrated
- Key derivation functions
- Proper initialization vectors
- Padding schemes (PKCS7)
- Attack surface analysis
- Performance monitoring

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the excellent framework
- PointyCastle for cryptographic primitives
- FL Chart for beautiful visualizations
- Open source security community

## Support

For issues, questions, or contributions:
1. Check existing issues in the repository
2. Create a new issue with detailed description
3. Include steps to reproduce any bugs
4. Provide browser and Flutter version information

---

**Disclaimer**: This educational tool is designed for learning cybersecurity concepts. Always consult security professionals for production implementations.