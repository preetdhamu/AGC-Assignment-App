import 'package:flutter/material.dart';
import 'screens/HomePage.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyCGSW_HVB-yNXh9viN788GZ4PWwAiCTBSk",
              appId: "1:380668958200:android:1754545aeeca7e7092320d",
              messagingSenderId: "380668958200",
              projectId: "agcapp-9652p"))
      : await Firebase.initializeApp();
  runApp(myApp());
}

class myApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "AGC",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
