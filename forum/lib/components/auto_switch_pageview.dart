import 'package:flutter/material.dart';
import 'dart:async';
import 'media_card.dart';


class AutoSwitchPageView extends StatefulWidget {
  final Duration interval;
  final Duration transitionDuration;
  final List<CarouselCard> cards;

  AutoSwitchPageView({
    Key? key,
    this.interval = const Duration(seconds: 3),
    this.transitionDuration = const Duration(milliseconds: 500),
    required this.cards
  }) : super(key: key);

  @override
  _AutoSwitchPageViewState createState() => _AutoSwitchPageViewState(
    interval: interval,
    transitionDuration: transitionDuration,
    cards: cards
  );
}

class _AutoSwitchPageViewState extends State<AutoSwitchPageView> {

  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  final Duration interval;
  final Duration transitionDuration;
  final List<CarouselCard> cards;

  _AutoSwitchPageViewState({
    required this.interval,
    required this.transitionDuration,
    required this.cards,
  });

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(interval, (timer) {
      if( cards.length > 1) {
        _pageController.animateToPage(
          (_currentPage + 1) % cards.length,
          duration: transitionDuration,
          curve: Curves.easeInOut,
        );
      }
    });
    print('inner cards${cards}');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      children: this.cards,
    );
  }
}