import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/constants.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Stream Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamPage(),
    );
  }
}

class StreamPage extends StatefulWidget {
  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  late StreamController<String> _streamController;
  late String text = '';
  @override
  void initState() {
    super.initState();
    _streamController = StreamController<String>();
    _startStreaming();
  }

  void _startStreaming() async {
    var client = http.Client();
    var url = Uri.parse('http://$BASEURL/api/ai/chat?userId=test23456&content=请问你和文心一言的关系');
    var requestBody = jsonEncode({
      'userId': 'test23456',
      'content': 'hello'
    });

    var request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = requestBody;


    request.headers.addAll({
      'Authorization': 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZXN0MjM0NTYiLCJpYXQiOjE3MTYzNDQ5NzEsImV4cCI6MTcxNjM4MDk3MX0.m4dytIfon-hFTqVJlk3LaBpNnXBc9PCj6rrgH4O3gGlLPxPGmaiCKcFEnrR1fefMF8IeHMZBnnPeqdK-rsRtsA' ?? '',
    });

    var response = await client.send(request);
    print(response.statusCode);

    response.stream
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((data) {
      if(data.isNotEmpty){
        text += data.trim().substring(5);
      }
      _streamController.add(data);
    }, onError: (error) {
      _streamController.addError(error);
    }, onDone: () {
      _streamController.close();
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stream Example'),
      ),
      body: StreamBuilder<String>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: Text('${text}'));
          }
        },
      ),
    );
  }
}
