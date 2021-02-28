import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gamecardv2.dart';
import 'socket.dart';

class GameState extends GetxController {
  var cards = <GameCardV2>[].obs;
  var players = <Presence>[].obs;
  var dashboardKey = UniqueKey().obs;
}
