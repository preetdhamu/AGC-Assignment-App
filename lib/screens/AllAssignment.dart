import 'package:agc/model/Subject.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'AddAssignment.dart';
import 'EditAssignment.dart';
import 'PreviewAssignment.dart';

class AllAssignment extends StatefulWidget {
  final String id;
  const AllAssignment({Key? key, required this.id }) : super(key: key);

  @override
  State<AllAssignment> createState() => _AllAssignmentState(id );
}

class _AllAssignmentState extends State<AllAssignment> {
  final String id;
  bool isLoading = true;
  late String _subname;
  late String _subcode;

  _AllAssignmentState(this.id);

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    getSubject(id);
  }

  getSubject(String id) async {
    _databaseReference.child(id).onValue.listen((event) {
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
      return EditAssignment(
        id: id,
        assignmentId: assignmentId,
      );
    }));
  }

  navigateToPreViewAssignment(
      String assignmentId, String course, String semester, String department , String subname , String subcode) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PreviewAssignment(
          id: id,
          assignmentId: assignmentId,
          course: course,
          semester: semester,
          department: department ,
          subname:subname , 
          subcode:subcode ,
          );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isLoading ? Text('Loading...') : Text("$_subname , $_subcode"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : Container(
              color: Colors.blue[100],
              child: FirebaseAnimatedList(
                  query: _databaseReference.child(id).child('Assigments'),
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    var value =
                        Map<String, dynamic>.from(snapshot.value as Map);

                    return Container(
                      margin: EdgeInsets.all(20.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              InkWell(
                                onTap: () {
                                  navigateToPreViewAssignment(
                                      snapshot.key!,
                                      value['course'].toString(),
                                      value['semester'].toString(),
                                      value['department'].toString() ,
                                      _subname,
                                      _subcode
                                      );
                                },
                                child: Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.black,
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    navigateToEditAssignment(snapshot.key!);
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  )),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToAddAssignment(id);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
