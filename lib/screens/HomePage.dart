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
  late int id;
  var user;
  bool isLoad = false;
  DatabaseReference _dataReference = FirebaseDatabase.instance.ref();
  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    this.getUser();
  }

  navigateToAllAssignment(id) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AllAssignment(id:id);
    }));
  }

  navigateToAddSubject() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddSubject();
    }));
  }

  checkAuthentication() async {
    await FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }));
      }
    });
  }

  getUser() async {
    var firebaseuser = await FirebaseAuth.instance.currentUser!;
    await firebaseuser.reload();
    firebaseuser = await FirebaseAuth.instance.currentUser!;
    setState(() {
      this.user = firebaseuser;
      isLoad = true;
    });
  }

  logout() async {
    await FirebaseAuth.instance.signOut();
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
                //firebase anmated List VIew
                child: FirebaseAnimatedList(
                  query: _dataReference,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    var value =
                        Map<String, dynamic>.from(snapshot.value as Map);
                    return GestureDetector(
                      onTap: () {
                        navigateToAllAssignment(snapshot.key);
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 2.0,
                        child: Container(
                          margin: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(value['subjectcode'] == null
                                  ? ''
                                  : '${value['subjectcode']} ' ,style: TextStyle(
                                    color: Colors.black,
                                  ),),
                              Text(value['subjectname'] == null
                                  ? ''
                                  : "${value['subjectname']}" ,style: TextStyle(
                                    color: Colors.black,
                                  ),),
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
