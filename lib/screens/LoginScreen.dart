import 'dart:math';

import 'package:agc/screens/SignUpPage.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
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
                  style:TextStyle(
                    color:Colors.black ,
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
                  style:TextStyle(
                    color:Colors.black ,
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
              Text("Don't have a account ? " ,
              style: TextStyle(
                color: Colors.black,
              ),),
              InkWell(
                onTap: () {
                  _navigateToSignUpPage();
                },
                child: Text("Register Here" ,
                style: TextStyle(
                  color: Colors.black,
                ),),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  _navigateToSignUpPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SignUpPage();
    }));
  }

  Future<String> _randomnumbergenerator(int max) async {
    return Random().nextInt(max).toString();
  }

  _loginprocess(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        return Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      });
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
//   Future<void> _loginprocess(String email, String password) async {
//   try {
//     UserCredential userCredential = await FirebaseAuth.instance
//         .signInWithEmailAndPassword(email: email, password: password);

//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       await user.reload(); // Reload user data to get the latest email verification status
//       user = FirebaseAuth.instance.currentUser; // Refresh user instance

//       if (user!.emailVerified) {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
//           return HomePage();
//         }));
//       } else {
//         showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               title: Text("Email not verified"),
//               content: Text("Please verify your email to continue. A verification email has been sent to $email."),
//               actions: [
//                 TextButton(
//                   onPressed: () async {
//                     await user!.sendEmailVerification();
//                     Navigator.of(context).pop();
//                   },
//                   child: Text("Resend Verification Email"),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text("OK"),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     }
//   } on FirebaseAuthException catch (e) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Error"),
//           content: Text(e.message ?? "An error occurred"),
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

  _setValuesToKey() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      username = username.trim();
      password = password.trim();
      // String randomNumber = await _randomnumbergenerator(1000);
      _loginprocess(username, password);
    } else {
      setState(() {
        _autovalidate = true;
      });
    }
  }
}
