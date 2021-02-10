import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gamecard.dart';
import 'socket.dart';

class GameState extends GetxController {
  var cards = <Rx<GameCard>>[].obs;
  var players = <Presence>[].obs;
  var dashboardKey = UniqueKey().obs;
}
