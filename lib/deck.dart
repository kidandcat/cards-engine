import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gamecard.dart';
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
  void Function(Rx<GameCard>) onTap = (_) {};
  void Function(Rx<GameCard>) onLongPress = (_) {};
  void Function(Rx<GameCard>) onDragUp = (_) {};
  void Function(Rx<GameCard>) onDragDown = (_) {};
  void Function(Rx<GameCard>) onDragRight = (_) {};
  void Function(Rx<GameCard>) onDragLeft = (_) {};
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
    var myCards = c.cards.where((card) => card.value.parent == this);
    var index = 0;
    for (var card in myCards) {
      card.update((val) {
        val.top = top + spacingY * index;
        val.left = left + spacingX * index;
      });
      index++;
    }
  }

  int indexOf(Rx<GameCard> card) {
    if (card.value.parent != this) throw 'card is not in this Deck';
    var myCards = c.cards.where((card) => card.value.parent == this).toList();
    return myCards.indexOf(card);
  }

  void move(Rx<GameCard> card, int index) async {
    if (card.value.parent == this) throw 'Card already owned by Deck';
    Deck oldParent;
    card.update((val) {
      if (val.parent != null) {
        val.parent.numberOfCards--;
        val.isMoving = true;
        val.color = Colors.red;
      }
      oldParent = val.parent;
      val.parent = this;
      val.top = top + spacingY * index;
      val.left = left + spacingX * index;
    });
    numberOfCards++;
    refresh();
    if (oldParent != null) oldParent.refresh();
    refreshDashboard();
  }

  void moveOnTop(Rx<GameCard> card) {
    c.cards.remove(card);
    c.cards.add(card);
    c.cards.refresh();
    move(card, numberOfCards);
  }

  void moveOnBottom(Rx<GameCard> card) {
    c.cards.remove(card);
    c.cards.insert(0, card);
    c.cards.refresh();
    move(card, 0);
  }

  void newCard(Rx<GameCard> card) {
    c.cards.add(card);
    move(card, numberOfCards);
  }
}
