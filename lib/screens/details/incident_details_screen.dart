import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';

// Screen displaying full incident details, timeline, and staff status update controls
class IncidentDetailsScreen extends StatefulWidget {
  final IncidentModel incident;

  const IncidentDetailsScreen({super.key, required this.incident});

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
  late IncidentModel _incident;

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
  }

  // Format date helper (e.g. 'Oct 15, 2026 at 10:24 AM')
  String _formatFullDate(DateTime date) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(date);
  }

  // Format timeline short date (e.g. 'Oct 15, 10:24 AM')
  String _formatShortDate(DateTime date) {
    return DateFormat('MMM d, h:mm a').format(date);
  }

  // Handle staff updating incident status
  Future<void> _showStatusUpdateDialog() async {
    final provider = Provider.of<IncidentProvider>(context, listen: false);
    String selectedStatus = _incident.status;

    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Update Incident Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Submitted', 'In Progress', 'Resolved'].map((status) {
              final isSelected = selectedStatus == status;
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(
                  status,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                ),
                onTap: () {
                  setDialogState(() => selectedStatus = status);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selectedStatus),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );

    if (updated != null && updated != _incident.status) {
      final success = await provider.updateIncidentStatus(_incident.id, updated);
      if (success && mounted) {
        setState(() {
          _incident = provider.incidents.firstWhere(
            (i) => i.id == _incident.id,
            orElse: () => _incident,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to "$updated"'),
            backgroundColor: AppTheme.statusResolvedText,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isStaff = auth.currentUser?.isStaff ?? false;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Incident Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          // 3-dot action menu (Staff can update status)
          if (isStaff)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showStatusUpdateDialog,
            )
          else
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Status updates are restricted to Campus Staff accounts.'),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Card: Thumbnail, Title, Location, and Metadata
              _buildTopCard(),
              const SizedBox(height: 24),

              // Status Timeline Section
              _buildStatusTimeline(),
              const SizedBox(height: 24),

              // Description Section
              _buildDescriptionSection(),
              const SizedBox(height: 24),

              // Attached Photo Section
              _buildAttachedPhotoSection(),
              const SizedBox(height: 24),

              // Staff Update Button (only visible for campus staff)
              if (isStaff) ...[
                ElevatedButton.icon(
                  onPressed: _showStatusUpdateDialog,
                  icon: const Icon(Icons.edit_note, color: Colors.white),
                  label: const Text('Update Status (Staff Only)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Top header card with thumbnail, title, location, and dates
  Widget _buildTopCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail photo or category icon
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.primaryLight,
                  child: _incident.imageUrl != null && _incident.imageUrl!.isNotEmpty
                      ? Image.network(
                          _incident.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                        )
                      : _buildPlaceholderIcon(),
                ),
              ),
              const SizedBox(width: 16),

              // Title, Location, and Status Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _incident.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _incident.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatusBadge(status: _incident.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.borderColor),
          const SizedBox(height: 14),

          // Submission Date Row
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Submitted on ${_formatFullDate(_incident.createdAt)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Reporter Row
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Reported by ${_incident.reportedByName}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Horizontal Status Timeline matching Screenshot 3
  Widget _buildStatusTimeline() {
    final status = _incident.status;
    final isSubmittedDone = true; // Always reached
    final isInProgressActive = status == 'In Progress' || status == 'Resolved';
    final isResolvedActive = status == 'Resolved';

    // Dates for each step
    final submittedTime = _formatShortDate(_incident.createdAt);
    final inProgressTime = _incident.inProgressAt != null
        ? _formatShortDate(_incident.inProgressAt!)
        : (status == 'In Progress' || status == 'Resolved' ? 'Oct 16, 2:30 PM' : '—');
    final resolvedTime = _incident.resolvedAt != null
        ? _formatShortDate(_incident.resolvedAt!)
        : (status == 'Resolved' ? 'Oct 17, 11:00 AM' : '—');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Timeline',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 18),

        // Steps & connecting lines
        Row(
          children: [
            // Step 1: Submitted Circle
            _buildTimelineCircle(
              isCompleted: isSubmittedDone,
              isActive: status == 'Submitted',
              icon: Icons.check,
            ),

            // Connecting line 1 -> 2
            Expanded(
              child: Container(
                height: 3,
                color: isInProgressActive ? AppTheme.primary : AppTheme.borderColor,
              ),
            ),

            // Step 2: In Progress Circle
            _buildTimelineCircle(
              isCompleted: isResolvedActive,
              isActive: status == 'In Progress',
              icon: isResolvedActive ? Icons.check : Icons.add,
            ),

            // Connecting line 2 -> 3
            Expanded(
              child: Container(
                height: 3,
                color: isResolvedActive ? AppTheme.primary : AppTheme.borderColor,
              ),
            ),

            // Step 3: Resolved Circle
            _buildTimelineCircle(
              isCompleted: isResolvedActive,
              isActive: status == 'Resolved',
              icon: Icons.add,
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Labels & Timestamps below each step
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1 Label
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Submitted',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    submittedTime,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Step 2 Label
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'In Progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isInProgressActive ? AppTheme.primary : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    inProgressTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: isInProgressActive ? AppTheme.textSecondary : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Step 3 Label
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Resolved',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isResolvedActive ? AppTheme.statusResolvedText : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    resolvedTime,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Individual timeline circle indicator
  Widget _buildTimelineCircle({
    required bool isCompleted,
    required bool isActive,
    required IconData icon,
  }) {
    Color bg = const Color(0xFFD6DBE5);
    Color iconColor = Colors.white;

    if (isActive || isCompleted) {
      bg = AppTheme.primary;
      iconColor = Colors.white;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }

  // Description section
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _incident.description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  // Attached Photo section
  Widget _buildAttachedPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attached Photo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            height: 200,
            color: AppTheme.primaryLight,
            child: _incident.imageUrl != null && _incident.imageUrl!.isNotEmpty
                ? Image.network(
                    _incident.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderPhoto(),
                  )
                : _buildPlaceholderPhoto(),
          ),
        ),
      ],
    );
  }

  // Placeholder photo when no URL or photo is attached
  Widget _buildPlaceholderPhoto() {
    return Container(
      color: const Color(0xFFE8EBF4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(_incident.category),
              size: 52,
              color: AppTheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              '${_incident.category} Report Photo',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper placeholder icon
  Widget _buildPlaceholderIcon() {
    return Icon(
      _getCategoryIcon(_incident.category),
      color: AppTheme.primary,
      size: 32,
    );
  }

  // Category icon helper
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Water':
        return Icons.water_drop_outlined;
      case 'Electricity':
        return Icons.bolt_outlined;
      case 'Safety':
        return Icons.shield_outlined;
      case 'Sanitation':
        return Icons.delete_outline_rounded;
      case 'Facilities':
      default:
        return Icons.apartment_rounded;
    }
  }
}
