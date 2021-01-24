import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'deck.dart';
import 'gamecard.dart';
import 'gamestate.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final GameState c = Get.put(GameState());
  List<GameAnimation> animations = <GameAnimation>[];

  @override
  void initState() {
    c.animations.stream.listen((animation) {
      animation.controller = AnimationController(
        duration: animation.duration,
        vsync: this,
      );
      animations.add(animation);
    });
    super.initState();
  }

  Widget deckWidget(Deck deck) {
    return Flow(
      delegate: SampleFlowDelegate(deck, animations),
      children: deck.cards.map((card) => GameCardWidget(card)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        child: Obx(() => Stack(children: [
              deckWidget(c.topLeft.value),
              deckWidget(c.topRight.value),
              deckWidget(c.center.value),
            ])),
      );
}

class SampleFlowDelegate extends FlowDelegate {
  Deck deck;
  final GameState c = Get.put(GameState());
  final List<GameAnimation> animations;
  SampleFlowDelegate(this.deck, this.animations);

  @override
  void paintChildren(FlowPaintingContext context) {
    deck.paint(context, animations);
  }

  @override
  bool shouldRepaint(SampleFlowDelegate oldDelegate) {
    return false;
  }
}
