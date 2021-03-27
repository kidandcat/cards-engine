import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'config.dart';
import 'deck.dart';

class GameCardV2 extends HookWidget {
  static const double width = 123;
  static const double height = 200;
  static const double panThreshold = 40;

  GameCardV2({int number, int suit, Color color, Deck parent})
      : super(key: GlobalKey()) {
    this.number.value = number;
    this.suit.value = suit;
    this.color.value = color;
    this.parent.value = parent;
  }

  AnimationController flipController;
  RxInt number = 0.obs;
  RxInt suit = 0.obs;
  RxDouble elevation = 0.0.obs;
  Rx<Deck> parent = Rx<Deck>();
  Rx<Color> color = Rx<Color>();
  RxBool isMoving = false.obs;
  RxDouble top = 0.0.obs;
  RxDouble left = 0.0.obs;
  bool isUpward = true;
  List<bool> upwardQueue = <bool>[];

  Offset initialPan = Offset.zero;
  Offset panOffset = Offset.zero;

  void upward(bool yes) {
    if (flipController == null) {
      upwardQueue.add(yes);
      return;
    }
    if (yes && !isUpward) {
      flipController.reverse();
      isUpward = true;
    } else if (isUpward) {
      flipController.forward();
      isUpward = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Flip animation
    flipController = useAnimationController(
      duration: Config.animationDuration,
    );
    final animationValue =
        useAnimation(Tween(end: 1.0, begin: 0.0).animate(flipController));

    // process flip actions queued because the widget werent on screen yet
    useEffect(() {
      if (flipController == null) return null;
      for (var q in upwardQueue) {
        upward(q);
      }
      upwardQueue = [];
      return null;
    }, [flipController]);

    return Obx(
      () => AnimatedPositioned(
        curve: Curves.easeInOut,
        duration: Config.animationDuration,
        top: top.value,
        left: left.value,
        onEnd: () {
          isMoving.value = false;
          color.value = Colors.blue;
        },
        child: GestureDetector(
          onTap: () {
            if (!isMoving.value) parent.value.onTap(this);
          },
          onLongPress: () => parent.value.onLongPress(this),
          onPanStart: (details) => initialPan = details.globalPosition,
          onPanUpdate: (details) => panOffset = details.globalPosition,
          onPanEnd: (details) {
            if (panOffset.dx - initialPan.dx < panThreshold * -1) {
              parent.value.onDragLeft(this);
            } else if (panOffset.dx - initialPan.dx > panThreshold) {
              parent.value.onDragRight(this);
            }
            if (panOffset.dy - initialPan.dy < panThreshold * -1) {
              parent.value.onDragUp(this);
            } else if (panOffset.dy - initialPan.dy > panThreshold) {
              parent.value.onDragDown(this);
            }
          },
          child: Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(pi * animationValue),
            child: animationValue <= 0.5
                ? Material(
                    type: MaterialType.card,
                    elevation: elevation.value,
                    child: Container(
                      width: GameCardV2.width,
                      height: GameCardV2.height,
                      decoration: BoxDecoration(
                        color: color.value,
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              "${number.value}",
                              style: TextStyle(color: Colors.deepPurple[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Material(
                    type: MaterialType.transparency,
                    elevation: elevation.value,
                    child: Container(
                      width: GameCardV2.width,
                      height: GameCardV2.height,
                      child: Center(
                        child: Image.asset(
                          'assets/back.png',
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
