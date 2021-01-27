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

  bool isMoving = false;

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
  final GameState c = Get.put(GameState());
  final Rx<GameCard> card;
  GameCardWidget(this.card);

  @override
  Widget build(BuildContext context) => Obx(
        () => AnimatedPositioned(
          key: card.value.key,
          curve: Curves.easeInOut,
          duration: Config.animationDuration,
          top: card.value.top,
          left: card.value.left,
          onEnd: () {
            card.update((val) {
              val.isMoving = false;
              val.color = Colors.blue;
            });
          },
          child: GestureDetector(
            onTap: () {
              if (!card.value.isMoving) card.value.parent.onTap(card);
            },
            onLongPress: () {
              card.value.parent.onLongPress(card);
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity < 0) {
                card.value.parent.onDragUp(card);
              } else {
                card.value.parent.onDragDown(card);
              }
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity < 0) {
                card.value.parent.onDragLeft(card);
              } else {
                card.value.parent.onDragRight(card);
              }
            },
            child: Container(
              width: GameCard.width,
              height: GameCard.height,
              decoration: BoxDecoration(
                color: card.value.color,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: Colors.green, width: 3),
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
