import 'package:agc/model/QuizQuestion.dart';
import 'package:firebase_database/firebase_database.dart';

class Assignment {
  late String _id;
  late String _course;
  late String _semester;
  late String _department;
  late String _deadline;
  late List<QuizQuestion> _question = [];

  Assignment(this._course, this._semester, this._department,this._deadline, this._question
      );

  Assignment.withId(this._id, this._course, this._semester, this._department,
      this._deadline ,this._question);

  // Setters
  set id(String id) {
    this._id = id;
  }

  set deadline(String deadline) {
    this._deadline = deadline;
  }

  set course(String course) {
    this._course = course;
  }

  set semester(String semester) {
    this._semester = semester;
  }

  set department(String department) {
    this._department = department;
  }

  set question(List<QuizQuestion> question) {
    this._question = question;
  }

  // Getters
  String get deadline => this._deadline;
  String get id => this._id;
  String get course => this._course;
  String get semester => this._semester;
  String get department => this._department;
  List<QuizQuestion> get question => this._question;

  Assignment.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> map = snapshot.value! as Map<dynamic, dynamic>;
    this._id = snapshot.key!;
    this._course = map['course'];
    this._semester = map['semester'];
    this._department = map['department'];
    this._deadline = map['deadline'];
    this._question = QuizQuestion.fromSnapshotList(map['question']);
  }

  static List<Assignment> fromSnapshotList(dynamic assignmentList) {
    return List<Assignment>.from(
      assignmentList.map((assignment) => Assignment(
            assignment['course'],
            assignment['semester'],
            assignment['department'],
            assignment['deadline'],
            QuizQuestion.fromSnapshotList(
                assignment['question']), // Corrected this line
          )),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course': _course,
      'semester': _semester,
      'department': _department,
      'deadline':_deadline,
      'question': _question.map((q) => q.toJSon()).toList(),
    };
  }
}
