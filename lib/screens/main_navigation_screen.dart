import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'home/home_screen.dart';
import 'report/report_incident_screen.dart';
import 'details/incident_details_screen.dart';
import 'reports/my_reports_screen.dart';
import 'profile/profile_screen.dart';

// Main navigation screen hosting the bottom navigation bar and tabs
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
      // Reports tab (Screenshot 4)
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
          children: [
            // Home tab
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
            ),

            // Reports tab
            _buildNavItem(
              index: 1,
              icon: Icons.assignment_outlined,
              label: 'Reports',
            ),

            // Elevated Center "+" Report Button
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

            // Profile tab
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

  // Helper widget for bottom nav items
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
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
