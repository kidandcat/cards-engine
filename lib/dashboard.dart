import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gamestate.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GameState c = Get.put(GameState(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Obx(
          () => KeyedSubtree(
            key: c.dashboardKey.value,
            child: Stack(
              children: [
                ...c.cards,
                ...c.ge.value.renderUI(context),
                ...c.ge.value.playerDeks.values
                    .map((deck) => deck.renderUI(context))
                    .toList(),
                c.ge.value.hand.renderUI(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
