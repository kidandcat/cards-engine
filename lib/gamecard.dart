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

  StreamController<void> flipController = StreamController<void>();
  StreamSubscription<void> listener;
  int number = 0;
  int suit = 0;
  Deck parent;
  Color color;
  Key key = UniqueKey();
  bool isFlipped = false;

  bool isMoving = false;

  double top = 0;
  double left = 0;

  GameCard({this.number, this.suit, this.color, this.parent});

  void flip() {
    flipController.add(null);
  }

  @override
  String toString() {
    return ' GameCard($suit, $number) ';
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
  StreamSubscription<void> listener;

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

    if (widget.card.value.listener != null) widget.card.value.listener.cancel();

    try {
      widget.card.value.listener =
          widget.card.value.flipController.stream.listen((event) {
        if (_animationStatus == AnimationStatus.dismissed) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    } catch (e) {
      print(
          'Error in flipController stream listen error:$e listener:${widget.card.value.listener}');
    }
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
              child: _animation.value <= 0.5 ? front() : back(),
            ),
          ),
        ),
      );

  Widget front() => Container(
        width: GameCard.width,
        height: GameCard.height,
        decoration: BoxDecoration(
          color: widget.card.value.color,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.green, width: 3),
        ),
        child: Center(
          child: Text(
            "${widget.card.value.number}",
            style: TextStyle(color: Colors.deepPurple[900]),
          ),
        ),
      );

  Widget back() => Container(
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
      );
}
