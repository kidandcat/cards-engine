import 'package:cartas/gamecardv2.dart';
import 'package:cartas/gameengine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Obx(
          () => KeyedSubtree(
            key: c.dashboardKey.value,
            child: Stack(
              children: [...c.cards, widget.ge.renderUI(context)],
            ),
          ),
        ),
      ),
    );
  }
}
