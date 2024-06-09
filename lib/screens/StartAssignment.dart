import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StartAssignment extends StatefulWidget {
  final String id; // This is the assignment ID
  final String assignmentId;
  final String semester;
  final String course;
  final String department;
  final String subname;
  final String subcode;
  final String deadline;
  StartAssignment({
    required this.id,
    required this.assignmentId,
    required this.course,
    required this.semester,
    required this.department,
    required this.subname,
    required this.subcode,
    required this.deadline,
  });

  @override
  State<StatefulWidget> createState() {
    return _StartAssignmentState(id, assignmentId, course, semester, department,
        subname, subcode, deadline);
  }
}

class _StartAssignmentState extends State<StartAssignment>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isMinimized = false;
  int _selectedOption = -1;
  Timer? _timer;
  int _timerLeft = 600;

  final String assignmentId;
  final String id;
  final String course;
  final String semester;
  final String department;
  final String subname;
  final String subcode;
  final String deadline;
  bool isLoad = true;
  bool isTeacher = false;
  String userBatch = '';
  String userCollegeRollNo = '';
  String userCourse = '';
  String userDepartment = '';
  String userSemester = '';
  String userUnivRollNo = '';
  late List<Map<String, dynamic>> questions = [];
  User? user;

  _StartAssignmentState(this.id, this.assignmentId, this.course, this.semester,
      this.department, this.subname, this.subcode, this.deadline);

  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    getStudent();
    WidgetsBinding.instance?.addObserver(this);
    _startTimer();
    getQuestions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  getQuestions() async {
    _databaseReference
        .child('subjects')
        .child(id)
        .child('Assigments')
        .child(assignmentId)
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      print("Data received: $data");
      if (data != null) {
        try {
          final Map<String, dynamic> assignmentData =
              Map<String, dynamic>.from(data as Map);
          final List<Map<String, dynamic>> questions =
              List<Map<String, dynamic>>.from(
                  (assignmentData['question'] as List)
                      .map((item) => Map<String, dynamic>.from(item as Map)));
          print("Questions: $questions");
          setState(() {
            this.questions = questions;
            isLoad = false;
          });
        } catch (e) {
          print('Error parsing data: $e');
          setState(() {
            isLoad = false;
          });
        }
      } else {
        print("No data found for the given assignment ID");
        setState(() {
          isLoad = false;
        });
      }
    });
  }

  Future<void> getStudent() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.reload();
        firebaseUser = FirebaseAuth.instance.currentUser;
        final uid = firebaseUser!.uid;
        final snapshot = await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(uid)
            .get();

        final data = snapshot.value as Map?;
        print("the data is $data");
        if (data != null) {
          setState(() {
            isTeacher = data['isTeacher'] ?? 'false';
            if (!isTeacher) {
              userSemester = data['semester'] ?? '';
              userCourse = data['course'] ?? '';
              userDepartment = data['department'] ?? '';
              userUnivRollNo = data['univRollNo'] ?? '';
              userCollegeRollNo = data['collegeRollNo'] ?? '';
              userBatch = data['batch'] ?? '';

              print("semester of the user is :$userSemester");
            }
            user = firebaseUser;
            isLoad = false;
          });
        }
      } else {
        setState(() {
          isLoad = false;
        });
      }
    } catch (e) {
      print('Error getting user: $e');
      setState(() {
        isLoad = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isMinimized) {
        setState(() {
          _score = 0;
          _submitResult();
          _timer?.cancel();
        });
      } else {
        setState(() {
          if (_timerLeft > 0) {
            _timerLeft--;
          } else {
            _timer?.cancel();
            _submitResult();
          }
        });
      }
    });
  }

  void _submitResult() {
    final result = {
      'studentUnivRollNo': userUnivRollNo,
      'assignmentId': assignmentId,
      'score': _score,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print(result);
    // _databaseReference
    //     .child('results')
    //     .push()
    //     .set(result)
    //     .then((_) => print("Result Submitted Successfully "))
    //     .catchError((error) => print("Failed to submit result : $error"));
    Navigator.pop(context);
  }

  void _nextQuestion() {
    // Check if an option is selected
    if (_selectedOption == -1) return;

    final correctAnswer = questions[_currentQuestionIndex]['correctAnswer'];

    // Update score based on selection
    if (questions[_currentQuestionIndex]['option${_selectedOption + 1}'] ==
        correctAnswer) {
      setState(() {
        _score++;
        print("Current Score: $_score");
      });
    }

    // Update question index and handle completion
    setState(() {
      _selectedOption = -1; // Reset selected option
      if (_currentQuestionIndex < questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _submitResult();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App is going into the background, reset the score here
      setState(() {
        _score = 0;
        _submitResult();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoad) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Start Assignment"),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final currentQuestion = questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text("Start Assignment "),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            print('Pop action was performed');
          } else {
            print('Pop action was not performed');
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Time left: ${_timerLeft ~/ 60}:${(_timerLeft % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Question ${_currentQuestionIndex + 1}/${questions.length}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  currentQuestion['question'],
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                ...List.generate(4, (index) {
                  return RadioListTile(
                    title: Text(currentQuestion['option${index + 1}']),
                    value: index,
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value as int;
                      });
                    },
                  );
                }),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectedOption == -1 ? null : _nextQuestion,
                  child: Text(
                    _currentQuestionIndex == questions.length - 1
                        ? 'Submit'
                        : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
