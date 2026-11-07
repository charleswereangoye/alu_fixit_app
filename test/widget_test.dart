import 'package:flutter_test/flutter_test.dart';
import 'package:alu_fixit_app/models/user_model.dart';
import 'package:alu_fixit_app/models/incident_model.dart';

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
}
