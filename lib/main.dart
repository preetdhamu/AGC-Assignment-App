import 'package:flutter/material.dart';
import 'screens/HomePage.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  String? apiKey = dotenv.env['API_KEY'];
  String? appId = dotenv.env['APP_ID'];
  String? messagingSenderId = dotenv.env['MESSAGE_SENDER_ID'];
  String? projectId = dotenv.env['PROJECT_ID'];
  String? storageBucket = dotenv.env['STORAGE_BUCKET'];

  if (apiKey != null &&
      appId != null &&
      messagingSenderId != null &&
      projectId != null &&
      storageBucket != null) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
      ),
    );
  } else {
    // ignore: avoid_print
   
    print("One or more environment variables are missing.");
    return; // Exit the application if environment variables are missing
  }

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