import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';

// Screen for submitting a new campus incident report
class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Selection states
  String _selectedCategory = 'Facilities';
  String _selectedLocation = 'Block B — Room 204';
  File? _pickedImage;
  bool _isSubmitting = false;

  // Available categories
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Facilities', 'icon': Icons.apartment_rounded},
    {'name': 'Water', 'icon': Icons.water_drop_outlined},
    {'name': 'Electricity', 'icon': Icons.bolt_outlined},
    {'name': 'Safety', 'icon': Icons.shield_outlined},
    {'name': 'Sanitation', 'icon': Icons.delete_outline_rounded},
  ];

  // Available locations
  final List<String> _locations = [
    'Block B — Room 204',
    'Block A — Classroom 101',
    'Student Residence',
    'Cafeteria',
    'Library & Learning Commons',
    'Campus Sports Arena',
    'Administration Building',
    'Engineering & Tech Lab',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Pick photo from gallery or camera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // Upload photo to Firebase Storage
  Future<String?> _uploadImage(String userId) async {
    if (_pickedImage == null) return null;

    try {
      final fileName = 'incidents/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(_pickedImage!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Firebase Storage upload notice: $e');
      // Gracefully continue so user can still submit report
      return null;
    }
  }

  // Handle report submission
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);

    final currentUser = auth.currentUser;
    final uid = currentUser?.uid ?? 'guest_uid';
    final name = currentUser?.name ?? 'Amina Hassan';
    final email = currentUser?.email ?? 'a.hassan@alueducation.com';

    // 1. Upload photo if selected
    String? imageUrl;
    if (_pickedImage != null) {
      imageUrl = await _uploadImage(uid);
    }

    // 2. Create IncidentModel
    final newIncident = IncidentModel(
      id: '', // Will be assigned by Firestore
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      location: _selectedLocation,
      imageUrl: imageUrl,
      status: 'Submitted',
      reportedByUid: uid,
      reportedByName: name,
      reportedByEmail: email,
      createdAt: DateTime.now(),
    );

    // 3. Save to Firestore via provider
    final success = await incidentProvider.createIncident(newIncident);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully! 🎉'),
          backgroundColor: AppTheme.statusResolvedText,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Report an Incident',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Selector Section
                const Text(
                  'Select a category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryGrid(),
                const SizedBox(height: 22),

                // Title Input
                const Text(
                  'Title',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Briefly describe the issue...',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please provide a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description Input
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'Provide more details about the issue...\ne.g. what happened, when, impact, etc.',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please provide a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Location Dropdown
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLocation,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  items: _locations.map((loc) {
                    return DropdownMenuItem(
                      value: loc,
                      child: Text(
                        loc,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLocation = val);
                  },
                ),
                const SizedBox(height: 20),

                // Add a Photo (optional)
                const Text(
                  'Add a photo (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPhotoUploadArea(),
                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit Report'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 2-row category selector matching the UI mockup
  Widget _buildCategoryGrid() {
    return Column(
      children: [
        // Top row: Facilities, Water, Electricity
        Row(
          children: [
            Expanded(child: _buildCategoryItem(_categories[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryItem(_categories[1])),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryItem(_categories[2])),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom row: Safety, Sanitation
        Row(
          children: [
            Expanded(child: _buildCategoryItem(_categories[3])),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryItem(_categories[4])),
            const Expanded(child: SizedBox()), // Empty spacer to balance 3 columns
          ],
        ),
      ],
    );
  }

  // Individual category button
  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final name = category['name'] as String;
    final icon = category['icon'] as IconData;
    final isSelected = _selectedCategory == name;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = name),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : const Color(0xFFF1F3FA),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? Colors.white : AppTheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Photo upload area with preview support
  Widget _buildPhotoUploadArea() {
    if (_pickedImage != null) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _pickedImage!,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 14,
              child: Icon(Icons.close, size: 16, color: Colors.black87),
            ),
            onPressed: () => setState(() => _pickedImage = null),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderColor,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 36,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'Tap to add photos',
              style: TextStyle(
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
}
