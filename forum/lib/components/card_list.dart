import 'package:flutter/material.dart';


class CardList extends StatelessWidget {
  const CardList({super.key});

  static const cards = const <Widget>[
    Card(child: ListTile(title: Text('One-line ListTile'))),
    Card(
      child: ListTile(
        leading: FlutterLogo(),
        title: Text('One-line with leading widget'),
      ),
    ),
    Card(
      child: ListTile(
        title: Text('One-line with trailing widget'),
        trailing: Icon(Icons.more_vert),
      ),
    ),
    Card(
      child: ListTile(
        leading: FlutterLogo(),
        title: Text('One-line with both widgets'),
        trailing: Icon(Icons.more_vert),
      ),
    ),
    Card(
      child: ListTile(
        title: Text('One-line dense ListTile'),
        dense: true,
      ),
    ),
    Card(
      child: ListTile(
        leading: FlutterLogo(size: 56.0),
        title: Text('Two-line ListTile'),
        subtitle: Text('Here is a second line'),
        trailing: Icon(Icons.more_vert),
      ),
    ),
    Card(
      child: ListTile(
        leading: FlutterLogo(size: 72.0),
        title: Text('Three-line ListTile'),
        subtitle:
        Text('A sufficiently long subtitle warrants three lines.'),
        trailing: Icon(Icons.more_vert),
        isThreeLine: true,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // 禁止内部ListView滚动
              itemCount: cards.length,
              itemBuilder: (BuildContext context, int index) {
                print(index);
                return cards[index];
              },
            ),
          ],
        ),
      ),
    );
  }
}
