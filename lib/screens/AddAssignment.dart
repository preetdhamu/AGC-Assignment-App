import 'package:agc/model/Assignment.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:file_picker/file_picker.dart';
import '../model/QuizQuestion.dart';
import 'dart:io';
import '../model/Subject.dart';

class AddAssignment extends StatefulWidget {
  final id;
  const AddAssignment({Key? key, required this.id}) : super(key: key);

  @override
  State<AddAssignment> createState() => _AddAssignmentState(id);
}

class _AddAssignmentState extends State<AddAssignment> {
  String course = '';
  String semester = '';
  String department = '';

  List<QuizQuestion> questions = [];
  bool isLoad = true;
  bool _autovalidate = false;
  int flag = 0;
  GlobalKey<FormState> _key = GlobalKey();
  DatabaseReference _database = FirebaseDatabase.instance.ref();
  var id;
  late Subject _sub;
  _AddAssignmentState(this.id);
  @override
  void initState() {
    super.initState();
    this.getSubject(id);
  }

  getSubject(id) async {
    _database.child(id).onValue.listen((event) {
      setState(() {
        _sub = Subject.fromSnapShot(event.snapshot);
        print("Subject is loaded successfully ${_sub.subname}");
        isLoad = false;
      });
    });
  }

  Future<String?> pickDocxFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null) {
      String docxPath = result.files.single.path!;
      print("File Picked Successfully $docxPath");
      return docxPath;
    } else {
      // User canceled the file picker.
      print('File picking canceled.');
      return null;
    }
  }

  Future<void> getDocxFilePath() async {
    String? docxPath = await pickDocxFile();

    if (docxPath != null) {
      final file = await DefaultAssetBundle.of(context).load("assets/b.docx");
      final bytes = file.buffer.asUint8List();

      // final file = File(docxPath);
      // final bytes = await file.readAsBytes();
      final text = await docxToText(bytes, handleNumbering: true);

      extractQuestions(text);
      setState(() {
        flag = 1;
      });
      print('File Picked Successfully $docxPath');
    } else {
      print('No DOCX file selected.');
    }
  }

  void extractQuestions(String text) {
    // Split text into individual questions
    List<String> rawQuestions = text.split('Question ');

    // Filter out empty strings
    rawQuestions = rawQuestions.where((q) => q.trim().isNotEmpty).toList();
    // Extract data for each question
    List<QuizQuestion> extractedQuestions = rawQuestions.map((questionText) {
      List<String> lines = questionText.split('\n');
      String question = lines.first.trim();
      List<String> options =
          lines.sublist(1, 5).map((opt) => opt.trim()).toList();
      String correctAnswerLine =
          lines.firstWhere((line) => line.contains('Correct Answer'));
      String correctAnswer = correctAnswerLine.split(':').last.trim();

      return QuizQuestion(question, options[0], options[1], options[2],
          options[3], correctAnswer);
    }).toList();

    setState(() {
      questions = extractedQuestions;
      print("Questions extracted Succesfully");
      isLoad = true;
    });

    print('Questions extracted:\n$questions');
  }

  navigateToLastScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  _setValuesToKey() async {
    if (_key.currentState!.validate() && flag == 1) {
      _key.currentState!.save();
      course = course.trim().toUpperCase();
      semester = semester.trim().toUpperCase();
      department = department.toUpperCase();
      print("All keys are accessed");
      Assignment assignment = Assignment(
          course, semester, department, questions);
      setState(() {
        _sub.addAssignment(assignment);
        print("Assignment UPloaded Successfully ");
      });
      navigateToLastScreen(context);
    } else {
      setState(() {
        _autovalidate = true;
      });
    }
  }

  Future<dynamic> getPreviewPage() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Preview Of Questions "),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: questions.map((question) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Question: ${question.question}'),
                      Text('Option 1: ${question.option1}'),
                      Text('Option 2: ${question.option2}'),
                      Text('Option 3: ${question.option3}'),
                      Text('Option 4: ${question.option4}'),
                      Text('Correct Answer: ${question.correctAnswer}'),
                      SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Assignment"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Color.fromARGB(255, 177, 220, 255),
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              ListTile(
                leading: Icon(
                  Icons.data_object,
                  color: Colors.black,
                ),
                title: TextFormField(
                  validator: (input) {
                    if (input!.isEmpty) {
                      return "Enter Course ";
                    }
                  },
                  decoration: InputDecoration(
                    label: Text(
                      'Course',
                      style: TextStyle(color: Colors.black),
                    ),
                    labelStyle: TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.black),
                  ),
                  onSaved: (input) {
                    course = input!;
                  },
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              ListTile(
                leading: Icon(
                  Icons.data_object,
                  color: Colors.black,
                ),
                title: TextFormField(
                  validator: (input) {
                    if (input!.isEmpty) {
                      return "Enter Semester ";
                    }
                  },
                  decoration: InputDecoration(
                    label: Text(
                      'Semester',
                      style: TextStyle(color: Colors.black),
                    ),
                    labelStyle: TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.black),
                  ),
                  onSaved: (input) {
                    semester = input!;
                  },
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              ListTile(
                leading: Icon(
                  Icons.data_object,
                  color: Colors.black,
                ),
                title: TextFormField(
                  enabled: false, // Set to false to disable the TextFormField
                  initialValue: _sub.subname, // Set the default value
                  decoration: InputDecoration(
                    label: Text(
                      'Subject',
                      style: TextStyle(color: Colors.black),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 15.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                  ),
                  
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              ListTile(
                leading: Icon(
                  Icons.data_object,
                  color: Colors.black,
                ),
                title: TextFormField(
                  enabled: false, // Set to false to disable the TextFormField
                  initialValue: _sub.subcode , // Set the default value
                  decoration: InputDecoration(
                    label: Text(
                      'Subjectcode',
                      style: TextStyle(color: Colors.black),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 15.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                  ),
                  
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              ListTile(
                leading: Icon(
                  Icons.data_object,
                  color: Colors.black,
                ),
                title: TextFormField(
                  validator: (input) {
                    if (input!.isEmpty) {
                      return "Enter Department";
                    }
                  },
                  decoration: InputDecoration(
                    label: Text(
                      'Department',
                      style: TextStyle(color: Colors.black),
                    ),
                    labelStyle: TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.black),
                  ),
                  onSaved: (input) {
                    department = input!;
                  },
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              ElevatedButton(
                onPressed: () {
                  getDocxFilePath();
                },
                child: Text(
                  "Pick DOCX File",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    getPreviewPage();
                  },
                  child: Text(
                    "Show data",
                    style: TextStyle(color: Colors.black),
                  )),
              Padding(
                padding: EdgeInsets.all(25.0),
              ),
              SizedBox(
                width: 300,
                child: MaterialButton(
                  onPressed: () {
                    _setValuesToKey();
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.black),
                  ),
                  minWidth: 150.0,
                  height: 40,
                  color: const Color.fromARGB(255, 142, 37, 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
