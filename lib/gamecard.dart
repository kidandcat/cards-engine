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

  double top = 0;
  double left = 0;

  GameCard({this.name, this.color, this.parent}) {
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
            onTap: () {
              if (card.value.parent == GlobalState.topLeft) {
                GlobalState.topRight.moveOnTop(card);
              } else if (card.value.parent == GlobalState.topRight) {
                GlobalState.center.moveOnTop(card);
              } else if (card.value.parent == GlobalState.center) {
                GlobalState.topLeft.moveOnTop(card);
              }
            },
            onDoubleTap: () {
              if (card.value.parent == GlobalState.topLeft) {
                GlobalState.topRight.moveOnBottom(card);
              } else if (card.value.parent == GlobalState.topRight) {
                GlobalState.center.moveOnBottom(card);
              } else if (card.value.parent == GlobalState.center) {
                GlobalState.topLeft.moveOnBottom(card);
              }
            },
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
