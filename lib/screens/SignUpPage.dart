import 'dart:ffi';
import 'package:firebase_database/firebase_database.dart';
import 'package:agc/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GlobalKey<FormState> _key = GlobalKey();
  String username = '';
  String password = '';
  

  bool _autovalidate = false;
  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  checkAuthentication() async {
    await FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        // if (event.emailVerified) {
        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        //     return HomePage();
        //   }));
        // } else {
        //   FirebaseAuth.instance.signOut();
        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        //     return LoginScreen();
        //   }));
        // }
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      }
    });
  }

  Registerprocess(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      print(email);
      String domain = email.split('@').last;
      List<String> teacherDomains = ['agc.edu', 'college.edu', 'school.edu'];
      bool isTeacher =
          teacherDomains.any((teacherDomains) => domain == teacherDomains);
      print("isTeacher is : ${isTeacher}");
      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .set({'email': email, 'isTeacher': isTeacher});
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
  }
//   Future<void> Registerprocess(String email, String password) async {
//   try {
//     UserCredential userCredential = await FirebaseAuth.instance
//         .createUserWithEmailAndPassword(email: email, password: password);

//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null && !user.emailVerified) {
//       await user.sendEmailVerification();
//       print('Verification email has been sent.');
//     }

//     print(email);
//     String domain = email.split('@').last;
//     List<String> teacherDomains = ['agc.edu', 'college.edu', 'school.edu'];
//     bool isTeacher = teacherDomains.any((teacherDomain) => domain == teacherDomain);
//     print("isTeacher is : $isTeacher");

//     await FirebaseDatabase.instance
//         .ref()
//         .child('users')
//         .child(userCredential.user!.uid)
//         .set({'email': email, 'isTeacher': isTeacher});

//     // Notify user to check their email for verification
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Verify your email"),
//           content: Text("A verification email has been sent to $email. Please verify your email to continue."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   } on FirebaseAuthException catch (e) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Error"),
//           content: Text(e.code.toString()),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(15.0)),
              SizedBox(
                child: Image(
                  image: AssetImage('images/logo.png'),
                  width: 250.0,
                  height: 100.0,
                  fit: BoxFit.fill,
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                title: TextFormField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  validator: (input) {
                    if (input!.isEmpty) {
                      return "Enter Username";
                    }
                  },
                  decoration: InputDecoration(
                    label: Text('Username'),
                    labelStyle: TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.black),
                  ),
                  onSaved: (input) {
                    username = input!;
                  },
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              ListTile(
                leading: Icon(
                  Icons.password,
                  color: Colors.black,
                ),
                title: TextFormField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  obscureText: true,
                  validator: (input) {
                    if (input!.isEmpty && input.length > 7) {
                      return "Enter Password";
                    }
                  },
                  decoration: InputDecoration(
                    label: Text("Password"),
                    labelStyle: TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.black),
                  ),
                  onSaved: (input) {
                    password = input!;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.0),
              ),
              SizedBox(
                width: 300,
                child: MaterialButton(
                  onPressed: () {
                    _setValuesToKey();
                  },
                  child: Text("Sign Up"),
                  minWidth: 150.0,
                  height: 40,
                  color: const Color.fromARGB(255, 142, 37, 30),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.0),
              ),
              Text(
                "Have a account ? ",
                style: TextStyle(color: Colors.black),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return HomePage();
                  }));
                },
                child: Text(
                  "Login Here",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  _setValuesToKey() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      username = username.trim();
      password = password.trim();

      await Registerprocess(username, password);
      //create firebase account
    } else {
      setState(() {
        _autovalidate = true;
      });
    }
  }
}
