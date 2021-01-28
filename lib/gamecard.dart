import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config.dart';
import 'deck.dart';
import 'gamestate.dart';

class GameCard {
  static const double width = 123;
  static const double height = 200;

  StreamController<void> flipController;
  String name;
  Deck parent;
  Color color;
  Key key;

  bool isMoving = false;

  double top = 0;
  double left = 0;

  GameCard({this.name, this.color, this.parent}) {
    flipController = StreamController<void>(sync: true);
    key = UniqueKey();
  }

  void flip() {
    print('Emitting to flipController in $name');
    flipController.add(null);
  }

  @override
  String toString() {
    return ' GameCard($name) ';
  }
}

class GameCardWidget extends StatefulWidget {
  final Rx<GameCard> card;
  final UniqueKey key;
  GameCardWidget(this.card, this.key);

  @override
  _GameCardWidgetState createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardWidget>
    with SingleTickerProviderStateMixin {
  final GameState c = Get.put(GameState());

  AnimationController _animationController;
  Animation _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Config.animationDuration);
    _animation = Tween(end: 1.0, begin: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });

    widget.card.value.flipController.stream.listen((event) {
      if (_animationStatus == AnimationStatus.dismissed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Obx(
        () => AnimatedPositioned(
          key: widget.key,
          curve: Curves.easeInOut,
          duration: Config.animationDuration,
          top: widget.card.value.top,
          left: widget.card.value.left,
          onEnd: () {
            widget.card.update((val) {
              val.isMoving = false;
              val.color = Colors.blue;
            });
          },
          child: GestureDetector(
            onTap: () {
              if (!widget.card.value.isMoving)
                widget.card.value.parent.onTap(widget.card);
            },
            onLongPress: () {
              widget.card.value.parent.onLongPress(widget.card);
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity < 0) {
                widget.card.value.parent.onDragUp(widget.card);
              } else {
                widget.card.value.parent.onDragDown(widget.card);
              }
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity < 0) {
                widget.card.value.parent.onDragLeft(widget.card);
              } else {
                widget.card.value.parent.onDragRight(widget.card);
              }
            },
            child: Transform(
              alignment: FractionalOffset.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(pi * _animation.value),
              child: _animation.value <= 0.5
                  ? Container(
                      width: GameCard.width,
                      height: GameCard.height,
                      decoration: BoxDecoration(
                        color: widget.card.value.color,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          "${widget.card.value.name}",
                          style: TextStyle(color: Colors.deepPurple[900]),
                        ),
                      ),
                    )
                  : Container(
                      width: GameCard.width,
                      height: GameCard.height,
                      decoration: BoxDecoration(
                        color: widget.card.value.color,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          "The other side",
                          style: TextStyle(color: Colors.deepPurple[900]),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      );
}
