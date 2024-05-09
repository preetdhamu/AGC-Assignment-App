// import 'package:agc/model/Subject.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';

// class AddTenant extends StatefulWidget {
//   @override
//   State<AddTenant> createState() => _AddTenantState();
// }

// class _AddTenantState extends State<AddTenant> {
//   DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
//   String _name = '';
//   String _rollno = '';
//   String _flatNumber = '';
//   bool _autovalidate = false;
//   GlobalKey<FormState> _key = GlobalKey();
//   navigateToLastScreen(BuildContext context) {
//     Navigator.of(context).pop();
//   }

//   _setValuesToKey() async {
//     if (_key.currentState!.validate()) {
//       _key.currentState!.save();
//       _name = _name.trim();
//       _rollno = _rollno.trim();
//       _flatNumber = _flatNumber.trim();

//       Subject sub = Tenant(_rollno, _flatNumber , _name);
//       await _databaseReference.child(_rollno).set(sub.toJson());
//       print("Tenant Created SuccessFully ");
//       navigateToLastScreen(context);
//     } else {
//       setState(() {
//         _autovalidate = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 177, 220, 255),
//       appBar: AppBar(
//         title: Text("Add Tenant"),
//         centerTitle: true,
//         backgroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: _key,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Padding(padding: EdgeInsets.symmetric(vertical: 15)),
//               ListTile(
//                 leading: Icon(
//                   Icons.data_object,
//                   color: Colors.black,
//                 ),
//                 title: TextFormField(
//                   validator: (input) {
//                     if (input!.isEmpty) {
//                       return "Enter Name";
//                     }
//                   },
//                   decoration: InputDecoration(
//                     label: Text('Name'),
//                     labelStyle: TextStyle(
//                         fontSize: 15.0,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.black),
//                   ),
//                   onSaved: (input) {
//                     _name = input!;
//                   },
//                 ),
//               ),
//               Padding(padding: EdgeInsets.symmetric(vertical: 15)),
//               ListTile(
//                 leading: Icon(
//                   Icons.data_object,
//                   color: Colors.black,
//                 ),
//                 title: TextFormField(
//                   validator: (input) {
//                     if (input!.isEmpty) {
//                       return "Enter Roll No ";
//                     }
//                   },
//                   decoration: InputDecoration(
//                     label: Text('Roll No'),
//                     labelStyle: TextStyle(
//                         fontSize: 15.0,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.black),
//                   ),
//                   onSaved: (input) {
//                     _rollno = input!;
//                   },
//                 ),
//               ),
//               Padding(padding: EdgeInsets.symmetric(vertical: 15)),
//               ListTile(
//                 leading: Icon(
//                   Icons.data_object,
//                   color: Colors.black,
//                 ),
//                 title: TextFormField(
//                   validator: (input) {
//                     if (input!.isEmpty) {
//                       return "Enter Flat Number";
//                     }
//                   },
//                   decoration: InputDecoration(
//                     label: Text('Roll No'),
//                     labelStyle: TextStyle(
//                         fontSize: 15.0,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.black),
//                   ),
//                   onSaved: (input) {
//                     _flatNumber = input!;
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.all(25.0),
//               ),
//               SizedBox(
//                 width: 300,
//                 child: MaterialButton(
//                   onPressed: () {
//                     _setValuesToKey();
//                   },
//                   child: Text("Save"),
//                   minWidth: 150.0,
//                   height: 40,
//                   color: const Color.fromARGB(255, 142, 37, 30),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
