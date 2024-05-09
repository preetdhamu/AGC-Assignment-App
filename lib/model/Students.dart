import 'package:firebase_database/firebase_database.dart';

class Students {
  String _username = '';
  String _password = '';
  Students(this._username, this._password);
  Students.withusername(this._password);

  set username(String username) {
    this._username = username;
  }

  set password(String password) {
    this._password = password;
  }

  String get username => this._username;
  String get password => this._password;

  Students.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> map = snapshot.value! as Map<dynamic, dynamic>;
    this._username = map['username'];
    this._password = map['password'];
  }

  Map<String, dynamic> toJson() {
    return {'username': _username, 'password': _password};
  }
}
