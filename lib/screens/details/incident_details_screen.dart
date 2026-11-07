import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';

// Screen displaying full incident details, timeline, campus block routing, and staff resolution controls
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

  // Fast one-tap status change for staff
  Future<void> _quickUpdateStatus(String newStatus) async {
    final provider = Provider.of<IncidentProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await provider.updateIncidentStatus(
      _incident.id,
      newStatus,
      staffName: auth.currentUser?.name,
    );

    if (success && mounted) {
      setState(() {
        _incident = provider.incidents.firstWhere(
          (i) => i.id == _incident.id,
          orElse: () => _incident,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status marked as "$newStatus" ✓'),
          backgroundColor: AppTheme.statusResolvedText,
        ),
      );
    }
  }

  // Handle staff updating incident status with optional resolution notes
  Future<void> _showStatusUpdateDialog() async {
    final provider = Provider.of<IncidentProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    String selectedStatus = _incident.status;
    final noteController =
        TextEditingController(text: _incident.resolutionNotes ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Update Incident Status & Notes'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Status:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                ...['Submitted', 'In Progress', 'Resolved'].map((status) {
                  final isSelected = selectedStatus == status;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: Text(
                      status,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                    ),
                    onTap: () {
                      setDialogState(() => selectedStatus = status);
                    },
                  );
                }),
                const SizedBox(height: 12),
                const Text(
                  'Technician / Resolution Notes (Optional):',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Technician dispatched to Rwanda Lab — repaired socket.',
                    hintStyle: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.borderColor),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save & Update'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.updateIncidentStatus(
        _incident.id,
        selectedStatus,
        resolutionNotes: noteController.text.trim(),
        staffName: auth.currentUser?.name,
      );

      if (success && mounted) {
        setState(() {
          _incident = provider.incidents.firstWhere(
            (i) => i.id == _incident.id,
            orElse: () => _incident,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to "$selectedStatus"!'),
            backgroundColor: AppTheme.statusResolvedText,
          ),
        );
      }
    }
  }

  // Delete report workflow
  Future<void> _deleteIncident() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Incident Report?'),
        content: const Text(
          'Are you sure you want to remove this incident report? This will delete it permanently from Firestore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<IncidentProvider>(context, listen: false);
      await provider.deleteIncident(_incident.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report deleted from Firestore.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isStaff = user?.isStaff ?? false;
    final isReporter = user?.uid == _incident.reportedByUid;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Incident Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onSelected: (val) {
              if (val == 'delete') {
                _deleteIncident();
              } else if (val == 'status') {
                _showStatusUpdateDialog();
              }
            },
            itemBuilder: (context) => [
              if (isStaff)
                const PopupMenuItem(
                  value: 'status',
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Update Status'),
                    ],
                  ),
                ),
              if (isReporter || isStaff)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          color: Color(0xFFEF4444), size: 20),
                      SizedBox(width: 8),
                      Text('Delete Report',
                          style: TextStyle(color: Color(0xFFEF4444))),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Card: Thumbnail, Title, Location, Routing Metadata
              _buildTopCard(),
              const SizedBox(height: 20),

              // Staff Control Action Box (When logged in as staff)
              if (isStaff) ...[
                _buildStaffActionBox(),
                const SizedBox(height: 20),
              ],

              // Resolution Notes Section (If added by staff)
              if (_incident.resolutionNotes != null &&
                  _incident.resolutionNotes!.isNotEmpty) ...[
                _buildResolutionNotesCard(),
                const SizedBox(height: 20),
              ],

              // Status Timeline Section
              _buildStatusTimeline(),
              const SizedBox(height: 24),

              // Description Section
              _buildDescriptionSection(),
              const SizedBox(height: 24),

              // Attached Photo Section
              _buildAttachedPhotoSection(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  // Top header card with thumbnail, title, location, and campus routing
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
                  child: _incident.imageUrl != null &&
                          _incident.imageUrl!.isNotEmpty
                      ? Image.network(
                          _incident.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderIcon(),
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

          // Campus Routing Row (Block and Responsible Staff Department)
          Row(
            children: [
              const Icon(
                Icons.apartment_rounded,
                size: 16,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_incident.campusBlock} • ${_incident.assignedDepartment}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

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

  // Staff Quick Action Control Box
  Widget _buildStaffActionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Campus Staff Action Control',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick 1-tap Status Buttons
          Row(
            children: [
              if (_incident.status == 'Submitted')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _quickUpdateStatus('In Progress'),
                    icon: const Icon(Icons.bolt, size: 16),
                    label: const Text('Start Work'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              if (_incident.status == 'Submitted') const SizedBox(width: 10),
              if (_incident.status != 'Resolved')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _quickUpdateStatus('Resolved'),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Mark Resolved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Full update status & add technician notes button
          OutlinedButton.icon(
            onPressed: _showStatusUpdateDialog,
            icon: const Icon(Icons.edit_note, size: 18),
            label: const Text('Update Status & Add Resolution Notes'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Resolution Notes Card
  Widget _buildResolutionNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_outlined, color: Color(0xFF059669), size: 18),
              SizedBox(width: 8),
              Text(
                'Staff Resolution Note',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF047857),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _incident.resolutionNotes!,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF065F46),
              height: 1.4,
            ),
          ),
          if (_incident.assignedStaffName != null) ...[
            const SizedBox(height: 6),
            Text(
              'Handled by: ${_incident.assignedStaffName}',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF047857),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Horizontal Status Timeline matching Screenshot 3
  Widget _buildStatusTimeline() {
    final status = _incident.status;
    const isSubmittedDone = true;
    final isInProgressActive = status == 'In Progress' || status == 'Resolved';
    final isResolvedActive = status == 'Resolved';

    final submittedDate = _formatShortDate(_incident.createdAt);
    final inProgressDate = _incident.inProgressAt != null
        ? _formatShortDate(_incident.inProgressAt!)
        : (isInProgressActive ? 'In Progress' : 'Pending');
    final resolvedDate = _incident.resolvedAt != null
        ? _formatShortDate(_incident.resolvedAt!)
        : (isResolvedActive ? 'Resolved' : 'Pending');

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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildTimelineCircle(
                    isCompleted: isSubmittedDone,
                    isActive: status == 'Submitted',
                    icon: Icons.check,
                  ),
                  const SizedBox(height: 8),
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
                    submittedDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 2,
              color: isInProgressActive
                  ? AppTheme.primary
                  : const Color(0xFFD6DBE5),
            ),
            Expanded(
              child: Column(
                children: [
                  _buildTimelineCircle(
                    isCompleted: isResolvedActive,
                    isActive: status == 'In Progress',
                    icon: isResolvedActive ? Icons.check : Icons.autorenew,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'In Progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    inProgressDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 2,
              color:
                  isResolvedActive ? AppTheme.primary : const Color(0xFFD6DBE5),
            ),
            Expanded(
              child: Column(
                children: [
                  _buildTimelineCircle(
                    isCompleted: isResolvedActive,
                    isActive: isResolvedActive,
                    icon: Icons.check,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Resolved',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    resolvedDate,
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
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderPhoto(),
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
