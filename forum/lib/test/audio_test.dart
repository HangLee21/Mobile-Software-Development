import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(SlotMachineApp());

class SlotMachineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slot Machine',
      home: SlotMachineScreen(),
    );
  }
}

class SlotMachineScreen extends StatefulWidget {
  @override
  _SlotMachineScreenState createState() => _SlotMachineScreenState();
}

class _SlotMachineScreenState extends State<SlotMachineScreen> {
  final GlobalKey<SlotMachineState> _slotMachineKey = GlobalKey();

  void _startSpin() {
    _slotMachineKey.currentState?.startSpin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slot Machine'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlotMachine(
              key: _slotMachineKey,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startSpin,
              child: Text('Spin'),
            ),
          ],
        ),
      ),
    );
  }
}

class SlotMachine extends StatefulWidget {
  SlotMachine({Key? key}) : super(key: key);

  @override
  SlotMachineState createState() => SlotMachineState();
}

class SlotMachineState extends State<SlotMachine> {
  final List<String> symbols = ['🍒', '🍊', '🍋', '🍇', '🔔', '💎'];
  late List<String> result;
  late Timer _timer;
  late Random _random;
  bool spinning = false;

  @override
  void initState() {
    super.initState();
    _random = Random();
    result = List.generate(3, (index) => symbols[_random.nextInt(symbols.length)]);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startSpin() {
    if (!spinning) {
      spinning = true;
      _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
        setState(() {
          result.insert(0, result.removeLast());
        });
      });
      // Simulate stopping after 3 seconds
      Future.delayed(Duration(seconds: 3), stopSpin);
    }
  }

  void stopSpin() {
    _timer.cancel();
    setState(() {
      spinning = false;
    });
    // Check result and show alert for win
    if (result[0] == result[1] && result[1] == result[2]) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text('You win!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < result.length; i++)
          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              result[i],
              style: TextStyle(fontSize: 40),
            ),
          ),
      ],
    );
  }
}
