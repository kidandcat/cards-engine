import 'package:cartas/gameengine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gamecard.dart';
import 'gamestate.dart';

class Dashboard extends StatefulWidget {
  final GameEngine ge;
  Dashboard(this.ge);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GameState c = Get.put(GameState());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => KeyedSubtree(
        key: c.dashboardKey.value,
        child: Container(
          child: Stack(
            children: c.cards
                .map((card) => GameCardWidget(card, card.value.key))
                .toList(),
          ),
        ),
      ),
    );
  }
}
