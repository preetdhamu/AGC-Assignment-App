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
          "Login Screen",
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
              SizedBox(
                child: Image(
                  image: AssetImage('images/logo.png'),
                  width: 450.0,
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
      backgroundColor: Color.fromARGB(255, 177, 220, 255),
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

  _setValuesToKey() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      username = username.trim();
      password = password.trim();
      // String randomNumber = await _randomnumbergenerator(1000);
      String formattedUsername = "$username.agc@gmail.com";
      formattedUsername = formattedUsername.trim();
      _loginprocess(formattedUsername, password);
    } else {
      setState(() {
        _autovalidate = true;
      });
    }
  }
}
