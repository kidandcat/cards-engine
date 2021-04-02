import 'package:cartas/config.dart';
import 'deck.dart';
import 'gamecardv2.dart';

class GameHand extends Deck {
  double originalLeft;
  int draggedPosition = 0;

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
    reloadHandlers();
    close();
  }

  @override
  void reloadHandlers() {
    handleTap = (card) {
      toggle();
      onTap(card);
    };
    handleDragLeft = (card) {
      dragLeft();
      onDragLeft(card);
    };
    handleDragRight = (card) {
      dragRight();
      onDragRight(card);
    };
    handleDragUp = (card) async {
      onDragUp(card);
      await Future.delayed(Duration(milliseconds: 500));
      toggle();
      toggle();
    };
    handleDragDown = (card) async {
      onDragDown(card);
      await Future.delayed(Duration(milliseconds: 500));
      toggle();
      toggle();
    };
  }

  void open() {
    spacingX = GameCardV2.width + Config.handCardSpacingBetweenExpanded;
    draggedPosition = 0;
    for (var i = 0; i < (numberOfCards - 1) / 2; i++) {
      dragLeft();
    }
    refresh();
  }

  void close() {
    spacingX = GameCardV2.width / Config.handCardSpacingBetweenShrinkPercentage;
    super.left = originalLeft;
    refresh();
  }

  void dragRight() {
    if (!isOpen()) open();
    if (draggedPosition <= 0) return;
    draggedPosition--;
    super.left = super.left + GameCardV2.width;
    refresh();
  }

  void dragLeft() {
    if (!isOpen()) open();
    if (draggedPosition >= numberOfCards - 1) return;
    draggedPosition++;
    super.left = super.left - GameCardV2.width;
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
