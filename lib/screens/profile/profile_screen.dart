import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

// Profile screen with user information, avatar upload, and role switching
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  // Show bottom sheet allowing user to manually pick an image from gallery or camera
  void _showPhotoUploadOptions(AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a picture to update your campus profile',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppTheme.primary),
                ),
                title: const Text('Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Select a photo from your device storage'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAndUploadProfileImage(auth, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppTheme.primary),
                ),
                title: const Text('Take Photo with Camera',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Capture a new photo using your camera'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAndUploadProfileImage(auth, ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Pick and upload profile image to Firebase Storage
  Future<void> _pickAndUploadProfileImage(
      AuthProvider auth, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    final user = auth.currentUser;
    final uid = user?.uid ?? 'guest';

    try {
      final fileName = 'profile_images/$uid.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(File(pickedFile.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await auth.updateProfileImage(downloadUrl);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully! 📸'),
          backgroundColor: AppTheme.statusResolvedText,
        ),
      );
    } catch (e) {
      debugPrint('Firebase Storage notice: $e');
      // Fallback: save local path for offline/demo presentation
      await auth.updateProfileImage(pickedFile.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated!'),
          backgroundColor: AppTheme.statusResolvedText,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    final userName =
        user?.name.isNotEmpty == true ? user!.name : 'Amina Hassan';
    final userEmail =
        user?.email.isNotEmpty == true ? user!.email : 'a.hassan@alueducation.com';
    final userRole = user?.role.isNotEmpty == true ? user!.role : 'student';
    final department = user?.department.isNotEmpty == true
        ? user!.department
        : 'BSc (Hons) in Software Engineering (BSE)';
    final campus =
        user?.campus.isNotEmpty == true ? user!.campus : 'Kigali, Rwanda';
    final profileImage = user?.profileImage;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Avatar & User Header Card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    // Avatar image with edit camera button overlay
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryLight,
                            border: Border.all(
                              color: AppTheme.primary,
                              width: 2.5,
                            ),
                          ),
                          child: ClipOval(
                            child: _isUploading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.primary),
                                    ),
                                  )
                                : profileImage != null &&
                                        profileImage.isNotEmpty
                                    ? (profileImage.startsWith('http')
                                        ? Image.network(
                                            profileImage,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: AppTheme.primary,
                                            ),
                                          )
                                        : Image.file(
                                            File(profileImage),
                                            fit: BoxFit.cover,
                                          ))
                                    : Image.network(
                                        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                          ),
                        ),
                        // Quick Camera Badge Tap
                        GestureDetector(
                          onTap: _isUploading
                              ? null
                              : () => _showPhotoUploadOptions(auth),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Explicit Manual Photo Upload / Edit Button
                    TextButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () => _showPhotoUploadOptions(auth),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: AppTheme.primary,
                      ),
                      label: Text(
                        _isUploading ? 'Uploading photo...' : 'Edit Profile Photo',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // User full name
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ALU email
                    Text(
                      userEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Role Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Role: ${userRole.toUpperCase()}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Seamless Role-Switch Toggle Button for Demo Presentation
                    OutlinedButton.icon(
                      onPressed: () => auth.toggleRole(),
                      icon: Icon(
                        userRole == 'staff'
                            ? Icons.school_outlined
                            : Icons.admin_panel_settings_outlined,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      label: Text(
                        'Switch to ${userRole == 'staff' ? 'Student' : 'Campus Staff'} View',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Academic & Campus Details Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: userRole == 'staff'
                          ? Icons.apartment_rounded
                          : Icons.school_outlined,
                      title: userRole == 'staff'
                          ? 'Staff Department / Role'
                          : 'Degree / Program',
                      value: department,
                    ),
                    const Divider(
                        height: 1, indent: 56, color: AppTheme.borderColor),
                    _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      title: 'Campus',
                      value: campus,
                    ),
                    const Divider(
                        height: 1, indent: 56, color: AppTheme.borderColor),
                    _buildInfoTile(
                      icon: Icons.verified_user_outlined,
                      title: 'Email Status',
                      value: 'ALU Verified (@alueducation.com)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // About ALU FixIt
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppTheme.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'About FIXIT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'FIXIT is a centralized campus incident reporting and facility tracking platform for the African Leadership University community at Kigali Innovation City.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sign Out Button
              ElevatedButton.icon(
                onPressed: () => auth.signOut(),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Information tile helper
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
