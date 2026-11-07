import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/incident_card.dart';

// Home screen showing greetings, issue reporting banner, summary cards, and recent reports
// Features tailored experiences for Students (reporting focus) and Campus Staff (resolution focus)
class HomeScreen extends StatefulWidget {
  final VoidCallback? onReportTap;
  final VoidCallback? onSeeAllReports;
  final Function(IncidentModel)? onIncidentTap;

  const HomeScreen({
    super.key,
    this.onReportTap,
    this.onSeeAllReports,
    this.onIncidentTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Selected campus block for staff filtering ('All', 'Leadership Center', etc.)
  String _selectedBlock = 'All';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final incidentProvider = Provider.of<IncidentProvider>(context);

    final user = authProvider.currentUser;
    final isStaff = user?.isStaff ?? false;
    final userName = user?.name.split(' ').first ?? 'Amina';
    final userProfileImage = user?.profileImage;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section (Greeting, role badge, notification bell, avatar)
              _buildHeader(userName, isStaff, userProfileImage),
              const SizedBox(height: 20),

              // Action Banner: Reporting for Students vs Resolution Hub for Staff
              if (isStaff)
                _buildStaffActionBanner(context)
              else
                _buildStudentReportBanner(context),
              const SizedBox(height: 24),

              // Campus Block Quick Filter (Only for Staff to filter by building/hub)
              if (isStaff) ...[
                _buildCampusBlockFilter(incidentProvider),
                const SizedBox(height: 24),
              ],

              // Report Summary Section (Adjusted counters for student vs staff)
              _buildReportSummarySection(context, incidentProvider, isStaff),
              const SizedBox(height: 24),

              // Recent Reports Section (With block-filter for staff)
              _buildRecentReportsSection(
                  context, incidentProvider, isStaff, _selectedBlock),
            ],
          ),
        ),
      ),
    );
  }

  // Top header with user greeting, staff indicator, notification bell, and avatar
  Widget _buildHeader(String userName, bool isStaff, String? profileImage) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting texts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Hello, $userName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 22)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Help make our campus safer.\nReport issues and track their resolution.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        // Notification Bell Icon with unread badge
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppTheme.textPrimary,
                  size: 24,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryLight,
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: ClipOval(
            child: profileImage != null && profileImage.isNotEmpty
                ? Image.network(
                    profileImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      color: AppTheme.primary,
                      size: 26,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: AppTheme.primary,
                    size: 26,
                  ),
          ),
        ),
      ],
    );
  }

  // Student reporting banner matching Screenshot 1
  Widget _buildStudentReportBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF5E4AE3), Color(0xFF7A68EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E4AE3).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'See an issue\non campus?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Report it and help improve\nour learning environment.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),

          // Action button inside banner
          GestureDetector(
            onTap: widget.onReportTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Report an Issue',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.primary,
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Staff Action Banner tailored for operations and resolution desk
  Widget _buildStaffActionBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF4A69BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Staff Resolution Desk',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Review incoming student reports, track repairs by campus block, and update statuses to keep ALU facilities operating smoothly.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          // Action button to open resolution queue
          GestureDetector(
            onTap: widget.onSeeAllReports,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    color: Color(0xFF2C3E50),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Manage Resolution Queue',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF2C3E50),
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Interactive Campus Block Filter for Staff
  Widget _buildCampusBlockFilter(IncidentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.apartment_rounded, color: AppTheme.primary, size: 18),
            SizedBox(width: 6),
            Text(
              'Filter by Campus Hub',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
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
                selectedColor: AppTheme.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.borderColor,
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

  // Report Summary horizontal cards
  Widget _buildReportSummarySection(
      BuildContext context, IncidentProvider provider, bool isStaff) {
    return Column(
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isStaff ? 'Campus Incident Summary' : 'Report Summary',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: widget.onSeeAllReports,
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 4 Summary statistic cards
        Row(
          children: [
            // Total / My Reports
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.description_rounded,
                iconColor: const Color(0xFF6C5CE7),
                bgColor: const Color(0xFFF3F0FF),
                count: provider.totalCount,
                label: isStaff ? 'Total Reports' : 'My Reports',
              ),
            ),
            const SizedBox(width: 10),

            // In Progress
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.access_time_filled_rounded,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                count: provider.inProgressCount,
                label: 'In Progress',
              ),
            ),
            const SizedBox(width: 10),

            // Resolved
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF16A34A),
                bgColor: const Color(0xFFECFDF5),
                count: provider.resolvedCount,
                label: 'Resolved',
              ),
            ),
            const SizedBox(width: 10),

            // Submitted / Needs Review
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.error_rounded,
                iconColor: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFFF1F2),
                count: provider.submittedCount,
                label: isStaff ? 'Pending' : 'Submitted',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Individual summary statistic card
  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Recent Reports vertical list
  Widget _buildRecentReportsSection(BuildContext context,
      IncidentProvider provider, bool isStaff, String selectedBlock) {
    final displayedList = isStaff && selectedBlock != 'All'
        ? provider.searchAndFilter(block: selectedBlock)
        : provider.recentIncidents;

    return Column(
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isStaff ? 'Campus Incident Queue' : 'Recent Reports',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: widget.onSeeAllReports,
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // List of Incident Cards
        if (displayedList.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Text(
              isStaff
                  ? 'No reports found for $selectedBlock.'
                  : 'No incident reports yet.',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedList.length,
            itemBuilder: (context, index) {
              final incident = displayedList[index];
              return IncidentCard(
                incident: incident,
                onTap: () {
                  if (widget.onIncidentTap != null) {
                    widget.onIncidentTap!(incident);
                  }
                },
              );
            },
          ),
      ],
    );
  }
}
