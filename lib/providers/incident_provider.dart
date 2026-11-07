import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';

// State management provider for Incident Reports
class IncidentProvider with ChangeNotifier {
  final FirebaseFirestore? _customFirestore;
  FirebaseFirestore get _firestore => _customFirestore ?? FirebaseFirestore.instance;

  List<IncidentModel> _incidents = [];
  bool _isLoading = false;

  IncidentProvider({FirebaseFirestore? firestore}) : _customFirestore = firestore {
    // Load initial sample data and listen to live Firestore updates
    _loadSampleIncidents();
    try {
      listenToIncidents();
    } catch (e) {
      debugPrint('Firestore initialization notice: $e');
    }
  }

  // Getters
  List<IncidentModel> get incidents => _incidents;
  bool get isLoading => _isLoading;

  // Counts for summary cards
  int get totalCount => _incidents.length;
  int get inProgressCount =>
      _incidents.where((i) => i.status == 'In Progress').length;
  int get resolvedCount =>
      _incidents.where((i) => i.status == 'Resolved').length;
  int get submittedCount =>
      _incidents.where((i) => i.status == 'Submitted').length;

  // Recent 5 incidents
  List<IncidentModel> get recentIncidents => _incidents.take(5).toList();

  // Filter reports by status ('All', 'Submitted', 'In Progress', 'Resolved')
  List<IncidentModel> filterByStatus(String status) {
    if (status == 'All') return _incidents;
    return _incidents.where((i) => i.status == status).toList();
  }

  // Filter reports for specific user
  List<IncidentModel> userIncidents(String uid) {
    return _incidents.where((i) => i.reportedByUid == uid).toList();
  }

  // Seed sample data matching the mockup for instant preview
  void _loadSampleIncidents() {
    final now = DateTime.now();
    _incidents = [
      IncidentModel(
        id: 'sample-1',
        title: 'Water shortage',
        description:
            'There has been no water supply in the student residence since this morning. This is affecting many students on the 2nd floor. Kindly check and fix the issue.',
        category: 'Water',
        location: 'Soul Hostels (Soul A & Soul B) — Bumbogo',
        status: 'Submitted',
        reportedByUid: 'user-amina',
        reportedByName: 'Amina Hassan',
        reportedByEmail: 'a.hassan@alueducation.com',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      IncidentModel(
        id: 'sample-2',
        title: 'Broken classroom projector',
        description:
            'The overhead projector in Rwanda Learning Lab won\'t turn on during lectures. Requires technical check.',
        category: 'Facilities',
        location: 'Leadership Center — Rwanda Learning Lab',
        status: 'In Progress',
        reportedByUid: 'user-amina',
        reportedByName: 'Amina Hassan',
        reportedByEmail: 'a.hassan@alueducation.com',
        createdAt: now.subtract(const Duration(days: 1)),
        inProgressAt: now.subtract(const Duration(hours: 18)),
      ),
      IncidentModel(
        id: 'sample-3',
        title: 'Overflowing bin',
        description:
            'The waste bin near the food court entrance is overflowing and needs immediate sanitation attention.',
        category: 'Sanitation',
        location: 'Social Commons — Food Court / Cafeteria',
        status: 'Resolved',
        reportedByUid: 'user-amina',
        reportedByName: 'Amina Hassan',
        reportedByEmail: 'a.hassan@alueducation.com',
        createdAt: now.subtract(const Duration(days: 3)),
        inProgressAt: now.subtract(const Duration(days: 2)),
        resolvedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Listen to Firestore real-time collection updates
  void listenToIncidents() {
    try {
      _firestore
          .collection('incidents')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _incidents = snapshot.docs
              .map((doc) => IncidentModel.fromMap(doc.data(), doc.id))
              .toList();
          notifyListeners();
        }
      }, onError: (err) {
        debugPrint('Firestore incidents listen error: $err');
      });
    } catch (e) {
      debugPrint('Firestore initialization notice: $e');
    }
  }

  // Create new incident report in Firestore
  Future<bool> createIncident(IncidentModel incident) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = await _firestore.collection('incidents').add(incident.toMap());
      final newReport = IncidentModel(
        id: docRef.id,
        title: incident.title,
        description: incident.description,
        category: incident.category,
        location: incident.location,
        imageUrl: incident.imageUrl,
        status: incident.status,
        reportedByUid: incident.reportedByUid,
        reportedByName: incident.reportedByName,
        reportedByEmail: incident.reportedByEmail,
        createdAt: incident.createdAt,
      );

      // Prepend to local list
      _incidents.insert(0, newReport);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating incident: $e');
      // If Firestore is offline, still update locally so UI responds immediately
      _incidents.insert(0, incident);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // Available campus blocks for staff routing and filtering
  List<String> get campusBlocks => const [
        'All',
        'Leadership Center',
        'Social Commons',
        'Enterprise Commons',
        'Grounds & Security',
        'Soul Hostels',
      ];

  // Update incident status (Staff only), optionally with notes and staff name
  Future<bool> updateIncidentStatus(
    String incidentId,
    String newStatus, {
    String? resolutionNotes,
    String? staffName,
  }) async {
    try {
      final Map<String, dynamic> updates = {'status': newStatus};
      final now = DateTime.now();

      if (newStatus == 'In Progress') {
        updates['inProgressAt'] = now.toIso8601String();
      } else if (newStatus == 'Resolved') {
        updates['resolvedAt'] = now.toIso8601String();
      }

      if (resolutionNotes != null && resolutionNotes.isNotEmpty) {
        updates['resolutionNotes'] = resolutionNotes;
      }
      if (staffName != null && staffName.isNotEmpty) {
        updates['assignedStaffName'] = staffName;
      }

      await _firestore.collection('incidents').doc(incidentId).update(updates);

      // Update in local state
      final index = _incidents.indexWhere((i) => i.id == incidentId);
      if (index != -1) {
        final current = _incidents[index];
        _incidents[index] = IncidentModel(
          id: current.id,
          title: current.title,
          description: current.description,
          category: current.category,
          location: current.location,
          imageUrl: current.imageUrl,
          status: newStatus,
          reportedByUid: current.reportedByUid,
          reportedByName: current.reportedByName,
          reportedByEmail: current.reportedByEmail,
          createdAt: current.createdAt,
          inProgressAt: newStatus == 'In Progress' ? now : current.inProgressAt,
          resolvedAt: newStatus == 'Resolved' ? now : current.resolvedAt,
          resolutionNotes: resolutionNotes ?? current.resolutionNotes,
          assignedStaffName: staffName ?? current.assignedStaffName,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating incident status: $e');
      return false;
    }
  }

  // Delete incident report from Firestore (CRUD: Delete)
  Future<bool> deleteIncident(String incidentId) async {
    try {
      await _firestore.collection('incidents').doc(incidentId).delete();
      _incidents.removeWhere((i) => i.id == incidentId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting incident: $e');
      _incidents.removeWhere((i) => i.id == incidentId);
      notifyListeners();
      return true;
    }
  }

  // Search and filter incidents by query text, status, and campus block
  List<IncidentModel> searchAndFilter({
    String query = '',
    String status = 'All',
    String block = 'All',
  }) {
    return _incidents.where((incident) {
      final matchesStatus = status == 'All' || incident.status == status;
      final matchesBlock = block == 'All' || incident.campusBlock == block;
      final matchesQuery = query.isEmpty ||
          incident.title.toLowerCase().contains(query.toLowerCase()) ||
          incident.location.toLowerCase().contains(query.toLowerCase()) ||
          incident.description.toLowerCase().contains(query.toLowerCase()) ||
          incident.reportedByName.toLowerCase().contains(query.toLowerCase());
      return matchesStatus && matchesBlock && matchesQuery;
    }).toList();
  }
}
