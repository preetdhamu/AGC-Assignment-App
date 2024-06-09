import 'package:agc/screens/LoginScreen.dart';
import 'package:agc/screens/SignUpPage.dart';
import 'package:agc/screens/ProfileStudent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:agc/screens/AllAssignment.dart';
import 'package:agc/screens/AddSubject.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final String id;
  User? user;
  bool isLoad = false;
  bool isTeacher = false;
  String instructor = '';
  DatabaseReference _dataReference = FirebaseDatabase.instance.ref();
  String userSemester = '';
  String userCourse = '';
  String userDepartment = '';

  @override
  void initState() {
    super.initState();
    checkAuthentication();
    getUser();
  }

  void navigateToAllAssignment(String id, bool isTeacher) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AllAssignment(id: id, isTeacher: isTeacher);
    }));
  }

  void navigateToAddSubject() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddSubject();
    }));
  }

  void checkAuthentication() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }));
      }
    });
  }

  Future<void> getUser() async {
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
              print("semester of the user is :$userSemester");
            }
            user = firebaseUser;
            isLoad = true;
          });
        }
      } else {
        setState(() {
          isLoad = true;
        });
      }
    } catch (e) {
      print('Error getting user: $e');
      setState(() {
        isLoad = true;
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  _deleteSubject(String id) async {
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool didAuthenticate = false;

    if (canCheckBiometrics) {
      try {
        didAuthenticate = await auth.authenticate(
          localizedReason: "Please authenticate to delete the subject",
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
          ),
        );
      } catch (e) {
        print("Error during biometric authentication: $e");
      }
    }

    if (didAuthenticate) {
      await _dataReference.child("subjects").child(id).remove();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Subject Deleted Successfully"),
      ));
      return;
    } else {
      TextEditingController passwordController = TextEditingController();

      return showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("Do you want to delete the subject?"),
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
                            await _dataReference
                                .child('subjects')
                                .child(id)
                                .remove();
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Subject Deleted Successfully"),
                            ));
                            Navigator.of(context).pop();
                          } else {
                            throw Exception(
                                "User not provided correct credentials");
                          }
                        } else {
                          return showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  title: Text("Error"),
                                  content: Text("Fill the Credentials"),
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
  }

  String addOneDay(String dateString) {
    DateTime date = DateTime.parse(dateString);
    DateTime newDate = date.add(Duration(days: 1));
    String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Sidebar',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ProfileStudent();
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to the settings page.
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                logout();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(isTeacher ? "HomePage Teahcer " : "Home"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: !isLoad
            ? CircularProgressIndicator(
                color: Colors.red,
              )
            : isTeacher
                ? Container(
                    child: FirebaseAnimatedList(
                      query: _dataReference.child('subjects'),
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        var value =
                            Map<String, dynamic>.from(snapshot.value as Map);
                        return GestureDetector(
                          onTap: () {
                            print("The snapshot key is ::${snapshot.key}");

                            navigateToAllAssignment(snapshot.key ?? '', true);
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: Container(
                              margin: EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        value['subjectcode'] ?? '',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        value['subjectname'] ?? '',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  MaterialButton(
                                    onPressed: () {
                                      _deleteSubject(snapshot.key.toString());
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          const Text(
                            'Deadline',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // SingleChildScrollView(
                          //   scrollDirection: Axis.horizontal,
                          //   child: Row(
                          //     children: [
                          //       Container(
                          //         height: 100,
                          //         width: 100,
                          //         color: Colors.amber,
                          //       ),
                          //       Container(
                          //         height: 100,
                          //         width: 100,
                          //         color: Colors.orange,
                          //       ),
                          //       Container(
                          //         height: 100,
                          //         width: 100,
                          //         color: Colors.brown,
                          //       ),
                          //       Container(
                          //         height: 100,
                          //         width: 100,
                          //         color: Colors.red,
                          //       ),
                          //       Container(
                          //         height: 100,
                          //         width: 100,
                          //         color: Colors.green,
                          //       ),
                          //       Container(
                          //         height: 100,
                          //         width: 100,
                          //         color: Colors.blue,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Container(
                            color: Colors.blue,
                            height: 300,
                            child: FirebaseAnimatedList(
                              query: _dataReference.child('subjects'),
                              itemBuilder: (BuildContext context,
                                  DataSnapshot snapshot,
                                  Animation<double> animation,
                                  int index) {
                                var subject = Map<String, dynamic>.from(
                                    snapshot.value as Map);
                                print("The subjects in deadline is : $subject");
                                var assignments = subject['Assigments']
                                    as Map<dynamic, dynamic>?;

                                if (assignments == null) {
                                  return SizedBox.shrink();
                                }

                                List<Map<String, dynamic>> assignmentList = [];
                                assignments.values.forEach((value) {
                                  var assignment =
                                      Map<String, dynamic>.from(value);
                                  if (assignment['semester'] == userSemester &&
                                      assignment['course'] == userCourse &&
                                      assignment['department'] ==
                                          userDepartment) {
                                    assignmentList.add(assignment);
                                  }
                                });

                                assignmentList.sort((a, b) {
                                  DateTime deadlineA =
                                      DateTime.parse(a['deadline']);
                                  DateTime deadlineB =
                                      DateTime.parse(b['deadline']);
                                  return deadlineA.compareTo(deadlineB);
                                });

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: assignmentList.length,
                                  itemBuilder: (context, index) {
                                    var assignment = assignmentList[index];
                                    return Container(
                                      margin: EdgeInsets.all(10.0),
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            subject["subjectname"] ?? '',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Deadline : ${addOneDay(assignment['deadline'])}",
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                          Text(
                                            "Department: ${assignment['department']}",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            "Semester: ${assignment['semester']}",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            "Course: ${assignment['course']}",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          const Text(
                            'List of Subjects ',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // GridView.count(
                          //     shrinkWrap: true,
                          //     physics: NeverScrollableScrollPhysics(),

                          //     crossAxisCount: 2,
                          //     children: [
                          //       //iterated from the list

                          //     ],
                          //   ),
                          Container(
                            height: 150,
                            // width: 500,

                            child: FirebaseAnimatedList(
                              query: _dataReference.child('subjects'),
                              itemBuilder: (BuildContext context,
                                  DataSnapshot snapshot,
                                  Animation<double> animation,
                                  int index) {
                                var value = Map<String, dynamic>.from(
                                    snapshot.value as Map);
                                return GestureDetector(
                                  onTap: () {
                                    print(
                                        "The snapshot key is ::${snapshot.key}");
                                    navigateToAllAssignment(
                                        snapshot.key ?? '', false);
                                  },
                                  child: Container(
                                    height: 100,
                                    color:
                                        const Color.fromRGBO(255, 235, 59, 1),
                                    margin: EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            value['subjectcode'] ?? '',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            value['subjectname'] ?? '',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const Text(
                            'Enrolled Courses',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            color: Colors.blue,
                            // height: 150,
                            child: FutureBuilder<DatabaseEvent>(
                              future: _dataReference.child('subjects').once(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DatabaseEvent> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child:
                                          CircularProgressIndicator()); // Show loading indicator while data is being fetched
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                // Extract DataSnapshot from DatabaseEvent
                                DataSnapshot dataSnapshot =
                                    snapshot.data!.snapshot;

                                // Collect all courses from all subjects without repetition
                                Set<String> courseSet = Set<String>();
                                Map<dynamic, dynamic>? subjectsData =
                                    dataSnapshot.value
                                        as Map<dynamic, dynamic>?;
                                if (subjectsData != null) {
                                  subjectsData.forEach((key, value) {
                                    var subject =
                                        value as Map<dynamic, dynamic>;
                                    var assignments = subject['Assigments']
                                        as Map<dynamic, dynamic>?;
                                    if (assignments != null) {
                                      assignments.values.forEach((assignment) {
                                        var course = (assignment
                                            as Map<dynamic, dynamic>)['course'];
                                        if (course != null) {
                                          courseSet.add(course);
                                        }
                                      });
                                    }
                                  });
                                }

                                // Convert the set of courses to a list and sort it
                                List<String> courseList = courseSet.toList();
                                courseList.sort();

                                // Display unique courses
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: courseList.length,
                                  itemBuilder: (context, index) {
                                    var course = courseList[index];
                                    return Container(
                                      margin: EdgeInsets.all(10.0),
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        course ?? '',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const Text(
                            'Submitted Assignments',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.amber,
                                ),
                                Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.orange,
                                ),
                                Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.brown,
                                ),
                                Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.red,
                                ),
                                Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.green,
                                ),
                                Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            child: Text(
                              'Suggestion/ Complaines',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
        onPressed: () {
          if (isTeacher) {
            navigateToAddSubject();
          }
        },
      ),
    );
  }
}
