import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gamecardv2.dart';
import 'gamestate.dart';

class Deck {
  final GameState c = Get.put(GameState());

  String name;

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
  double spacingX;
  double spacingY;
  int numberOfCards = 0;

  Deck({
    this.name,
    this.spacingX: 3,
    this.spacingY: 3,
    this.left: 0,
    this.top: 0,
    this.refreshDashboard,
  });

  void refresh() async {
    var myCards = c.cards.where((card) => card.parent.value == this);
    var index = 0;
    for (var card in myCards) {
      card.top.value = top + spacingY * index;
      card.left.value = left + spacingX * index;
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
      card.color.value = Colors.red;
    }
    oldParent = card.parent.value;
    card.parent.value = this;
    card.top.value = top + spacingY * index;
    card.left.value = left + spacingX * index;
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

  void newCard(GameCardV2 card) {
    c.cards.add(card);
    move(card, numberOfCards);
  }
}
