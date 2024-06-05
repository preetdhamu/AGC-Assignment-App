// import 'package:agc/screens/LoginScreen.dart';
// import 'package:agc/screens/SignUpPage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:flutter/material.dart';
// import 'package:agc/screens/AllAssignment.dart';
// import 'package:agc/screens/AddSubject.dart';
// import 'package:flutter/rendering.dart';

// class HomePage extends StatefulWidget {
//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late int id;
//   var user;
//   bool isLoad = false;
//   DatabaseReference _dataReference = FirebaseDatabase.instance.ref();
//   @override
//   void initState() {
//     super.initState();
//     this.checkAuthentication();
//     this.getUser();
//   }

//   navigateToAllAssignment(id) {
//     Navigator.push(context, MaterialPageRoute(builder: (context) {
//       return AllAssignment(id: id);
//     }));
//   }

//   navigateToAddSubject() {
//     Navigator.push(context, MaterialPageRoute(builder: (context) {
//       return AddSubject();
//     }));
//   }

//   checkAuthentication() async {
//     await FirebaseAuth.instance.authStateChanges().listen((user) {
//       if (user == null) {
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) {
//           return LoginScreen();
//         }));
//       }
//     });
//   }

//   getUser() async {
//     var firebaseuser = await FirebaseAuth.instance.currentUser!;
//     await firebaseuser.reload();
//     firebaseuser = await FirebaseAuth.instance.currentUser!;
//     setState(() {
//       this.user = firebaseuser;
//       isLoad = true;
//     });
//   }

//   logout() async {
//     await FirebaseAuth.instance.signOut();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 177, 220, 255),
//       appBar: AppBar(
//         title: Text("Home"),
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         actions: [
//           InkWell(
//             onTap: () {
//               logout();
//             },
//             child: Icon(Icons.logout),
//           ),
//         ],
//       ),
//       body: Center(
//         child: !isLoad
//             ? CircularProgressIndicator(
//                 color: Colors.red,
//               )
//             : Container(
//                 //firebase anmated List VIew
//                 child: FirebaseAnimatedList(
//                   query: _dataReference,
//                   itemBuilder: (BuildContext context, DataSnapshot snapshot,
//                       Animation<double> animation, int index) {
//                     var value =
//                         Map<String, dynamic>.from(snapshot.value as Map);
//                     return GestureDetector(
//                       onTap: () {
//                         print("The snapshow key is ::${snapshot.key}");
//                         navigateToAllAssignment(snapshot.key);
//                       },
//                       child: Card(
//                         color: Colors.white,
//                         elevation: 2.0,
//                         child: Container(
//                           margin: EdgeInsets.all(20.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 value['subjectcode'] == null
//                                     ? ''
//                                     : '${value['subjectcode']} ',
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               Text(
//                                 value['subjectname'] == null
//                                     ? ''
//                                     : "${value['subjectname']}",
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () {
//           navigateToAddSubject();
//         },
//       ),
//     );
//   }
// }

import 'package:agc/screens/LoginScreen.dart';
import 'package:agc/screens/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:agc/screens/AllAssignment.dart';
import 'package:agc/screens/AddSubject.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String id;
  User? user;
  bool isLoad = false;
  DatabaseReference _dataReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    checkAuthentication();
    getUser();
  }

  void navigateToAllAssignment(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AllAssignment(id: id);
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

        setState(() {
          user = firebaseUser;
          isLoad = true;
        });
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

  _deleteSubject() async {
    TextEditingController passwordController = TextEditingController();
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Do your want to delete the subject ?"),
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
                      if (passwordController.text.isNotEmpty ) {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          AuthCredential credential =
                              EmailAuthProvider.credential(
                                  email: user.email!,
                                  password: passwordController.text);
                          await user.reauthenticateWithCredential(credential);
                          await _dataReference.child(id).remove();

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Subject Deleted Successfully"),
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
                            return const AlertDialog(
                              title: Text("Error"),
                              content: Text("Fill the Credentials "),
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
      backgroundColor: Color.fromARGB(255, 177, 220, 255),
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          InkWell(
            onTap: () {
              logout();
            },
            child: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: !isLoad
            ? CircularProgressIndicator(
                color: Colors.red,
              )
            : Container(
                child: FirebaseAnimatedList(
                  query: _dataReference,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    var value =
                        Map<String, dynamic>.from(snapshot.value as Map);
                    return GestureDetector(
                      onTap: () {
                        print("The snapshot key is ::${snapshot.key}");
                        navigateToAllAssignment(snapshot.key ?? '');
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 2.0,
                        child: Container(
                          margin: EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  _deleteSubject();
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
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          navigateToAddSubject();
        },
      ),
    );
  }
}
