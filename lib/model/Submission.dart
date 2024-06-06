import 'package:firebase_database/firebase_database.dart';

class Submission {
  String _username = '';
  String _assignmentId = '';
  String _submissionDate = '';
  String _score = '';
  String _commit = '';

  Submission(this._username, this._assignmentId, this._submissionDate,
      this._score, this._commit);

  set username(String username) {
    _username = username;
  }

  set assignmentId(String id) {
    _assignmentId = id;
  }

  set submissionDate(String submissionDate) {
    _submissionDate = submissionDate;
  }

  set score(String score) {
    _score = score;
  }

  set commit(String commit) {
    _commit = commit;
  }

  String get username => _username;
  String get assignmentId => _assignmentId;
  String get submissionDate => _submissionDate;
  String get score => _score;
  String get commit => _commit;

  Submission.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> map = snapshot.value! as Map<dynamic, dynamic>;
    _assignmentId = map['assignmentId'];
    _username = map['username'];
    _submissionDate = map['submissionDate'];
    _score = map['score'];
    _commit = map['commit'];
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'assignmentId':_assignmentId, 
      'username':_username,
      'submissionDate':_submissionDate,
      'score':_score,
      'commit':_commit
      };
  }
}
