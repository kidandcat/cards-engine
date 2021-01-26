import 'package:cartas/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'deck.dart';
import 'gamecard.dart';
import 'gamestate.dart';

void main() {
  runApp(GetMaterialApp(home: Dashboard()));
  GameController();
}

class GameController {
  final GameState c = Get.put(GameState());
  GameController() {
    GlobalState.topLeft.newCard(GameCard(color: Colors.blue, name: '1').obs);
    GlobalState.topLeft.newCard(GameCard(color: Colors.blue, name: '2').obs);
    GlobalState.topLeft.newCard(GameCard(color: Colors.blue, name: '3').obs);
    GlobalState.topRight.newCard(GameCard(color: Colors.red, name: '4').obs);
    GlobalState.topRight.newCard(GameCard(color: Colors.red, name: '5').obs);
    GlobalState.topRight.newCard(GameCard(color: Colors.red, name: '6').obs);
    GlobalState.topRight.newCard(GameCard(color: Colors.red, name: '7').obs);
    GlobalState.topRight.newCard(GameCard(color: Colors.red, name: '8').obs);
    GlobalState.center.newCard(GameCard(color: Colors.yellow, name: '9').obs);
    GlobalState.center.newCard(GameCard(color: Colors.yellow, name: '10').obs);
    GlobalState.center.newCard(GameCard(color: Colors.yellow, name: '11').obs);
  }
}
