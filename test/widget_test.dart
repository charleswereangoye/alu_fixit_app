import 'package:flutter_test/flutter_test.dart';
import 'package:alu_fixit_app/models/user_model.dart';

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
}
