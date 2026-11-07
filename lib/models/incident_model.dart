// Incident model representing a reported campus issue
class IncidentModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'Facilities', 'Water', 'Electricity', 'Safety', 'Sanitation'
  final String location;
  final String? imageUrl;
  final String status; // 'Submitted', 'In Progress', 'Resolved'
  final String reportedByUid;
  final String reportedByName;
  final String reportedByEmail;
  final DateTime createdAt;
  final DateTime? inProgressAt;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final String? assignedStaffName;

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.imageUrl,
    this.status = 'Submitted',
    required this.reportedByUid,
    required this.reportedByName,
    required this.reportedByEmail,
    DateTime? createdAt,
    this.inProgressAt,
    this.resolvedAt,
    this.resolutionNotes,
    this.assignedStaffName,
  }) : createdAt = createdAt ?? DateTime.now();

  // Smart campus block detection based on location
  String get campusBlock {
    final loc = location.toLowerCase();
    if (loc.contains('leadership') || loc.contains('lab')) {
      return 'Leadership Center';
    } else if (loc.contains('social') ||
        loc.contains('cafeteria') ||
        loc.contains('dining') ||
        loc.contains('food court') ||
        loc.contains('lounge')) {
      return 'Social Commons';
    } else if (loc.contains('enterprise') ||
        loc.contains('fab lab') ||
        loc.contains('incubator') ||
        loc.contains('workstation')) {
      return 'Enterprise Commons';
    } else if (loc.contains('hostel') ||
        loc.contains('soul') ||
        loc.contains('mirror') ||
        loc.contains('residence')) {
      return 'Soul Hostels';
    } else if (loc.contains('court') ||
        loc.contains('gate') ||
        loc.contains('parking') ||
        loc.contains('security') ||
        loc.contains('ground')) {
      return 'Grounds & Security';
    }
    return 'General Campus';
  }

  // Smart routing to responsible staff department based on category and location
  String get assignedDepartment {
    switch (category) {
      case 'Water':
        return 'Facilities & Operations';
      case 'Sanitation':
        return 'Facilities & Operations';
      case 'Electricity':
        return 'Facilities / IT Support';
      case 'Safety':
        return 'Campus Safety & Security';
      case 'Facilities':
        if (location.toLowerCase().contains('lab') ||
            title.toLowerCase().contains('projector') ||
            title.toLowerCase().contains('screen') ||
            title.toLowerCase().contains('wifi')) {
          return 'IT & Technical Support';
        }
        return 'Facilities & Operations';
      default:
        return 'Campus Operations';
    }
  }

  // Convert to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'status': status,
      'reportedByUid': reportedByUid,
      'reportedByName': reportedByName,
      'reportedByEmail': reportedByEmail,
      'createdAt': createdAt.toIso8601String(),
      'inProgressAt': inProgressAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolutionNotes': resolutionNotes,
      'assignedStaffName': assignedStaffName,
    };
  }

  // Create IncidentModel from Firestore document map
  factory IncidentModel.fromMap(Map<String, dynamic> map, String id) {
    return IncidentModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Facilities',
      location: map['location'] ?? 'ALU Campus',
      imageUrl: map['imageUrl'],
      status: map['status'] ?? 'Submitted',
      reportedByUid: map['reportedByUid'] ?? '',
      reportedByName: map['reportedByName'] ?? 'Anonymous',
      reportedByEmail: map['reportedByEmail'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      inProgressAt: map['inProgressAt'] != null
          ? DateTime.tryParse(map['inProgressAt'])
          : null,
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.tryParse(map['resolvedAt'])
          : null,
      resolutionNotes: map['resolutionNotes'],
      assignedStaffName: map['assignedStaffName'],
    );
  }

  // Human-readable time ago helper (e.g. '2 hours ago', '1 day ago')
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} mins ago';
    } else {
      return 'Just now';
    }
  }
}

