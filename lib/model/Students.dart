import 'package:firebase_database/firebase_database.dart';

class Students {
  String _username = '';
  String _password = '';
  bool _isTeacher = false;
  Students(this._username, this._password, this._isTeacher);
  Students.withusername(this._password);

  set username(String username) {
    _username = username;
  }

  set password(String password) {
    _password = password;
  }

  set isTeacher(bool isTeacher) {
    _isTeacher = isTeacher;
  }

  String get username => _username;
  String get password => _password;
  bool get isTeacher => _isTeacher;

  Students.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> map = snapshot.value! as Map<dynamic, dynamic>;
    this._username = map['username'];
    this._password = map['password'];
    this._isTeacher = map['isTeacher'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {'username': _username, 'password': _password , 'isTeacher': _isTeacher};
  }
}
