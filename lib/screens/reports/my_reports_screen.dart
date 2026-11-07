import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/incident_card.dart';
import '../details/incident_details_screen.dart';

// Screen displaying user's reports, statistics, and status filter tabs
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  // Selected filter tab ('All', 'Submitted', 'In Progress', 'Resolved')
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Submitted', 'In Progress', 'Resolved'];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final incidentProvider = Provider.of<IncidentProvider>(context);

    final user = auth.currentUser;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Amina Hassan';
    final userRole = user?.role.isNotEmpty == true ? user!.role : 'Student';
    final department = user?.department.isNotEmpty == true ? user!.department : 'Computer Science';
    final campus = user?.campus.isNotEmpty == true ? user!.campus : 'Kigali, Rwanda';

    // Get incidents filtered by selected tab
    final displayedIncidents = incidentProvider.filterByStatus(_selectedFilter);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'My Reports',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
            onPressed: () => _showSettingsMenu(context, auth),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Header Card
              _buildProfileHeaderCard(
                name: userName,
                role: userRole,
                department: department,
                campus: campus,
              ),
              const SizedBox(height: 20),

              // Report Statistic Cards (3 cards: Total Reports, In Progress, Resolved)
              _buildStatisticCards(incidentProvider),
              const SizedBox(height: 20),

              // Filter Tabs (All, Submitted, In Progress, Resolved)
              _buildFilterTabs(),
              const SizedBox(height: 18),

              // Filtered List of Incidents
              _buildIncidentList(displayedIncidents),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Header Card matching Screenshot 4
  Widget _buildProfileHeaderCard({
    required String name,
    required String role,
    required String department,
    required String campus,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          // User Avatar Image
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryLight,
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  color: AppTheme.primary,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User info and role badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Role Badge (Student or Staff)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Department row
                Row(
                  children: [
                    const Icon(
                      Icons.apartment_rounded,
                      size: 15,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        department,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Campus location row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      campus,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3 Statistic Cards: Total Reports, In Progress, Resolved
  Widget _buildStatisticCards(IncidentProvider provider) {
    return Row(
      children: [
        // Total Reports
        Expanded(
          child: _buildStatItem(
            count: provider.totalCount,
            label: 'Total Reports',
            color: const Color(0xFF5E4AE3),
            bgColor: const Color(0xFFF3F0FF),
          ),
        ),
        const SizedBox(width: 12),

        // In Progress
        Expanded(
          child: _buildStatItem(
            count: provider.inProgressCount,
            label: 'In Progress',
            color: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 12),

        // Resolved
        Expanded(
          child: _buildStatItem(
            count: provider.resolvedCount,
            label: 'Resolved',
            color: const Color(0xFF16A34A),
            bgColor: const Color(0xFFECFDF5),
          ),
        ),
      ],
    );
  }

  // Individual statistic card
  Widget _buildStatItem({
    required int count,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal Filter Tabs
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : const Color(0xFFF1F3FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // List of incidents filtered by selected tab
  Widget _buildIncidentList(List<IncidentModel> incidents) {
    if (incidents.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No "$_selectedFilter" reports found.',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final incident = incidents[index];
        return IncidentCard(
          incident: incident,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IncidentDetailsScreen(incident: incident),
              ),
            );
          },
        );
      },
    );
  }

  // Settings / Account sheet
  void _showSettingsMenu(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: AppTheme.primary),
                title: Text(auth.currentUser?.name ?? 'User Profile'),
                subtitle: Text(auth.currentUser?.email ?? ''),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  auth.signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
