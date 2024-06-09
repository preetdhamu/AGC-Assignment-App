import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileStudent extends StatefulWidget {
  @override
  _ProfileStudentState createState() => _ProfileStudentState();
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
  String? _profileImageUrl;
  final picker = ImagePicker();

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
          _batchController.text = data['batch'] ?? '';
          _courseController.text = data['course'] ?? '';
          _collegeRollController.text = data['collegeRollNo'] ?? '';
          _univRollController.text = data['univRollNo'] ?? '';
          _profileImageUrl = data['profilePhoto'] ?? '';
          _departmentController.text = data['department'] ?? '';
          _semController.text = data['semester'] ?? '';
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

          await userRef.update({
            'batch': _batchController.text.toUpperCase().trim(),
            'course': _courseController.text.toUpperCase().trim(),
            'collegeRollNo': _collegeRollController.text.toUpperCase().trim(),
            'univRollNo': _univRollController.text.toUpperCase().trim(),
            'profilePhoto': photoUrl,
            'department': _departmentController.text.toUpperCase().trim(),
            'semester': _semController.text.toUpperCase().trim(),
          });

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CircleAvatar(
                radius: 75, // This controls the size of the circle
                backgroundColor: Colors.grey[200],
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
              TextFormField(
                controller: _batchController,
                decoration: InputDecoration(labelText: 'Batch'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your batch';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _courseController,
                decoration: InputDecoration(labelText: 'Course'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your course';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _semController,
                decoration: InputDecoration(labelText: 'Semester'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Semester';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(labelText: 'Department'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Department';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _collegeRollController,
                decoration: InputDecoration(labelText: 'College Roll No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your college roll number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _univRollController,
                decoration: InputDecoration(labelText: 'University Roll No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your university roll number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print(_profileImage.toString());
                  _updateProfile();
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
