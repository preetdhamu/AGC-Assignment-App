import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreviewAssignment extends StatefulWidget {
  final String id; // This is the assignment ID
  final String assignmentId;
  PreviewAssignment({required this.id, required this.assignmentId});

  @override
  State<StatefulWidget> createState() {
    return _PreviewAssignmentState(this.id, this.assignmentId);
  }
}

class _PreviewAssignmentState extends State<PreviewAssignment> {
  final String id;
  final String assignmentId;
  late List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  _PreviewAssignmentState(this.id, this.assignmentId);

  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    print("id is : ${this.id}");
    getQuestions();
  }

  getQuestions() async {
    _databaseReference
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
  }

  _deleteAssignment() async {
    TextEditingController passwordController = TextEditingController();
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Do u want to delete the assignment ?"),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter your Password",
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    try {
                      if (passwordController.text.isNotEmpty) {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          AuthCredential credential =
                              EmailAuthProvider.credential(
                                  email: user.email!,
                                  password: passwordController.text);
                          await user.reauthenticateWithCredential(credential);
                          await _databaseReference
                              .child(id)
                              .child('Assigments')
                              .child(assignmentId)
                              .remove();

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Assignment Deleted Successfully"),
                          ));
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        } else {
                          throw Exception(
                              "User not Provided Correct Credentials");
                        }
                      }
                      else{
                        return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text("FIll the Credentials First"),
                            );
                          });
                      }
                    } on FirebaseAuthException catch (e) {
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text(e.code.toString()),
                            );
                          });
                    }
                  },
                  child: Text("Delete")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Assignment'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return ListTile(
                        title: Text(question['question']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Option 1: ${question['option1']}'),
                            Text('Option 2: ${question['option2']}'),
                            Text('Option 3: ${question['option3']}'),
                            Text('Option 4: ${question['option4']}'),
                            Text(
                                'Correct Answer: ${question['correctAnswer']}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      _deleteAssignment();
                    },
                    child: Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
    );
  }
}
