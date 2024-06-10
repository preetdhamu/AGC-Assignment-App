import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileStudent extends StatefulWidget {
  final bool isTeacher;
  ProfileStudent({required this.isTeacher});
  @override
  _ProfileStudentState createState() => _ProfileStudentState(this.isTeacher);
}

class _ProfileStudentState extends State<ProfileStudent> {
  final _formKey = GlobalKey<FormState>();

  final _batchController = TextEditingController();
  final _semController = TextEditingController();
  final _courseController = TextEditingController();
  final _collegeRollController = TextEditingController();
  final _univRollController = TextEditingController();
  final _departmentController = TextEditingController();
  File? _profileImage;
  final _nameController = TextEditingController();
  String? _profileImageUrl;
  final picker = ImagePicker();
  bool isTeacher;

  _ProfileStudentState(this.isTeacher);
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    print("User is :${user} \n");
    if (user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(user.uid);

      final snapshot = await userRef.get();
      final data = snapshot.value as Map?;

      if (data != null) {
        setState(() {
          _profileImageUrl = data['profilePhoto'] ?? '';
          if (!isTeacher) {
            _batchController.text = data['batch'] ?? '';
            _courseController.text = data['course'] ?? '';
            _collegeRollController.text = data['collegeRollNo'] ?? '';
            _univRollController.text = data['univRollNo'] ?? '';
            _departmentController.text = data['department'] ?? '';
            _semController.text = data['semester'] ?? '';
          } else {
            _nameController.text = data['name'] ?? '';
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      } else {
        print("No Image selected");
      }
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          String? photoUrl;

          if (_profileImage != null) {
            photoUrl = await _uploadProfileImage(user.uid);
          } else {
            photoUrl = _profileImageUrl;
          }

          await user.updatePhotoURL(photoUrl);
          await user.reload();
          user = FirebaseAuth.instance.currentUser;

          DatabaseReference userRef =
              FirebaseDatabase.instance.ref().child('users').child(user!.uid);
          if (!isTeacher) {
            await userRef.update({
              'batch': _batchController.text.toUpperCase().trim(),
              'course': _courseController.text.toUpperCase().trim(),
              'collegeRollNo': _collegeRollController.text.toUpperCase().trim(),
              'univRollNo': _univRollController.text.toUpperCase().trim(),
              'profilePhoto': photoUrl,
              'department': _departmentController.text.toUpperCase().trim(),
              'semester': _semController.text.toUpperCase().trim(),
            });
          }else{
            await userRef.update({
              'profilePhoto': photoUrl,
              'name':_nameController.text.toUpperCase().trim(),
            });
          }

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
        } catch (e) {
          print('${e.toString()}');
        }
      }
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');
      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _batchController.dispose();
    _courseController.dispose();
    _collegeRollController.dispose();
    _univRollController.dispose();
    _departmentController.dispose();
    _semController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Update Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CircleAvatar(
                radius: 75, // This controls the size of the circle
                backgroundColor: const Color.fromARGB(
                                            255, 209, 209, 209),

                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!) as ImageProvider
                    : _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                child: _profileImageUrl == null && _profileImage == null
                    ? Text(
                        'No image selected.',
                        style: TextStyle(color: Colors.black),
                      )
                    : null,
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Profile Image'),
              ),
              !isTeacher ? TextFormField(
                style: TextStyle( color : Colors.black ),
                controller: _batchController,
                decoration: InputDecoration(labelText: 'Batch'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your batch';
                  }
                  return null;
                },
              ): SizedBox.shrink(),
              !isTeacher ? TextFormField(
                style: TextStyle( color : Colors.black ),
                controller: _courseController,
                decoration: InputDecoration(labelText: 'Course'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your course';
                  }
                  return null;
                },
              ) : SizedBox.shrink(),
              !isTeacher ? TextFormField(
                style: TextStyle( color : Colors.black ),
                controller: _semController,
                decoration: InputDecoration(labelText: 'Semester' ,fillColor: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Semester';
                  }
                  return null;
                },
              ): SizedBox.shrink(),
              !isTeacher ? TextFormField(
                style: TextStyle( color : Colors.black ),
                controller: _departmentController,
                decoration: InputDecoration(labelText: 'Department' ,fillColor: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Department';
                  }
                  return null;
                },
              ) : SizedBox.shrink(),
              !isTeacher ? TextFormField(
                style: TextStyle( color : Colors.black ),
                controller: _collegeRollController,
                decoration: InputDecoration(labelText: 'College Roll No' ,fillColor: Colors.black)  ,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your college roll number';
                  }
                  return null;
                },
              ) : SizedBox.shrink() ,
              !isTeacher ? TextFormField(
                style: TextStyle( color : Colors.black ),
                controller: _univRollController,
                decoration: InputDecoration(labelText: 'University Roll No' , fillColor: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your university roll number';
                  }
                  return null;
                },
              ) : SizedBox.shrink(),
              isTeacher ? TextFormField(
                style: TextStyle( color : Colors.black ),
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name' , fillColor: Colors.black) ,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Name';
                  }
                  return null;
                },
              ) : SizedBox.shrink(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print(_profileImage.toString());
                  _updateProfile();
                },
                child: Text('Update Profile' , style: TextStyle( color:const Color.fromARGB(
                                            255, 209, 209, 209),
 ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
