import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// Reusable badge to display incident status (Submitted, In Progress, Resolved)
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (status) {
      case 'In Progress':
        bg = AppTheme.statusInProgressBg;
        text = AppTheme.statusInProgressText;
        break;
      case 'Resolved':
        bg = AppTheme.statusResolvedBg;
        text = AppTheme.statusResolvedText;
        break;
      case 'Submitted':
      default:
        bg = AppTheme.statusSubmittedBg;
        text = AppTheme.statusSubmittedText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
