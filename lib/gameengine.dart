import 'dart:async';

import 'package:cartas/config.dart';
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
      spacingY: 2,
      spacingX: 2,
      left: Config.dashboardMargin,
      top: Config.dashboardMargin,
      refreshDashboard: refreshDashboard,
    );
    topRight = Deck(
      name: 'TopRight',
      top: Config.dashboardMargin,
      left: context.size.width - GameCard.width - Config.dashboardMargin,
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
      topLeft.moveOnBottom(card);
    };
    topRight.onDragDown = (card) {
      hand.moveOnBottom(card);
    };
    hand.onDragUp = (card) {
      print('onDragUp');
      topLeft.moveOnBottom(card);
    };

    for (var i = 0; i < 10; i++) {
      topLeft.newCard(GameCard(
        color: Colors.blue,
        name: '$i',
      ).obs);
    }

    refreshDashboard();
  }
}
