import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:docx_template/docx_template.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> results = [];
  Map<String, dynamic> subjects = {};

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  void fetchResults() async {
    DatabaseEvent resultEvent = await _dbRef.child('results').once();
    DatabaseEvent subjectEvent = await _dbRef.child('subjects').once();

    DataSnapshot resultSnapshot = resultEvent.snapshot;
    DataSnapshot subjectSnapshot = subjectEvent.snapshot;

    setState(() {
      results = (resultSnapshot.value as Map).values.map((e) => Map<String, dynamic>.from(e)).toList();
      subjects = Map<String, dynamic>.from(subjectSnapshot.value as Map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: results.isEmpty ? Center(child: CircularProgressIndicator()) : buildResultsTable(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          downloadResults(context);
        },
        child: Icon(Icons.download),
      ),
    );
  }

  Widget buildResultsTable() {
    List<TableRow> rows = [
      TableRow(
        children: [
          TableCell(child: Text('Student Univ Roll No', style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black))),
          TableCell(child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black))),
          TableCell(child: Text('Subject Code', style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black))),
          TableCell(child: Text('Semester', style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black))),
          TableCell(child: Text('Course', style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black))),
          TableCell(child: Text('Department', style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black))),
          TableCell(child: Text('College Roll No', style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black))),
          TableCell(child: Text('Batch', style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black))),
          TableCell(child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black))),
          TableCell(child: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black))),
        ],
      ),
    ];

    for (var result in results) {
      rows.add(
        TableRow(
          children: [
            TableCell(child: Text("${result['studentUnivRollNo']}" , style: TextStyle( color: Colors.black),)),
            TableCell(child: Text("${result['subname']}" , style: TextStyle( color: Colors.black),)),
            TableCell(child: Text("${result['subcode']}" , style: TextStyle( color: Colors.black),)),
            TableCell(child: Text("${result['userSemester']}" , style: TextStyle( color: Colors.black),)),
            TableCell(child: Text("${result['userCourse']}" , style: TextStyle( color: Colors.black),)),
            TableCell(child: Text("${result['userDepartment']}" , style: TextStyle( color: Colors.black),)),
            TableCell(child: Text("${result['userCollegeRollNo']}" , style: TextStyle( color: Colors.black),)),
            TableCell(child: Text("${result['userBatch']}" , style: TextStyle( color: Colors.black),)),
            TableCell(child: Text("${result['score'].toString()}" , style: TextStyle( color: Colors.black),)),
            TableCell(child: Text("${result['timestamp']}" , style: TextStyle( color: Colors.black),)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          border: TableBorder.all(),
          children: rows,
        ),
      ),
    );
  }

 void downloadResults(BuildContext context) async {
    final ByteData data = await rootBundle.load('assets/template.docx');
    final Uint8List bytes = data.buffer.asUint8List();

    final docx = await DocxTemplate.fromBytes(bytes);

    // Example content generation
    Content content = Content()
      ..add(TextContent("header", "Result Report"))
      ..add(TextContent("date", "Date: ${DateTime.now().toString()}"))
      ..add(TextContent("subject", "Subject: Math"))
      ..add(TextContent("score", "Score: 90"));

    final docGenerated = await docx.generate(content);
    final fileGenerated = File('generated.docx');
    if (docGenerated != null) {
      await fileGenerated.writeAsBytes(docGenerated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Results downloaded successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download results'),
        ),
      );
    }
  }
}
