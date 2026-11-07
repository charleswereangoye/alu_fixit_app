import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/incident_card.dart';
import '../details/incident_details_screen.dart';

// Screen displaying reports, statistics, search, block filters, and status tabs
// For Students: Displays personal reports tracking ("My Reports", Screenshot 4)
// For Campus Staff: Functions as the "Campus Incident Queue" to review and inspect student reports
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  // Selected filter tab ('All', 'Submitted', 'In Progress', 'Resolved')
  String _selectedFilter = 'All';
  String _selectedBlock = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Submitted', 'In Progress', 'Resolved'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final incidentProvider = Provider.of<IncidentProvider>(context);

    final user = auth.currentUser;
    final isStaff = user?.isStaff ?? false;
    final userName =
        user?.name.isNotEmpty == true ? user!.name : 'Amina Hassan';
    final userRole = user?.role.isNotEmpty == true ? user!.role : 'Student';
    final department = user?.department.isNotEmpty == true
        ? user!.department
        : (isStaff
            ? 'Facilities & Operations'
            : 'BSc (Hons) in Software Engineering (BSE)');
    final campus =
        user?.campus.isNotEmpty == true ? user!.campus : 'Kigali, Rwanda';
    final profileImage = user?.profileImage;

    // Filter incidents by search query, status tab, and campus block
    final displayedIncidents = incidentProvider.searchAndFilter(
      query: _searchQuery,
      status: _selectedFilter,
      block: isStaff ? _selectedBlock : 'All',
    );

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          isStaff ? 'Campus Incident Queue' : 'My Reports',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
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
              // User Profile Header Card (Displays uploaded photo and role)
              _buildProfileHeaderCard(
                name: userName,
                role: userRole,
                department: department,
                campus: campus,
                profileImage: profileImage,
                isStaff: isStaff,
              ),
              const SizedBox(height: 20),

              // Report Statistic Cards (3 cards: Total Reports, In Progress, Resolved)
              _buildStatisticCards(incidentProvider, isStaff),
              const SizedBox(height: 18),

              // Real-Time Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isStaff
                        ? 'Search reports by title, student, or location...'
                        : 'Search reports by title, location...',
                    hintStyle: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textSecondary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),
              const SizedBox(height: 16),

              // Campus Block Filter Chips for Staff
              if (isStaff) ...[
                _buildCampusBlockFilter(incidentProvider),
                const SizedBox(height: 16),
              ],

              // Filter Tabs (All, Submitted, In Progress, Resolved)
              _buildFilterTabs(),
              const SizedBox(height: 18),

              // Filtered List of Incidents
              _buildIncidentList(displayedIncidents, isStaff),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Header Card matching Screenshot 4 with real uploaded photo
  Widget _buildProfileHeaderCard({
    required String name,
    required String role,
    required String department,
    required String campus,
    String? profileImage,
    required bool isStaff,
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
              child: profileImage != null && profileImage.isNotEmpty
                  ? (profileImage.startsWith('http')
                      ? Image.network(
                          profileImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.person,
                            color: AppTheme.primary,
                            size: 36,
                          ),
                        )
                      : Image.file(
                          File(profileImage),
                          fit: BoxFit.cover,
                        ))
                  : Image.network(
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
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isStaff
                            ? const Color(0xFFEFF6FF)
                            : AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: isStaff
                            ? Border.all(
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: TextStyle(
                          color: isStaff
                              ? const Color(0xFF2563EB)
                              : AppTheme.primary,
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
                    Icon(
                      isStaff
                          ? Icons.apartment_rounded
                          : Icons.school_outlined,
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
  Widget _buildStatisticCards(IncidentProvider provider, bool isStaff) {
    return Row(
      children: [
        // Total Reports
        Expanded(
          child: _buildStatItem(
            count: provider.totalCount,
            label: isStaff ? 'All Reports' : 'Total Reports',
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

  // Campus Block Filter Chips for Staff
  Widget _buildCampusBlockFilter(IncidentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Campus Block:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.campusBlocks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final block = provider.campusBlocks[index];
              final isSelected = _selectedBlock == block;
              return ChoiceChip(
                label: Text(block),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedBlock = block);
                  }
                },
                selectedColor: const Color(0xFF2C3E50),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF2C3E50)
                        : AppTheme.borderColor,
                  ),
                ),
                showCheckmark: false,
              );
            },
          ),
        ),
      ],
    );
  }

  // Horizontal Filter Tabs matching Screenshot 4
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        isSelected ? AppTheme.primary : AppTheme.borderColor,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Incident List
  Widget _buildIncidentList(
      List<IncidentModel> incidents, bool isStaff) {
    if (incidents.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              isStaff
                  ? 'No reports matching current filter or search.'
                  : 'No reports found.',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isStaff
                  ? 'Reports submitted by students will appear in this review queue.'
                  : 'When you submit incident reports, they will be tracked here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
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
                builder: (context) =>
                    IncidentDetailsScreen(incident: incident),
              ),
            );
          },
        );
      },
    );
  }

  // Settings menu bottom sheet
  void _showSettingsMenu(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: AppTheme.primary),
                title: Text(
                  'Switch to ${auth.currentUser?.isStaff == true ? 'Student' : 'Staff'} Mode',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Toggle role presentation for demo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  auth.toggleRole();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await auth.signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
