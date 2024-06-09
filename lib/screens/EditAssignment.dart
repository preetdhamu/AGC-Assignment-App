import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EditAssignment extends StatefulWidget {
  final String id;
  final String assignmentId;
  EditAssignment({required this.id  , required this.assignmentId});

  @override
  State<StatefulWidget> createState() {
    return _EditAssignmentState(this.id , this.assignmentId);
  }
}

class _EditAssignmentState extends State<EditAssignment> {
  final String id;
  late String assignmentId;
  late List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  _EditAssignmentState(this.id ,this.assignmentId);
  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    print("Init called successfully");
    getQuestions();
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
            isLoading = false;
          });
        } catch (e) {
          print('Error parsing data: $e');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("No data found for the given assignment ID");
        setState(() {
          isLoading = false;
        });
      }
    });
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Assignment'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                var question = questions[index];
                return QuestionForm(
                    questionData: question,
                    onSave: (updatedQuestion) {
                      setState(() {
                        //deadline update 
                        //subject update 
                        questions[index] = updatedQuestion;
                      });
                    });
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _submitForm();
        },
        child: Icon(Icons.save),
      ),
    );
  }

  void _submitForm() async {
    setState(() {
      isLoading = true;
    });
    try {
      final DatabaseReference assignmentRef =
          _databaseReference.child('subjects').child(id).child('Assigments').child(assignmentId);
      final DataSnapshot snapshot = await assignmentRef.get();
      final Map<String, dynamic> existingData =
          Map<String, dynamic>.from(snapshot.value as Map);
      existingData['question'] = questions;
      await assignmentRef.set(existingData);

      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Assignment updated Successfully ")));
      Navigator.of(context).pop();
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro occured in updation")));
    }
  }
}

class QuestionForm extends StatefulWidget {
  final Map<String, dynamic> questionData;
  final Function(Map<String, dynamic>) onSave;

  QuestionForm({required this.questionData, required this.onSave});

  @override
  _QuestionFormState createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final _formKey = GlobalKey<FormState>();

  late String _question;
  late String _option1;
  late String _option2;
  late String _option3;
  late String _option4;
  late String _correctAnswer;

  @override
  void initState() {
    super.initState();
    _question = widget.questionData['question'];
    _option1 = widget.questionData['option1'];
    _option2 = widget.questionData['option2'];
    _option3 = widget.questionData['option3'];
    _option4 = widget.questionData['option4'];
    _correctAnswer = widget.questionData['correctAnswer'];
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: _question,
            decoration: InputDecoration(labelText: 'Question'),
            onSaved: (value) {
              _question = value!;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a question';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: _option1,
            decoration: InputDecoration(labelText: 'Option 1'),
            onSaved: (value) {
              _option1 = value!;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter option 1';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: _option2,
            decoration: InputDecoration(labelText: 'Option 2'),
            onSaved: (value) {
              _option2 = value!;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter option 2';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: _option3,
            decoration: InputDecoration(labelText: 'Option 3'),
            onSaved: (value) {
              _option3 = value!;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter option 3';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: _option4,
            decoration: InputDecoration(labelText: 'Option 4'),
            onSaved: (value) {
              _option4 = value!;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter option 4';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: _correctAnswer,
            decoration: InputDecoration(labelText: 'Correct Answer'),
            onSaved: (value) {
              _correctAnswer = value!;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the correct answer';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveForm,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.onSave({
        'question': _question,
        'option1': _option1,
        'option2': _option2,
        'option3': _option3,
        'option4': _option4,
        'correctAnswer': _correctAnswer,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Question updated')));
    }
  }
}
