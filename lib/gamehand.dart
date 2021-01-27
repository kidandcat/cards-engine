import 'package:cartas/config.dart';
import 'package:cartas/gamecard.dart';
import 'package:get/get.dart';
import 'deck.dart';

class GameHand extends Deck {
  double originalLeft;

  GameHand({
    String name,
    double left: 0,
    double top: 0,
    void Function(Rx<GameCard>) onDragTop,
    void Function() refreshDashboard,
  }) : super(
            name: name,
            left: left,
            top: top,
            refreshDashboard: refreshDashboard) {
    spacingY = 0;
    originalLeft = left;
    onTap = (_) {
      toggle();
    };
    onDragLeft = (_) {
      if (!isOpen()) open();
      super.left = super.left - GameCard.width;
      refresh();
    };
    onDragRight = (_) {
      if (!isOpen()) open();
      super.left = super.left + GameCard.width;
      refresh();
    };
    close();
  }

  void open() {
    spacingX = GameCard.width + Config.handCardSpacingBetweenExpanded;
    refresh();
  }

  void close() {
    spacingX = GameCard.width / Config.handCardSpacingBetweenShrinkPercentage;
    super.left = originalLeft;
    refresh();
  }

  bool isOpen() =>
      GameCard.width + Config.handCardSpacingBetweenExpanded == spacingX;

  void toggle() {
    if (isOpen())
      close();
    else
      open();
    refresh();
  }
}
