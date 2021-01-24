import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'gamecard.dart';
import 'gamestate.dart';
import 'painters.dart';

class Deck {
  var cards = <GameCard>[].obs;
  String name;
  double spacingX;
  double spacingY;
  Painter painter;
  double cardWidth;
  double cardHeight;
  TickerProviderStateMixin tickerProvider;
  final GameState c = Get.put(GameState());

  Deck({
    this.name,
    this.spacingX: 3,
    this.spacingY: 3,
    this.painter,
    this.cardHeight: 200,
    this.cardWidth: 123,
  });

  setTickerProvider(TickerProviderStateMixin tp) => tickerProvider = tp;

  contains(GameCard card) => cards.contains(card);

  paint(FlowPaintingContext context, List<GameAnimation> animations) =>
      painter.paint(context, this, animations);

  append(GameCard card) {
    cards.add(card);
    card.parent = this;
  }

  remove(GameCard card) => cards.remove(card);

  take(GameCard card) {
    assert(tickerProvider != null);
    card.reParent(this);
    c.animations.add(GameAnimation(
      target: card,
      duration: Duration(seconds: 5),
      onDone: (status) {
        print('Animation status $status');
      },
    ));
  }
}
