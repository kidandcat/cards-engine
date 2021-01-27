import 'package:cartas/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'deck.dart';
import 'gamecard.dart';

class GameEngine {
  Deck topLeft;
  Deck topRight;
  Deck center;

  GameEngine(BuildContext context) {
    topLeft = Deck(
      name: 'TopLeft',
      spacingY: 2,
      spacingX: 2,
      left: Config.dashboardMargin,
      top: Config.dashboardMargin,
    );
    topRight = Deck(
      name: 'TopRight',
      top: Config.dashboardMargin,
      left: context.size.width - GameCard.width - Config.dashboardMargin,
    );
    center = Deck(
      name: 'Center',
      spacingX: 3,
      spacingY: 3,
      left: context.size.width / 2 - GameCard.width / 2,
      top: context.size.height / 2 - GameCard.height / 2,
    );

    for (var i = 0; i < 10; i++) {
      topLeft.newCard(GameCard(
        color: Colors.blue,
        name: '$i',
        onTap: (card) {
          if (card.value.parent == topLeft) {
            topRight.moveOnBottom(card);
          } else if (card.value.parent == topRight) {
            center.moveOnBottom(card);
          } else if (card.value.parent == center) {
            topLeft.moveOnBottom(card);
          }
        },
      ).obs);
    }
  }
}
