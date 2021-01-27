import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config.dart';
import 'deck.dart';
import 'gamestate.dart';

class GameCard {
  static const double width = 123;
  static const double height = 200;

  String name;
  Deck parent;
  Color color;
  Key key;
  Function(Rx<GameCard>) onTap;

  double top = 0;
  double left = 0;

  GameCard({this.name, this.color, this.parent, this.onTap}) {
    key = UniqueKey();
  }

  @override
  String toString() {
    return ' GameCard($name) ';
  }
}

class GameCardWidget extends StatelessWidget {
  final Rx<GameCard> card;
  final GameState c = Get.put(GameState());
  GameCardWidget(this.card);

  @override
  Widget build(BuildContext context) => Obx(
        () => AnimatedPositioned(
          key: card.value.key,
          curve: Curves.easeInOut,
          duration: Config.animationDuration,
          top: card.value.top,
          left: card.value.left,
          child: GestureDetector(
            onTap: () => card.value.onTap(card),
            child: Container(
              width: GameCard.width,
              height: GameCard.height,
              decoration: BoxDecoration(
                color: card.value.color,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: Colors.green),
              ),
              child: Center(
                child: Text(
                  "${card.value.name}",
                  style: TextStyle(color: Colors.deepPurple[900]),
                ),
              ),
            ),
          ),
        ),
      );
}
