import 'package:flutter/material.dart';

import 'deck.dart';
import 'gamecard.dart';

abstract class Painter {
  paint(FlowPaintingContext context, Deck deck, List<GameAnimation> animations);
}

class PainterTopLeft extends Painter {
  paint(
    FlowPaintingContext context,
    Deck deck,
    List<GameAnimation> animations,
  ) {
    for (int i = context.childCount - 1; i >= 0; --i) {
      double dx = deck.spacingX * i;
      double dy = deck.spacingY * i;
      double modX = 0;
      double modY = 0;
      if (deck.cards[i].widget != null) {
        modX = deck.cards[i].oldPosition.dx -
            dx * deck.cards[i].movementAnimation.value;
        modY = deck.cards[i].oldPosition.dy -
            dy * deck.cards[i].movementAnimation.value;
        print('animating card $modX $modY');
      }
      context.paintChild(
        i,
        transform: Matrix4.translationValues(dx + modX, dy + modY, 0),
      );
      deck.cards[i].position = Offset(deck.spacingX * i, deck.spacingY * i);
    }
  }
}

class PainterTopRight extends Painter {
  paint(
    FlowPaintingContext context,
    Deck deck,
    List<GameAnimation> animations,
  ) {
    for (int i = context.childCount - 1; i >= 0; --i) {
      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          context.size.width - (deck.cardWidth + deck.spacingX * i),
          deck.spacingY * i,
          0,
        ),
      );
      deck.cards[i].position = Offset(
          context.size.width - (deck.cardWidth + deck.spacingX * i),
          deck.spacingY * i);
    }
  }
}

class PainterCenter extends Painter {
  paint(
    FlowPaintingContext context,
    Deck deck,
    List<GameAnimation> animations,
  ) {
    // var totalWidth = deck.cardWidth + (cards.length - 1) * deck.spacingX;
    for (int i = context.childCount - 1; i >= 0; --i) {
      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          (context.size.width / 2 - deck.cardWidth / 2 + deck.spacingX * i),
          context.size.height / 2 - deck.cardHeight / 2 + deck.spacingY * i,
          0,
        ),
      );
      deck.cards[i].position = Offset(
          (context.size.width / 2 - deck.cardWidth / 2 + deck.spacingX * i),
          context.size.height / 2 - deck.cardHeight / 2 + deck.spacingY * i);
    }
  }
}
