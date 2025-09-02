import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/cyber_card.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
import '../services/error_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.surfaceDark,
      ),
      body: SingleChildScrollView(
        padding: AppConfig.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildAppearanceSettings(),
            const SizedBox(height: 24),
            _buildSecuritySettings(),
            const SizedBox(height: 24),
            _buildPerformanceSettings(),
            const SizedBox(height: 24),
            _buildAdvancedSettings(),
            const SizedBox(height: 24),
            _buildDataSettings(),
            const SizedBox(height: 24),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Settings',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Configure your cybersecurity lab experience',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Appearance', Icons.palette),
              const SizedBox(height: 16),
              
              // Dark Mode Toggle
              _buildSettingTile(
                title: 'Dark Mode',
                subtitle: 'Use dark theme for better visibility',
                trailing: Switch(
                  value: appState.isDarkMode,
                  onChanged: (value) {
                    appState.setDarkMode(value);
                    _notificationService.showToast(
                      message: value ? 'Dark mode enabled' : 'Light mode enabled',
                      type: NotificationType.success,
                    );
                  },
                ),
              ),
              
              const Divider(),
              
              // Animation Settings
              _buildSettingTile(
                title: 'Enable Animations',
                subtitle: 'Show smooth transitions and effects',
                trailing: Switch(
                  value: appState.enableAnimations,
                  onChanged: appState.setEnableAnimations,
                ),
              ),
              
              const Divider(),
              
              // Glow Effects
              _buildSettingTile(
                title: 'Glow Effects',
                subtitle: 'Enable cyberpunk-style glowing elements',
                trailing: Switch(
                  value: appState.enableGlowEffects,
                  onChanged: appState.setEnableGlowEffects,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecuritySettings() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Security', Icons.security),
              const SizedBox(height: 16),
              
              // Auto-clear sensitive data
              _buildSettingTile(
                title: 'Auto-clear Sensitive Data',
                subtitle: 'Automatically clear uploaded code after session',
                trailing: Switch(
                  value: appState.autoClearSensitiveData,
                  onChanged: appState.setAutoClearSensitiveData,
                ),
              ),
              
              const Divider(),
              
              // Session timeout
              _buildSettingTile(
                title: 'Session Timeout',
                subtitle: 'Automatically logout after inactivity',
                trailing: DropdownButton<Duration>(
                  value: appState.sessionTimeout,
                  onChanged: appState.setSessionTimeout,
                  items: const [
                    DropdownMenuItem(
                      value: Duration(minutes: 30),
                      child: Text('30 minutes'),
                    ),
                    DropdownMenuItem(
                      value: Duration(hours: 1),
                      child: Text('1 hour'),
                    ),
                    DropdownMenuItem(
                      value: Duration(hours: 2),
                      child: Text('2 hours'),
                    ),
                    DropdownMenuItem(
                      value: Duration(hours: 4),
                      child: Text('4 hours'),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Validation strictness
              _buildSettingTile(
                title: 'Code Validation',
                subtitle: 'Strictness level for uploaded code validation',
                trailing: DropdownButton<String>(
                  value: appState.validationStrictness,
                  onChanged: appState.setValidationStrictness,
                  items: const [
                    DropdownMenuItem(value: 'lenient', child: Text('Lenient')),
                    DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                    DropdownMenuItem(value: 'strict', child: Text('Strict')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceSettings() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Performance', Icons.speed),
              const SizedBox(height: 16),
              
              // Max simulation steps
              _buildSettingTile(
                title: 'Max Simulation Steps',
                subtitle: 'Limit simulation complexity for performance',
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: TextEditingController(
                      text: appState.maxSimulationSteps.toString(),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) {
                      final steps = int.tryParse(value);
                      if (steps != null && steps > 0) {
                        appState.setMaxSimulationSteps(steps);
                      }
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ),
              
              const Divider(),
              
              // Enable performance monitoring
              _buildSettingTile(
                title: 'Performance Monitoring',
                subtitle: 'Track app performance metrics',
                trailing: Switch(
                  value: appState.enablePerformanceMonitoring,
                  onChanged: appState.setEnablePerformanceMonitoring,
                ),
              ),
              
              const Divider(),
              
              // Memory management
              _buildSettingTile(
                title: 'Aggressive Memory Management',
                subtitle: 'Clear unused data more frequently',
                trailing: Switch(
                  value: appState.aggressiveMemoryManagement,
                  onChanged: appState.setAggressiveMemoryManagement,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedSettings() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Advanced Features', Icons.tune),
              const SizedBox(height: 16),
              
              // Quantum resistance
              _buildSettingTile(
                title: 'Quantum Resistance',
                subtitle: 'Enable post-quantum cryptography features',
                trailing: Switch(
                  value: appState.enableQuantumResistance,
                  onChanged: appState.setEnableQuantumResistance,
                ),
              ),
              
              const Divider(),
              
              // ML Detection
              _buildSettingTile(
                title: 'ML-based Detection',
                subtitle: 'Use machine learning for threat detection',
                trailing: Switch(
                  value: appState.enableMLDetection,
                  onChanged: appState.setEnableMLDetection,
                ),
              ),
              
              const Divider(),
              
              // Blockchain Analysis
              _buildSettingTile(
                title: 'Blockchain Analysis',
                subtitle: 'Enable blockchain security analysis tools',
                trailing: Switch(
                  value: appState.enableBlockchainAnalysis,
                  onChanged: appState.setEnableBlockchainAnalysis,
                ),
              ),
              
              const Divider(),
              
              // Real-time monitoring
              _buildSettingTile(
                title: 'Real-time Monitoring',
                subtitle: 'Monitor simulations in real-time',
                trailing: Switch(
                  value: appState.enableRealTimeMonitoring,
                  onChanged: appState.setEnableRealTimeMonitoring,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataSettings() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Data Management', Icons.storage),
          const SizedBox(height: 16),
          
          // Clear cache
          _buildSettingTile(
            title: 'Clear Cache',
            subtitle: 'Remove temporary files and cached data',
            trailing: ElevatedButton(
              onPressed: _clearCache,
              child: const Text('Clear'),
            ),
          ),
          
          const Divider(),
          
          // Export data
          _buildSettingTile(
            title: 'Export Data',
            subtitle: 'Export analytics and benchmark data',
            trailing: ElevatedButton(
              onPressed: _exportData,
              child: const Text('Export'),
            ),
          ),
          
          const Divider(),
          
          // Reset settings
          _buildSettingTile(
            title: 'Reset Settings',
            subtitle: 'Reset all settings to default values',
            trailing: ElevatedButton(
              onPressed: _resetSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
              ),
              child: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('About', Icons.info),
          const SizedBox(height: 16),
          
          _buildInfoTile('Version', AppConfig.appVersion),
          _buildInfoTile('Build Date', '2024-01-15'),
          _buildInfoTile('Developer', 'Cybersecurity Lab Team'),
          _buildInfoTile('License', 'MIT License'),
          
          const SizedBox(height: 16),
          
          // View error logs
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _viewErrorLogs,
              child: const Text('View Error Logs'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await _notificationService.showConfirmation(
      title: 'Clear Cache',
      message: 'This will remove all temporary files and cached data. Continue?',
      type: NotificationType.warning,
    );

    if (confirmed) {
      // Clear cache logic here
      _notificationService.showToast(
        message: 'Cache cleared successfully',
        type: NotificationType.success,
      );
    }
  }

  Future<void> _exportData() async {
    try {
      final analyticsData = AnalyticsService().exportAnalyticsData();
      
      // In a real app, this would trigger a file download
      _notificationService.showToast(
        message: 'Data exported successfully',
        type: NotificationType.success,
      );
    } catch (e) {
      _notificationService.showToast(
        message: 'Failed to export data: $e',
        type: NotificationType.error,
      );
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await _notificationService.showConfirmation(
      title: 'Reset Settings',
      message: 'This will reset all settings to their default values. This action cannot be undone.',
      confirmText: 'Reset',
      type: NotificationType.error,
    );

    if (confirmed) {
      final appState = context.read<AppState>();
      appState.resetToDefaults();
      
      _notificationService.showToast(
        message: 'Settings reset to defaults',
        type: NotificationType.success,
      );
    }
  }

  void _viewErrorLogs() {
    final errorHistory = ErrorService.instance.errorHistory;
    
    _notificationService.showDialog(
      title: 'Error Logs',
      message: errorHistory.isEmpty
          ? 'No errors recorded in this session.'
          : '${errorHistory.length} errors recorded. Check console for details.',
      actions: [
        DialogAction(
          label: 'Clear Logs',
          onPressed: () {
            ErrorService.instance.clearErrorHistory();
            _notificationService.showToast(
              message: 'Error logs cleared',
              type: NotificationType.success,
            );
          },
        ),
        DialogAction(
          label: 'Close',
          isPrimary: true,
        ),
      ],
    );
  }
} 