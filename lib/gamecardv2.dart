import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config.dart';
import 'deck.dart';
import 'gamestate.dart';

class GameCardV2 extends StatefulWidget {
  static const double width = 123;
  static const double height = 200;

  GameCardV2({int number, int suit, Color color, Deck parent}) {
    this.number.value = number;
    this.suit.value = suit;
    this.color.value = color;
    this.parent.value = parent;
  }

  StreamController<void> flipController = StreamController<void>();
  StreamSubscription<void> listener;
  RxInt number = 0.obs;
  RxInt suit = 0.obs;
  Rx<Deck> parent = Rx<Deck>();
  Rx<Color> color = Rx<Color>();
  RxBool isFlipped = false.obs;

  RxBool isMoving = false.obs;

  RxDouble top = 0.0.obs;
  RxDouble left = 0.0.obs;

  void flip() {
    flipController.add(null);
  }

  @override
  _GameCardWidgetState createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardV2>
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

    if (widget.listener != null) widget.listener.cancel();

    try {
      widget.listener = widget.flipController.stream.listen((event) {
        if (_animationStatus == AnimationStatus.dismissed) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    } catch (e) {
      print(
          'Error in flipController stream listen error:$e listener:${widget.listener}');
    }
  }

  @override
  Widget build(BuildContext context) => Obx(
        () => AnimatedPositioned(
          curve: Curves.easeInOut,
          duration: Config.animationDuration,
          top: widget.top.value,
          left: widget.left.value,
          onEnd: () {
            widget.isMoving.value = false;
            widget.color.value = Colors.blue;
          },
          child: GestureDetector(
            onTap: () {
              if (!widget.isMoving.value) widget.parent.value.onTap(widget);
            },
            onLongPress: () {
              widget.parent.value.onLongPress(widget);
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity < 0) {
                widget.parent.value.onDragUp(widget);
              } else {
                widget.parent.value.onDragDown(widget);
              }
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity < 0) {
                widget.parent.value.onDragLeft(widget);
              } else {
                widget.parent.value.onDragRight(widget);
              }
            },
            child: Transform(
              alignment: FractionalOffset.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(pi * _animation.value),
              child: _animation.value <= 0.5
                  ? Container(
                      width: GameCardV2.width,
                      height: GameCardV2.height,
                      decoration: BoxDecoration(
                        color: widget.color.value,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          "${widget.number.value}",
                          style: TextStyle(color: Colors.deepPurple[900]),
                        ),
                      ),
                    )
                  : Container(
                      width: GameCardV2.width,
                      height: GameCardV2.height,
                      decoration: BoxDecoration(
                        color: widget.color.value,
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
