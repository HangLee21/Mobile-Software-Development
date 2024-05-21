import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<String>();
    _startStreaming();
  }

  void _startStreaming() async {
    var client = http.Client();
    var request = http.Request('GET', Uri.parse('http://your-server-address/chat-stream?userId=123&content=hello'));

    var response = await client.send(request);

    response.stream
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((data) {
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
            return Center(child: Text('Data: ${snapshot.data}'));
          }
        },
      ),
    );
  }
}
