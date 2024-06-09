import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class PreviewAssignment extends StatefulWidget {
  final String id; // This is the assignment ID
  final String assignmentId;
  final String semester;
  final String course;
  final String department;
  final String subname;
  final String subcode;
  final String deadline;
  PreviewAssignment({
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
    return _PreviewAssignmentState(
        this.id,
        this.assignmentId,
        this.course,
        this.semester,
        this.department,
        this.subname,
        this.subcode,
        this.deadline);
  }
}

class _PreviewAssignmentState extends State<PreviewAssignment> {
  final String id;
  final String assignmentId;
  final String course;
  final String semester;
  final String department;
  final String subname;
  final String subcode;
  final String deadline;
  late List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  _PreviewAssignmentState(
      this.id,
      this.assignmentId,
      this.course,
      this.semester,
      this.department,
      this.subname,
      this.subcode,
      this.deadline);

  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    print("id is : ${this.id}");
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
                              .child('subjects')
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
                      } else {
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
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Table(
                    border: TableBorder.all(color: Colors.black),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          children: [
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Image(
                                      image: AssetImage('images/logo.png'),
                                      fit: BoxFit.cover,
                                    ))),
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          "${course}",
                                          style: TextStyle(color: Colors.black ,fontWeight: FontWeight.bold,),
                                        ),
                                        Text(
                                          "${semester}",
                                          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, ),
                                        ),
                                        Text(
                                          "${department}",
                                          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),
                                        ),
                                      ],
                                    ))),
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        
                                        Text(
                                          "${subcode}",
                                          style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold,),
                                        ),
                                        Text(
                                          "${subname}",
                                          style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold,),
                                        ),
                                        Text(
                                              '${deadline}',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ],
                                    ))),
                          ]),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.all(15.0)),
                  Table(
                    border: TableBorder.all(color: Colors.black),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: const [
                      TableRow(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          children: [
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Question",
                                        style:
                                            TextStyle(color: Colors.black , fontWeight: FontWeight.bold,)))),
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Options",
                                        style:
                                            TextStyle(color: Colors.black ,fontWeight: FontWeight.bold,)))),
                            TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Solution",
                                        style:
                                            TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
                          ]),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          return Table(
                            border: TableBorder.all(color: Colors.black),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(children: [
                                TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(question['question'],
                                          style:
                                              TextStyle(color: Colors.black)),
                                    )),
                                TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                                "Options 1 : ${question['option1']}",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            Text(
                                                "Options 2 : ${question['option2']}",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            Text(
                                                "Options 3 : ${question['option3']}",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            Text(
                                                "Options 4 :${question['option4']}",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ],
                                        ))),
                                TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                          "Correct :${question['correctAnswer']}",
                                          style:
                                              TextStyle(color: Colors.black)),
                                    )),
                              ]),
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ),
      floatingActionButton: ElevatedButton(
          onPressed: () {
            _deleteAssignment();
          },
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.red),
          )),
    );
  }
}
