import 'package:cartas/gameengine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gamecard.dart';
import 'gamestate.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GameState c = Get.put(GameState());
  GameEngine ge;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => ge = GameEngine(context));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(
        () => Stack(
          children: c.cards.map((card) => GameCardWidget(card)).toList(),
        ),
      ),
    );
  }
}
