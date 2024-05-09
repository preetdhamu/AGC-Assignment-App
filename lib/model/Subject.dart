import 'package:agc/model/Assignment.dart';
import 'package:firebase_database/firebase_database.dart';

class Subject {
  late String _subjectcode;
  late String _subjectname;
  late List<Assignment> _assignments = [];
  Subject(this._subjectcode, this._subjectname,
      [List<Assignment>? assignments]) {
    if (assignments != null) {
      this._assignments = assignments;
    }
  }
  Subject.withCode(this._subjectname, this._assignments,
      [List<Assignment>? assignments]) {
    if (assignments != null) {
      this._assignments = assignments;
    }
  }

  String get subcode => this._subjectcode;
  String get subname => this._subjectname;
  List<Assignment> get assignment => this._assignments;

  set subname(String subjectname) {
    this._subjectname = subjectname;
  }

  set subcode(String subjectcode) {
    this._subjectcode = subjectcode;
  }

  void addAssignment(Assignment assignment) {
    this._assignments.add(assignment);

    // DatabaseReference reference = FirebaseDatabase.instance.ref();
    // reference.child(_subjectcode).update({
    //   'assignment': _assignments.map((q) => q.toJson()).toList(),
    // });

    DatabaseReference reference = FirebaseDatabase.instance.ref();
    DatabaseReference subjectReference = reference.child(_subjectcode);
    String assignemntKey = subjectReference.push().key!;
  
    subjectReference.child("Assigments").child(assignemntKey).set(assignment.toJson()).then((_) {
    print("Assignment added to database successfully ");
  }).catchError((error) {
    print("Error adding assignment to the database: $error");
  });
  }

//   void addAssignment(Assignment assignment) {
//   DatabaseReference reference = FirebaseDatabase.instance.ref();
//   DatabaseReference subjectReference = reference.child(_subjectcode).child("assignments");

//   // Append the new assignment to the existing list
//   subjectReference.child("${_assignments.length}").set(assignment.toJson()).then((_) {
//     _assignments.add(assignment);
//     print("Assignment added to database successfully");
//   }).catchError((error) {
//     print("Error adding assignment to the database: $error");
//   });
// }

  Subject.fromSnapShot(DataSnapshot snapshot) {
    Map<dynamic, dynamic>? map = snapshot.value as Map<dynamic, dynamic>?;

    if (map != null) {
      this._subjectcode = map['subjectcode'];
      this._subjectname = map['subjectname'];

      // Check if 'assignment' key exists and is not null
      if (map.containsKey('assignment') && map['assignment'] != null) {
        this._assignments = Assignment.fromSnapshotList(map['assignment']);
      } else {
        // If 'assignment' key is not present or is null, initialize an empty list
        this._assignments = [];
      }
    } else {
      // Handle the case where 'map' is null (no data)
      // You might want to throw an error or set default values based on your use case.
      print("No FIle Found From Map after making a subject ");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectcode': _subjectcode,
      'subjectname': _subjectname,
      'assignment': _assignments.map((q) => q.toJson()).toList(),
    };
  }
}
