import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'deck.dart';
import 'gamestate.dart';

class GameCard {
  String name;
  Deck parent;
  Deck previousParent;
  Color color;
  Offset position;
  Offset oldPosition;
  Animation animation;
  GameCard({this.name, this.color, this.parent}) {
    widget = GameCardWidget(this);
  }

  GameCardWidget widget;

  reParent(Deck newParent) {
    oldPosition = position;
    previousParent = parent;
    parent = newParent;
    previousParent.remove(this);
    parent.append(this);
  }

  @override
  String toString() {
    return ' GameCard($name) ';
  }
}

class GameCardWidget extends StatefulWidget {
  final GameCard card;
  GameCardWidget(this.card);

  @override
  _GameCardWidgetState createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardWidget> {
  final GameState c = Get.put(GameState());

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          if (c.topLeft.value.contains(widget.card)) {
            c.topRight.value.take(widget.card);
          } else if (c.topRight.value.contains(widget.card)) {
            c.topLeft.value.take(widget.card);
          } else if (c.center.value.contains(widget.card)) {
            c.topLeft.value.take(widget.card);
          }
        },
        child: Container(
          width: widget.card.parent.cardWidth,
          height: widget.card.parent.cardHeight,
          decoration: BoxDecoration(
            color: widget.card.color,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.green),
          ),
          child: Center(
            child: Text('Card'),
          ),
        ),
      );
}

class GameAnimation {
  GameCard target;
  Duration duration;
  Function(AnimationStatus) onDone;
  AnimationController controller;
  GameAnimation({this.target, this.duration, this.onDone});
}
