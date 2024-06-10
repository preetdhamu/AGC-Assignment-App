import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';
import 'AddAssignment.dart';
import 'EditAssignment.dart';
import 'PreviewAssignment.dart';
import 'StartAssignment.dart';

class AllAssignment extends StatefulWidget {
  final String id;
  final bool isTeacher;
  const AllAssignment({Key? key, required this.id, required this.isTeacher})
      : super(key: key);

  @override
  State<AllAssignment> createState() => _AllAssignmentState(id, isTeacher);
}

class _AllAssignmentState extends State<AllAssignment> {
  final String id;
  bool isLoading = true;
  late String _subname;
  late String _subcode;
  final bool isTeacher;
  bool isButtonEnabled = true;

  _AllAssignmentState(this.id, this.isTeacher);

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    getSubject(id);
  }

  String addOneDay(String dateString) {
    DateTime date = DateTime.parse(dateString);
    DateTime newDate = date.add(Duration(days: 1));
    String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
    return formattedDate;
  }

  getSubject(String id) async {
    _databaseReference.child('subjects').child(id).onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          _subname = data['subjectname'] ?? 'No Subject Name';
          _subcode = data['subjectcode'] ?? 'No Subject Code';
          isLoading = false;
        });
      }
    });
  }

  navigateToAddAssignment(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddAssignment(id: id);
    }));
  }

  navigateToEditAssignment(String assignmentId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditAssignment(id: id, assignmentId: assignmentId);
    }));
  }

  navigateToStartAssignment(String assignmentId, String course, String semester,
      String department, String subname, String subcode, String deadline) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return StartAssignment(
        id: id,
        assignmentId: assignmentId,
        course: course,
        semester: semester,
        department: department,
        subname: subname,
        subcode: subcode,
        deadline: deadline,
      );
    }));
  }

  navigateToPreViewAssignment(
      String assignmentId,
      String course,
      String semester,
      String department,
      String subname,
      String subcode,
      String deadline) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PreviewAssignment(
        id: id,
        assignmentId: assignmentId,
        course: course,
        semester: semester,
        department: department,
        subname: subname,
        subcode: subcode,
        deadline: deadline,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isLoading ? Text('') : Text("All Assignments" , style: TextStyle( color:  Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : Container(
              color: Colors.white,
              child: FirebaseAnimatedList(
                  query: _databaseReference
                      .child('subjects')
                      .child(id)
                      .child('Assigments'),
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    var value =
                        Map<String, dynamic>.from(snapshot.value as Map);

                    return Container(
                      
                      margin: EdgeInsets.all(20.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 209, 209, 209),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deadline: ${value['deadline'] != null ? addOneDay(value['deadline']) : "DOU:$value['deadline']"}',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Course : ${value['course']}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              isTeacher
                                  ? InkWell(
                                      onTap: () {
                                        navigateToPreViewAssignment(
                                            snapshot.key!,
                                            value['course'].toString(),
                                            value['semester'].toString(),
                                            value['department'].toString(),
                                            _subname,
                                            _subcode,
                                            '${value['deadline'] != null ? addOneDay(value['deadline']) : "$value['deadline']"}');
                                      },
                                      child: Icon(
                                        Icons.remove_red_eye,
                                        color: Colors.black,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              isTeacher
                                  ? InkWell(
                                      onTap: () {
                                        navigateToEditAssignment(
                                          snapshot.key!,
                                        );
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              !isTeacher
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 8.0, 8.0, 0.0),
                                      child: MaterialButton(
                                        onPressed: () {
                                          navigateToStartAssignment(
                                              snapshot.key!,
                                              value['course'].toString(),
                                              value['semester'].toString(),
                                              value['department'].toString(),
                                              _subname,
                                              _subcode,
                                              '${value['deadline'] != null ? addOneDay(value['deadline']) : "$value['deadline']"}');
                                        },
                                        child: Text(
                                          "Start",
                                          style: TextStyle(color: Colors.red , fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                          Text(
                            "Department : ${value['department']}",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Semester : ${value['semester']}",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
      floatingActionButton: isTeacher
          ? FloatingActionButton(
              onPressed: () {
                navigateToAddAssignment(id);
              },
              child: Icon(Icons.add),
            )
          : SizedBox.shrink(),
    );
  }
}
