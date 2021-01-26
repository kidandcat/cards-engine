import 'package:get/get.dart';
import 'dart:ui';
import 'deck.dart';
import 'gamecard.dart';

class GlobalState {
  static Deck topLeft = Deck(
    name: 'TopLeft',
    spacingY: 2,
    spacingX: 2,
    left: 3,
    top: 3,
  );
  static Deck topRight = Deck(
    name: 'TopRight',
    top: 0,
    left: window.physicalSize.width - GameCard.width - 20,
  );
  static Deck center = Deck(
    name: 'Center',
    spacingX: 3,
    spacingY: 3,
    top: window.physicalSize.height / 2 - GameCard.height / 2,
    left: window.physicalSize.width / 2 - GameCard.width / 2,
  );
}

class GameState extends GetxController {
  var cards = <Rx<GameCard>>[].obs;
}
