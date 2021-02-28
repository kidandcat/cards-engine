import 'package:cartas/config.dart';
import 'package:get/get.dart';
import 'deck.dart';
import 'gamecardv2.dart';

class GameHand extends Deck {
  double originalLeft;

  GameHand({
    String name,
    double left: 0,
    double top: 0,
    void Function(GameCardV2) onDragTop,
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
      super.left = super.left - GameCardV2.width;
      refresh();
    };
    onDragRight = (_) {
      if (!isOpen()) open();
      super.left = super.left + GameCardV2.width;
      refresh();
    };
    close();
  }

  void open() {
    spacingX = GameCardV2.width + Config.handCardSpacingBetweenExpanded;
    refresh();
  }

  void close() {
    spacingX = GameCardV2.width / Config.handCardSpacingBetweenShrinkPercentage;
    super.left = originalLeft;
    refresh();
  }

  bool isOpen() =>
      GameCardV2.width + Config.handCardSpacingBetweenExpanded == spacingX;

  void toggle() {
    if (isOpen())
      close();
    else
      open();
    refresh();
  }
}
