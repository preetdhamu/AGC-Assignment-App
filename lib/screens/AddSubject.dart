import 'package:agc/model/Subject.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddSubject extends StatefulWidget {
  @override
  State<AddSubject> createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  String _subjectname = '';
  String _subjectcode = '';
  bool _autovalidate = false;
  GlobalKey<FormState> _key = GlobalKey();
  navigateToLastScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  _setValuesToKey() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      _subjectname = _subjectname.trim();
      _subjectcode = _subjectcode.trim();
      _subjectcode = _subjectcode.toUpperCase();

      Subject sub = Subject(_subjectcode, _subjectname);
      await _databaseReference.child(_subjectcode).set(sub.toJson());
      print("Subject Created SuccessFully ");
      navigateToLastScreen(context);
    } else {
      setState(() {
        _autovalidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 177, 220, 255),
      appBar: AppBar(
        title: Text("Add Subject"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              ListTile(
                leading: Icon(
                  Icons.data_object,
                  color: Colors.black,
                ),
                title: TextFormField(
                  validator: (input) {
                    if (input!.isEmpty) {
                      return "Enter Subject Name";
                    }
                  },
                  decoration: InputDecoration(
                    label: Text('Subject Name'),
                    labelStyle: TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.black),
                  ),
                  onSaved: (input) {
                    _subjectname = input!;
                  },
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              ListTile(
                leading: Icon(
                  Icons.data_object,
                  color: Colors.black,
                ),
                title: TextFormField(
                  validator: (input) {
                    if (input!.isEmpty) {
                      return "Enter Subject Code";
                    }
                  },
                  decoration: InputDecoration(
                    label: Text('Subject Code'),
                    labelStyle: TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.black),
                  ),
                  onSaved: (input) {
                    _subjectcode = input!;
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
                  child: Text("Save"),
                  minWidth: 150.0,
                  height: 40,
                  color: const Color.fromARGB(255, 142, 37, 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
