import 'package:agc/model/Subject.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:agc/screens/AddAssignment.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class AllAssignment extends StatefulWidget {
  final id;
  const AllAssignment({Key? key, required this.id}) : super(key: key);

  @override
  State<AllAssignment> createState() => _AllAssignmentState(id);
}

class _AllAssignmentState extends State<AllAssignment> {
  var id;
  bool isLoading = true;
  late Subject _sub;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref(id);
  _AllAssignmentState(this.id);
  @override
  void initState() {
    super.initState();
    this.getSubject(id);

  }

  getSubject(id) async {
    _databaseReference.child(id).onValue.listen((event) {
      setState(() {
        print("Id of subject is : $id");
        _sub = Subject.fromSnapShot(event.snapshot);
        isLoading = false;
      });
    });
  }

  navigateToAddAssignment(id) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddAssignment(
        id: id,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Assignments - ${_sub.subname}"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? CircularProgressIndicator(
              color: Colors.red,
            )
          : Container(
              child: FirebaseAnimatedList(
                  query: _databaseReference,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    var value =
                        Map<String, dynamic>.from(snapshot.value as Map);
                    return GestureDetector(
                      onTap: () {
                        // view the assignment
                      },
                      child: Container(
                        margin: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(value['subjectname'] == null ? '' : 
                            '${value['subjectname']} ' , style: TextStyle(
                              color: Colors.white,
                            ),),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //adding new assignment
          navigateToAddAssignment(id);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
