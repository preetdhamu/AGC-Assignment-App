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
    _subjectname = _subjectname.toUpperCase();

    try {
      // Check if subject code already exists
      DataSnapshot codeSnapshot = await _databaseReference.child('subjects').child(_subjectcode).get();

      if (codeSnapshot.exists) {
        // Subject code already exists
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Subject code already exists. Please use a different code."),
        ));
        return; // Exit the function early
      }

      // Subject code does not exist, proceed with adding
      Subject sub = Subject(_subjectcode, _subjectname);
      await _databaseReference.child('subjects').child(_subjectcode).set(sub.toJson());
      print("Subject Created Successfully");
      navigateToLastScreen(context);

    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred while checking for duplicates."),
      ));
    }
  } else {
    setState(() {
      _autovalidate = true;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  Icons.label_important_outline_rounded,
                  color: Colors.black,
                ),
                title: TextFormField(
                  style: TextStyle( color : Colors.black ),
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
                  Icons.label_important_outline_rounded,
                  color: Colors.black,
                ),
                title: TextFormField(
                  style: TextStyle( color : Colors.black ),
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
                child: ElevatedButton(
                  onPressed: () {
                    _setValuesToKey();
                  },
                  child: Center(child: Text("Save" , style: TextStyle( color: const Color.fromARGB(255, 142, 37, 30),),)),
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
