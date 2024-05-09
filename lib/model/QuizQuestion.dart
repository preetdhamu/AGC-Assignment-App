import 'package:firebase_database/firebase_database.dart';

class QuizQuestion {
  late String _id;
  late String _question;
  late String _option1;
  late String _option2;
  late String _option3;
  late String _option4;
  late String _correctAnswer;

  QuizQuestion(this._question, this._option1, this._option2,
      this._option3, this._option4, this._correctAnswer);
  QuizQuestion.withId(this._id , _question, this._option1, this._option2,
      this._option3, this._option4, this._correctAnswer);

  //setter

  set question(String question) {
    this._question = question;
  }

  set option1(String option) {
    this._option1 = option;
  }

  set option2(String option) {
    this._option2 = option;
  }

  set option3(String option) {
    this._option3 = option;
  }

  set option4(String option) {
    this._option4 = option;
  }

  set correctAnswer(String correctAnswer) {
    this._correctAnswer = correctAnswer;
  }

  String get id => this._id;
  String get question => this._question;
  String get option1 => this._option1;
  String get option2 => this._option2;
  String get option3 => this._option3;
  String get option4 => this._option4;
  String get correctAnswer => this._correctAnswer;

  QuizQuestion.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> map = snapshot.value! as Map<dynamic, dynamic>;
    this._id = snapshot.key!;
    this._question = map['question'];
    this._option1 = map['option1'];
    this._option2 = map['option2'];
    this._option3 = map['option3'];
    this._option4 = map['option4'];
    this._correctAnswer = map['correctAnswer'];
  }
  static List<QuizQuestion> fromSnapshotList(dynamic questionsList) {
    return List<QuizQuestion>.from(
      questionsList.map((question) => QuizQuestion(
        question['question'],
        question['option1'],
        question['option2'],
        question['option3'],
        question['option4'],
        question['correctAnswer'],
      )),
    );
  }
  Map<String, dynamic> toJSon() {
    return {
      'question':_question,
      'option1' : _option1,
      'option2' : _option2,
      'option3' : _option3,
      'option4' : _option4,
      'correctAnswer' : _correctAnswer,
    };
  }
  
}
