import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../models/app_state.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/cyber_card.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import 'upload_screen.dart';
import 'test_screen.dart';
import 'metrics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final NotificationService _notificationService = NotificationService();
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _trackScreenView();
    _checkSessionStatus();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppConfig.animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _fadeController.forward();
  }

  void _trackScreenView() {
    AnalyticsService().trackScreenView('dashboard');
  }

  void _checkSessionStatus() {
    final appState = context.read<AppState>();
    if (appState.needsSessionRefresh) {
      _notificationService.showToast(
        message: 'Session refreshed',
        type: NotificationType.info,
      );
      appState.refreshSession();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Row(
            children: [
              // Sidebar Navigation
              AnimatedContainer(
                duration: AppConfig.animationDuration,
                width: _isSidebarCollapsed ? 80 : AppConfig.sidebarWidth,
                child: SidebarNavigation(
                  isCollapsed: _isSidebarCollapsed,
                  onToggleCollapse: () {
                    setState(() {
                      _isSidebarCollapsed = !_isSidebarCollapsed;
                    });
                  },
                ),
              ),
              
              // Main Content Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: appState.enableGlowEffects 
                        ? AppTheme.cyberGradient 
                        : null,
                    color: appState.enableGlowEffects 
                        ? null 
                        : AppTheme.backgroundDark,
                  ),
                  child: Column(
                    children: [
                      // Top App Bar
                      _buildTopAppBar(appState),
                      
                      // Content Area
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildCurrentScreen(appState),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopAppBar(AppState appState) {
    final currentRoute = AppRoutes.routeInfo.entries
        .where((entry) => entry.value.title.toLowerCase().contains(
              _getScreenName(appState.currentIndex).toLowerCase()))
        .firstOrNull;
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: appState.enableGlowEffects
            ? [AppTheme.defaultShadow]
            : null,
      ),
      child: Row(
        children: [
          // Sidebar toggle
          IconButton(
            onPressed: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
            icon: Icon(
              _isSidebarCollapsed ? Icons.menu : Icons.menu_open,
              color: AppTheme.primaryGreen,
            ),
            tooltip: _isSidebarCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
          ),
          
          const SizedBox(width: 16),
          
          // Current screen info
          if (currentRoute != null) ...[
            Icon(
              currentRoute.value.icon,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentRoute.value.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentRoute.value.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          
          const Spacer(),
          
          // Status indicators
          _buildStatusIndicators(appState),
          
          const SizedBox(width: 16),
          
          // Action buttons
          _buildActionButtons(appState),
        ],
      ),
    );
  }

  Widget _buildStatusIndicators(AppState appState) {
    return Row(
      children: [
        // Running test indicator
        if (appState.isRunningTest)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.warningOrange,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppTheme.warningOrange),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Running Test',
                  style: TextStyle(
                    color: AppTheme.warningOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(width: 12),
        
        // Feature status indicators
        Row(
          children: [
            _buildFeatureIndicator(
              'ML',
              appState.enableMLDetection,
              'Machine Learning Detection',
            ),
            const SizedBox(width: 8),
            _buildFeatureIndicator(
              'QC',
              appState.enableQuantumResistance,
              'Quantum Cryptography',
            ),
            const SizedBox(width: 8),
            _buildFeatureIndicator(
              'BC',
              appState.enableBlockchainAnalysis,
              'Blockchain Analysis',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureIndicator(String label, bool enabled, String tooltip) {
    return Tooltip(
      message: '$tooltip: ${enabled ? 'Enabled' : 'Disabled'}',
      child: Container(
        width: 32,
        height: 20,
        decoration: BoxDecoration(
          color: enabled 
              ? AppTheme.primaryGreen.withOpacity(0.2)
              : AppTheme.textDisabled.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? AppTheme.primaryGreen : AppTheme.textDisabled,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: enabled ? AppTheme.primaryGreen : AppTheme.textDisabled,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppState appState) {
    return Row(
      children: [
        // Settings button
        IconButton(
          onPressed: () => AppRoutes.pushNamed(AppRoutes.settings),
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
        ),
        
        // Help button
        IconButton(
          onPressed: () => AppRoutes.pushNamed(AppRoutes.help),
          icon: const Icon(Icons.help_outline),
          tooltip: 'Help & Documentation',
        ),
        
        // Theme toggle
        IconButton(
          onPressed: () {
            appState.setDarkMode(!appState.isDarkMode);
            _notificationService.showToast(
              message: appState.isDarkMode 
                  ? 'Dark mode enabled' 
                  : 'Light mode enabled',
              type: NotificationType.success,
            );
          },
          icon: Icon(
            appState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          tooltip: appState.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        ),
      ],
    );
  }

  Widget _buildCurrentScreen(AppState appState) {
    Widget screen;
    
    switch (appState.currentIndex) {
      case 0:
        screen = const UploadScreen();
        break;
      case 1:
        screen = const TestScreen();
        break;
      case 2:
        screen = const MetricsScreen();
        break;
      default:
        screen = _buildWelcomeScreen();
    }

    // Add animations if enabled
    if (appState.enableAnimations) {
      return screen
          .animate()
          .fadeIn(duration: AppConfig.animationDuration)
          .slideX(begin: 0.1, end: 0, duration: AppConfig.animationDuration);
    }
    
    return screen;
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: AppConfig.defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome header
            Container(
              padding: const EdgeInsets.all(32),
              decoration: AppTheme.cyberCardDecoration,
              child: Column(
                children: [
                  Icon(
                    Icons.security,
                    size: 64,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to ${AppConfig.appName}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConfig.appDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickAction(
                  'Upload Code',
                  Icons.upload_file,
                  'Start by uploading your algorithms',
                  () => context.read<AppState>().setCurrentIndex(0),
                ),
                const SizedBox(width: 24),
                _buildQuickAction(
                  'Run Tests',
                  Icons.play_circle,
                  'Execute security simulations',
                  () => context.read<AppState>().setCurrentIndex(1),
                ),
                const SizedBox(width: 24),
                _buildQuickAction(
                  'View Metrics',
                  Icons.analytics,
                  'Analyze performance results',
                  () => context.read<AppState>().setCurrentIndex(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: CyberCard(
        child: SizedBox(
          width: 200,
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getScreenName(int index) {
    switch (index) {
      case 0:
        return 'Upload Code';
      case 1:
        return 'Test Code';
      case 2:
        return 'Metrics';
      default:
        return 'Dashboard';
    }
  }
}