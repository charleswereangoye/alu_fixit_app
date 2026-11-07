import 'package:flutter_test/flutter_test.dart';
import 'package:alu_fixit_app/models/user_model.dart';
import 'package:alu_fixit_app/models/incident_model.dart';
import 'package:alu_fixit_app/providers/incident_provider.dart';

void main() {
  test('UserModel converts to and from Map correctly', () {
    final user = UserModel(
      uid: 'test_123',
      name: 'Amina Hassan',
      email: 'a.hassan@alueducation.com',
      role: 'student',
      department: 'Computer Science',
      campus: 'Kigali, Rwanda',
    );

    final map = user.toMap();
    expect(map['uid'], 'test_123');
    expect(map['email'], 'a.hassan@alueducation.com');
    expect(map['role'], 'student');

    final reconstructed = UserModel.fromMap(map, 'test_123');
    expect(reconstructed.name, 'Amina Hassan');
    expect(reconstructed.isStaff, false);
  });

  test('IncidentModel converts to and from Map correctly', () {
    final incident = IncidentModel(
      id: 'inc_101',
      title: 'Water shortage',
      description: 'No water supply in residence',
      category: 'Water',
      location: 'Student Residence',
      status: 'Submitted',
      reportedByUid: 'uid_amina',
      reportedByName: 'Amina Hassan',
      reportedByEmail: 'a.hassan@alueducation.com',
    );

    final map = incident.toMap();
    expect(map['title'], 'Water shortage');
    expect(map['status'], 'Submitted');
    expect(map['category'], 'Water');

    final reconstructed = IncidentModel.fromMap(map, 'inc_101');
    expect(reconstructed.title, 'Water shortage');
    expect(reconstructed.location, 'Student Residence');
    expect(reconstructed.timeAgo, 'Just now');
  });

  test('IncidentProvider search and filter operations work accurately', () {
    final provider = IncidentProvider();
    expect(provider.incidents.isNotEmpty, true);

    // Filter by 'In Progress'
    final inProgress = provider.searchAndFilter(status: 'In Progress');
    expect(inProgress.every((i) => i.status == 'In Progress'), true);

    // Search query match
    final waterResults = provider.searchAndFilter(query: 'water');
    expect(waterResults.any((i) => i.title.toLowerCase().contains('water')), true);

    // Campus Block filtering test
    final leadershipResults =
        provider.searchAndFilter(block: 'Leadership Center');
    expect(leadershipResults.every((i) => i.campusBlock == 'Leadership Center'),
        true);
  });

  test('IncidentModel smart campus block and department routing works', () {
    final labIncident = IncidentModel(
      id: 'lab_1',
      title: 'Broken projector',
      description: 'HDMI cable snapped',
      category: 'Facilities',
      location: 'Leadership Center — Rwanda Lab',
      reportedByUid: 'uid_1',
      reportedByName: 'Amina',
      reportedByEmail: 'a.hassan@alueducation.com',
    );
    expect(labIncident.campusBlock, 'Leadership Center');
    expect(labIncident.assignedDepartment, 'IT & Technical Support');

    final cafeteriaIncident = IncidentModel(
      id: 'caf_1',
      title: 'Water leak',
      description: 'Pipe leaking under sink',
      category: 'Water',
      location: 'Social Commons — Food Court Cafeteria',
      reportedByUid: 'uid_2',
      reportedByName: 'Kwame',
      reportedByEmail: 'k.mensah@alueducation.com',
    );
    expect(cafeteriaIncident.campusBlock, 'Social Commons');
    expect(cafeteriaIncident.assignedDepartment, 'Facilities & Operations');
  });
}
