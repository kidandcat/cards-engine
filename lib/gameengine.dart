import 'dart:async';

import 'package:cartas/gamehand.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'deck.dart';
import 'gamecard.dart';
import 'gamestate.dart';

class GameEngine {
  final GameState c = Get.put(GameState());
  var dashboardRefresher = StreamController();
  Deck topLeft;
  Deck topRight;
  GameHand hand;

  bool waitingForRefresh = false;
  Timer refreshTimer;
  void refreshDashboard() {
    var shouldNotRefresh = c.cards.any((card) => card.value.isMoving);
    if (shouldNotRefresh) {
      waitingForRefresh = true;
      if (refreshTimer != null) refreshTimer.cancel();
      refreshTimer = Timer(Duration(seconds: 1), () {
        refreshDashboard();
      });
      return;
    }
    dashboardRefresher.add(null);
  }

  GameEngine(BuildContext context) {
    topLeft = Deck(
      name: 'TopLeft',
      spacingY: 0.2,
      spacingX: 0.2,
      left: 3,
      top: 3,
      refreshDashboard: refreshDashboard,
    );
    topRight = Deck(
      name: 'TopRight',
      top: 3,
      left: context.size.width - GameCard.width - 3,
      refreshDashboard: refreshDashboard,
    );
    hand = GameHand(
      name: 'Center',
      left: context.size.width / 2 - GameCard.width / 2,
      top: context.size.height - GameCard.height - 10,
      refreshDashboard: refreshDashboard,
    );

    topLeft.onTap = (card) {
      topRight.moveOnBottom(card);
    };
    topLeft.onDragDown = (card) {
      hand.moveOnBottom(card);
    };
    topRight.onTap = (card) {
      print('tapped card ${card.value.name}');
      card.value.flip();
    };
    topRight.onDragDown = (card) {
      hand.moveOnBottom(card);
    };
    hand.onDragUp = (card) {
      print('onDragUp');
      topLeft.moveOnBottom(card);
    };

    for (var i = 0; i < 100; i++) {
      topLeft.newCard(GameCard(
        color: Colors.blue,
        name: '$i',
      ).obs);
    }

    refreshDashboard();
  }
}
