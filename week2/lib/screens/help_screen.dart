import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../config/app_config.dart';
import '../widgets/cyber_card.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _selectedSection = 0;

  final List<HelpSection> _sections = [
    HelpSection(
      title: 'Getting Started',
      icon: Icons.play_arrow,
      content: _gettingStartedContent,
    ),
    HelpSection(
      title: 'Upload Code',
      icon: Icons.upload_file,
      content: _uploadCodeContent,
    ),
    HelpSection(
      title: 'Testing & Simulation',
      icon: Icons.play_circle,
      content: _testingContent,
    ),
    HelpSection(
      title: 'Metrics & Analytics',
      icon: Icons.analytics,
      content: _metricsContent,
    ),
    HelpSection(
      title: 'Security Features',
      icon: Icons.security,
      content: _securityFeaturesContent,
    ),
    HelpSection(
      title: 'Troubleshooting',
      icon: Icons.help_outline,
      content: _troubleshootingContent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Help & Documentation'),
        backgroundColor: AppTheme.surfaceDark,
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(
                right: BorderSide(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Documentation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _sections.length,
                    itemBuilder: (context, index) {
                      final section = _sections[index];
                      final isSelected = index == _selectedSection;
                      
                      return ListTile(
                        leading: Icon(
                          section.icon,
                          color: isSelected 
                              ? AppTheme.primaryGreen 
                              : AppTheme.textSecondary,
                        ),
                        title: Text(
                          section.title,
                          style: TextStyle(
                            color: isSelected 
                                ? AppTheme.primaryGreen 
                                : AppTheme.textSecondary,
                            fontWeight: isSelected 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: AppTheme.primaryGreen.withOpacity(0.1),
                        onTap: () {
                          setState(() {
                            _selectedSection = index;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: AppConfig.defaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(_sections[_selectedSection]),
                  const SizedBox(height: 24),
                  _sections[_selectedSection].content(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(HelpSection section) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            section.icon,
            color: AppTheme.primaryGreen,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Learn how to use ${section.title.toLowerCase()} effectively',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Content builders for each section
  static Widget _gettingStartedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentCard(
          'Welcome to Cybersecurity Lab',
          'This application provides a comprehensive platform for testing encryption algorithms and simulating cyberattacks. You can upload custom code, run simulations, and analyze security metrics.',
        ),
        const SizedBox(height: 16),
        _buildContentCard(
          'Quick Start Guide',
          '1. Navigate to "Upload Code" to upload your encryption and attack algorithms\n'
          '2. Go to "Test Code" to run simulations with your uploaded code\n'
          '3. View "Metrics" to analyze performance and security results\n'
          '4. Adjust settings in the "Settings" screen for optimal experience',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Key Features',
          [
            'Advanced encryption algorithms (AES, RSA, ECC, Post-Quantum)',
            'Sophisticated attack simulations (MITM, Replay, Brute Force)',
            'Real-time performance monitoring',
            'Machine learning-based threat detection',
            'Blockchain security analysis',
            'Interactive visualizations and charts',
          ],
        ),
      ],
    );
  }

  static Widget _uploadCodeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentCard(
          'Uploading Custom Code',
          'You can upload custom Dart files containing encryption algorithms and attack simulations. The system supports .dart, .py, .js, and .ts files.',
        ),
        const SizedBox(height: 16),
        _buildCodeExample(
          'Encryption Algorithm Example',
          '''class CustomEncryption {
  static String encrypt(String message) {
    // Your encryption logic here
    return encryptedMessage;
  }
  
  static String decrypt(String encryptedMessage) {
    // Your decryption logic here
    return decryptedMessage;
  }
}''',
        ),
        const SizedBox(height: 16),
        _buildCodeExample(
          'Attack Algorithm Example',
          '''class CustomAttack {
  static AttackResult executeAttack(String data) {
    // Your attack logic here
    return AttackResult(
      success: true,
      confidence: 0.85,
      details: ['Attack details'],
    );
  }
}''',
        ),
      ],
    );
  }

  static Widget _testingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentCard(
          'Running Simulations',
          'The testing environment allows you to run comprehensive security simulations. You can test encryption algorithms against various attack vectors and analyze the results.',
        ),
        const SizedBox(height: 16),
        _buildStepsCard(
          'Testing Process',
          [
            'Enter a message to encrypt',
            'Select encryption algorithm and attack type',
            'Configure simulation parameters',
            'Run the simulation',
            'Analyze results and logs',
          ],
        ),
        const SizedBox(height: 16),
        _buildContentCard(
          'Multi-Agent Simulation',
          'The system simulates network transmission through multiple agents, allowing you to test how your encryption performs in real-world scenarios with intermediate nodes and potential attackers.',
        ),
      ],
    );
  }

  static Widget _metricsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentCard(
          'Understanding Metrics',
          'The metrics screen provides comprehensive analysis of your encryption algorithms and attack simulations, including performance benchmarks, security scores, and detailed analytics.',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Available Metrics',
          [
            'Encryption/Decryption performance (speed, memory usage)',
            'Security strength assessment',
            'Attack success rates and confidence levels',
            'Network simulation results',
            'Comparative analysis across algorithms',
            'Historical performance trends',
          ],
        ),
      ],
    );
  }

  static Widget _securityFeaturesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentCard(
          'Security Features',
          'The application includes advanced security features to ensure safe testing and protect your code and data.',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Security Measures',
          [
            'Code validation and sandboxing',
            'Automatic sensitive data clearing',
            'Session timeout protection',
            'Secure file upload validation',
            'Error reporting without sensitive data',
            'Performance monitoring for anomaly detection',
          ],
        ),
        const SizedBox(height: 16),
        _buildContentCard(
          'Best Practices',
          'Always validate your code before uploading. Use strong, unique algorithms for testing. Monitor performance metrics to detect potential issues. Keep your testing environment updated.',
        ),
      ],
    );
  }

  static Widget _troubleshootingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentCard(
          'Common Issues',
          'If you encounter problems, check the error logs in Settings > About > View Error Logs. Most issues are related to invalid code uploads or network connectivity.',
        ),
        const SizedBox(height: 16),
        _buildStepsCard(
          'Troubleshooting Steps',
          [
            'Check that your uploaded code follows the required format',
            'Verify file size is under 10MB limit',
            'Ensure your code doesn\'t contain syntax errors',
            'Try refreshing the page if simulations fail',
            'Clear cache if experiencing performance issues',
            'Reset settings if the app behaves unexpectedly',
          ],
        ),
        const SizedBox(height: 16),
        _buildContentCard(
          'Performance Issues',
          'If the app runs slowly, try reducing the number of simulation steps, disabling real-time monitoring, or enabling aggressive memory management in settings.',
        ),
      ],
    );
  }

  static Widget _buildContentCard(String title, String content) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureCard(String title, List<String> features) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  static Widget _buildStepsCard(String title, List<String> steps) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static Widget _buildCodeExample(String title, String code) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              code,
              style: AppTheme.codeTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpSection {
  final String title;
  final IconData icon;
  final Widget Function() content;

  const HelpSection({
    required this.title,
    required this.icon,
    required this.content,
  });
} 