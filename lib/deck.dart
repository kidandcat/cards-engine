import 'package:get/get.dart';
import 'gamecard.dart';
import 'gamestate.dart';

enum CardOrigin { TopLeft, TopRight, BottomLeft, BottomRight }

class Deck {
  final GameState c = Get.put(GameState());

  String name;
  // position
  double top;
  double left;
  bool centerOrigin = false;

  // card config
  CardOrigin origin;
  double spacingX;
  double spacingY;
  int numberOfCards = 0;

  Deck({
    this.name,
    this.spacingX: 3,
    this.spacingY: 3,
    this.left,
    this.top,
  });

  setNewCardPosition(Rx<GameCard> card) {
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

  void move(Rx<GameCard> card) async {
    await Future.delayed(Duration(milliseconds: 50));
    card.update((val) {
      if (val.parent != null) val.parent.numberOfCards--;
      val.parent = this;
    });
    numberOfCards++;
    setNewCardPosition(card);
  }

  void moveOnTop(Rx<GameCard> card) {
    c.cards.remove(card);
    c.cards.add(card);
    c.cards.refresh();
    move(card);
  }

  void moveOnBottom(Rx<GameCard> card) {
    c.cards.remove(card);
    c.cards.insert(0, card);
    c.cards.refresh();
    move(card);
  }

  void newCard(Rx<GameCard> card) {
    c.cards.add(card);
    move(card);
  }
}
