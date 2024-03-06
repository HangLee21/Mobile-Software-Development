import 'package:flutter/material.dart';
import 'package:forum/components/content_card.dart';

class CardList extends StatelessWidget {
  const CardList({
    super.key,
    required this.cards,
  });

  final List<ContentCard> cards;

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
