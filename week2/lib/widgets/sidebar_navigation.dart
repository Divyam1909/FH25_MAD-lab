import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_state.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../config/app_config.dart';
import '../services/analytics_service.dart';

class SidebarNavigation extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  
  const SidebarNavigation({
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return AnimatedContainer(
          duration: AppConfig.animationDuration,
          width: isCollapsed ? 80 : AppConfig.sidebarWidth,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            border: Border(
              right: BorderSide(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: appState.enableGlowEffects
                ? [AppTheme.defaultShadow]
                : null,
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(appState),
              
              Divider(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                thickness: 1,
              ),
              
              // Navigation Items
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      _buildNavItem(
                        context: context,
                        icon: Icons.upload_file,
                        title: 'Upload Code',
                        subtitle: 'Upload algorithms',
                        index: 0,
                        isSelected: appState.currentIndex == 0,
                        onTap: () {
                          appState.setCurrentIndex(0);
                          AnalyticsService().trackUserAction('navigate_to_upload');
                        },
                        appState: appState,
                      ),
                      _buildNavItem(
                        context: context,
                        icon: Icons.play_circle,
                        title: 'Test Code',
                        subtitle: 'Run simulations',
                        index: 1,
                        isSelected: appState.currentIndex == 1,
                        onTap: () {
                          appState.setCurrentIndex(1);
                          AnalyticsService().trackUserAction('navigate_to_test');
                        },
                        appState: appState,
                      ),
                      _buildNavItem(
                        context: context,
                        icon: Icons.analytics,
                        title: 'Metrics',
                        subtitle: 'View analytics',
                        index: 2,
                        isSelected: appState.currentIndex == 2,
                        onTap: () {
                          appState.setCurrentIndex(2);
                          AnalyticsService().trackUserAction('navigate_to_metrics');
                        },
                        appState: appState,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Divider for additional items
                      if (!isCollapsed)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Additional navigation items
                      _buildNavItem(
                        context: context,
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'App configuration',
                        index: -1,
                        isSelected: false,
                        onTap: () {
                          AppRoutes.pushNamed(AppRoutes.settings);
                          AnalyticsService().trackUserAction('navigate_to_settings');
                        },
                        appState: appState,
                      ),
                      _buildNavItem(
                        context: context,
                        icon: Icons.help_outline,
                        title: 'Help',
                        subtitle: 'Documentation',
                        index: -2,
                        isSelected: false,
                        onTap: () {
                          AppRoutes.pushNamed(AppRoutes.help);
                          AnalyticsService().trackUserAction('navigate_to_help');
                        },
                        appState: appState,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer
              _buildFooter(appState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppState appState) {
    return AnimatedContainer(
      duration: AppConfig.animationDuration,
      padding: EdgeInsets.all(isCollapsed ? 16 : 20),
      child: Column(
        children: [
          // Logo with glow effect
          Container(
            padding: EdgeInsets.all(isCollapsed ? 8 : 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: appState.enableGlowEffects
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.security,
              size: isCollapsed ? 24 : 32,
              color: AppTheme.primaryGreen,
            ),
          ),
          
          if (!isCollapsed) ...[
            const SizedBox(height: 16),
            Text(
              'CYBER LAB',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppTheme.primaryGreen,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: -0.2, end: 0),
            
            const SizedBox(height: 8),
            Text(
              'Security Testing Suite',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    required AppState appState,
  }) {
    final hasNotification = _hasNotificationForItem(index, appState);
    
    return AnimatedContainer(
      duration: AppConfig.animationDuration,
      margin: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppTheme.primaryGreen.withOpacity(0.15)
            : null,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.5),
                width: 1,
              )
            : null,
        boxShadow: isSelected && appState.enableGlowEffects
            ? [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 12 : 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                // Icon with notification badge
                Stack(
                  children: [
                    Icon(
                      icon,
                      color: isSelected 
                          ? AppTheme.primaryGreen 
                          : AppTheme.textSecondary,
                      size: isCollapsed ? 20 : 24,
                    ),
                    if (hasNotification)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.errorRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isSelected 
                                ? AppTheme.primaryGreen 
                                : AppTheme.textPrimary,
                            fontWeight: isSelected 
                                ? FontWeight.bold 
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Selection indicator
                if (isSelected && !isCollapsed)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppState appState) {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 12 : 20),
      child: Column(
        children: [
          if (!isCollapsed) ...[
            Divider(
              color: AppTheme.primaryGreen.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
          ],
          
          // System status
          Row(
            mainAxisAlignment: isCollapsed 
                ? MainAxisAlignment.center 
                : MainAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  shape: BoxShape.circle,
                  boxShadow: appState.enableGlowEffects
                      ? [
                          BoxShadow(
                            color: AppTheme.successGreen.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.2, 1.2),
                    duration: 1000.ms,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1.0, 1.0),
                    duration: 1000.ms,
                  ),
              
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Online',
                        style: TextStyle(
                          color: AppTheme.successGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'All services operational',
                        style: TextStyle(
                          color: AppTheme.textDisabled,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          if (!isCollapsed) ...[
            const SizedBox(height: 16),
            
            // Quick stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat(
                  'Tests',
                  appState.benchmarkResults.length.toString(),
                  Icons.play_circle,
                ),
                _buildQuickStat(
                  'Logs',
                  appState.logs.length.toString(),
                  Icons.list_alt,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Version info
            Text(
              'v${AppConfig.appVersion}',
              style: TextStyle(
                color: AppTheme.textDisabled,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.primaryGreen,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textDisabled,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  bool _hasNotificationForItem(int index, AppState appState) {
    switch (index) {
      case 1: // Test screen
        return appState.isRunningTest;
      case 2: // Metrics screen
        return appState.benchmarkResults.isNotEmpty;
      default:
        return false;
    }
  }
}