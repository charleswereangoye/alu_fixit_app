// User model representing a student or campus staff member
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' or 'staff'
  final String department;
  final String campus;
  final String? profileImage;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.department = 'Computer Science',
    this.campus = 'Kigali, Rwanda',
    this.profileImage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Helper check for staff role
  bool get isStaff => role == 'staff';

  // Convert user data to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'campus': campus,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create user object from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      department: map['department'] ?? 'Computer Science',
      campus: map['campus'] ?? 'Kigali, Rwanda',
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
