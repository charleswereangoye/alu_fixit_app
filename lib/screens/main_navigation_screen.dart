import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'home/home_screen.dart';
import 'report/report_incident_screen.dart';
import 'details/incident_details_screen.dart';
import 'reports/my_reports_screen.dart';
import 'profile/profile_screen.dart';

// Main navigation screen hosting the bottom navigation bar and tabs
// Adapts dynamically: Student mode (with center + button) and Staff mode (all items uniform size)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isStaff = auth.currentUser?.isStaff ?? false;

    // List of screens for each bottom navigation tab
    final List<Widget> screens = [
      HomeScreen(
        onReportTap: () => _navigateToReportTab(),
        onSeeAllReports: () => setState(() => _currentIndex = 1),
        onIncidentTap: (incident) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IncidentDetailsScreen(incident: incident),
            ),
          );
        },
      ),
      // Reports / Resolution Desk tab
      const MyReportsScreen(),
      // Profile tab
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.borderColor)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: isStaff
              ? [
                  // Hub tab
                  _buildNavItem(
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    label: 'Hub',
                  ),

                  // Queue tab
                  _buildNavItem(
                    index: 1,
                    icon: Icons.assignment_outlined,
                    label: 'Queue',
                  ),

                  // Profile tab
                  _buildNavItem(
                    index: 2,
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                  ),
                ]
              : [
                  // Student: Home tab
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: 'Home',
                  ),

                  // Student: Reports tab
                  _buildNavItem(
                    index: 1,
                    icon: Icons.assignment_outlined,
                    label: 'Reports',
                  ),

                  // Student: Elevated Center "+" Report Button (Screenshot 1)
                  GestureDetector(
                    onTap: _navigateToReportTab,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  // Student: Profile tab
                  _buildNavItem(
                    index: 2,
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                  ),
                ],
        ),
      ),
    );
  }

  // Navigate to Report Incident Screen
  void _navigateToReportTab() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportIncidentScreen(),
      ),
    );
  }

  // Helper widget for bottom nav items with uniform styling
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primary : AppTheme.textMuted,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
