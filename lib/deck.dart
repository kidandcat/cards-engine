import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gamecardv2.dart';
import 'gamestate.dart';

class Deck {
  final GameState c = Get.put(GameState(), permanent: true);

  String playerId;
  String name = '';
  int points = 0;
  List<double> positionXRandomValues = [];
  List<double> positionYRandomValues = [];
  List<double> rotationRandomValues = [];
  double posRandomness;
  double rotRandomness;
  Function refreshDashboard;

  // position
  double top;
  double left;
  bool centerOrigin = false;

  // card config
  void Function(GameCardV2) onTap = (_) {};
  void Function(GameCardV2) onLongPress = (_) {};
  void Function(GameCardV2) onDragUp = (_) {};
  void Function(GameCardV2) onDragDown = (_) {};
  void Function(GameCardV2) onDragRight = (_) {};
  void Function(GameCardV2) onDragLeft = (_) {};
  void Function(GameCardV2) handleTap;
  void Function(GameCardV2) handleLongPress;
  void Function(GameCardV2) handleDragUp;
  void Function(GameCardV2) handleDragDown;
  void Function(GameCardV2) handleDragRight;
  void Function(GameCardV2) handleDragLeft;
  double spacingX;
  double spacingY;
  double rotation;
  int numberOfCards = 0;

  Deck({
    this.playerId,
    this.name,
    this.rotRandomness: 0,
    this.rotation: 0,
    this.posRandomness: 0,
    this.spacingX: 3,
    this.spacingY: 3,
    this.left: 0,
    this.top: 0,
    this.refreshDashboard,
  }) {
    generateRandomValues();
    reloadHandlers();
  }

  void generateRandomValues() {
    for (var i = 0; i < 100; i++) {
      positionXRandomValues.add(randomizePosition(left));
      positionYRandomValues.add(randomizePosition(top));
      rotationRandomValues.add(randomizeRotation(rotation));
    }
  }

  double randomizeRotation(double num) {
    if (rotRandomness == 0) return num;
    return (num - rotRandomness) +
        Random().nextInt(
            ((num + rotRandomness + 1) - (num - rotRandomness)).toInt());
  }

  double randomizePosition(double num) {
    if (posRandomness == 0) return num;
    return (num - posRandomness) +
        Random().nextInt(
            ((num + posRandomness + 1) - (num - posRandomness)).toInt());
  }

  void reloadHandlers() {
    handleTap = onTap;
    handleLongPress = onLongPress;
    handleDragDown = onDragDown;
    handleDragUp = onDragUp;
    handleDragLeft = onDragLeft;
    handleDragRight = onDragRight;
  }

  Future<void> refresh() async {
    var myCards = c.cards.where((card) => card.parent.value == this).toList();
    var index = 0;
    for (var card in myCards) {
      card.top.value = positionYRandomValues[index] + spacingY * index;
      card.left.value = positionXRandomValues[index] + spacingX * index;
      card.rotation.value = rotationRandomValues[index];
      card.elevation.value = index.toDouble();
      index++;
    }
  }

  GameCardV2 first() {
    return c.cards.firstWhere((card) => card.parent.value == this);
  }

  int indexOf(GameCardV2 card) {
    if (card.parent.value != this) throw 'card is not in this Deck';
    var myCards = c.cards.where((card) => card.parent.value == this).toList();
    return myCards.indexOf(card);
  }

  void move(GameCardV2 card, int index) async {
    if (card.parent.value == this) throw 'Card already owned by Deck';
    Deck oldParent;
    if (card.parent.value != null) {
      card.parent.value.numberOfCards--;
      card.isMoving.value = true;
    }
    oldParent = card.parent.value;
    card.parent.value = this;
    numberOfCards++;
    refresh();
    if (oldParent != null) oldParent.refresh();
    refreshDashboard();
  }

  void moveOnTop(GameCardV2 card) {
    c.cards.remove(card);
    c.cards.add(card);
    c.cards.refresh();
    move(card, numberOfCards);
  }

  void moveOnBottom(GameCardV2 card) {
    c.cards.remove(card);
    c.cards.insert(0, card);
    c.cards.refresh();
    move(card, 0);
  }

  void newCard(GameCardV2 card) async {
    c.cards.add(card);
    card.top.value = -500;
    card.left.value = -500;
    await refresh();
    refreshDashboard();
    await Future.delayed(Duration(milliseconds: 500));
    move(card, numberOfCards);
  }

  Widget renderUI(BuildContext context) {
    return Positioned(
      top: top + c.height() + 10,
      left: left - 5,
      child: Container(
        width: c.width() + 10,
        child: Column(
          children: [
            Text(name, softWrap: false),
            Text('$points', softWrap: false),
          ],
        ),
      ),
    );
  }
}
