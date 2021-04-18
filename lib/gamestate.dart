import 'package:cartas/gameengine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gamecardv2.dart';
import 'socket.dart';

class GameState extends GetxController {
  Rx<GameEngine> ge = Rx<GameEngine>();
  RxList<GameCardV2> cards = <GameCardV2>[].obs;
  RxList<Presence> players = <Presence>[].obs;
  Rx<UniqueKey> dashboardKey = UniqueKey().obs;
  RxString delete = ''.obs;
  RxDouble height = 100.0.obs;
  RxDouble width = (100 * 0.618).obs;

  void reset() {
    cards.clear();
    players.clear();
    dashboardKey.value = UniqueKey();
    delete.value = '';
    if (ge.value != null) {
      ge.value.dispose();
      ge.value.refreshDashboard();
    }
    print('- - - - STATE CLEANED - - - -');
  }
}
