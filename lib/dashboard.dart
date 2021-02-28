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
    return Obx(
      () => KeyedSubtree(
        key: c.dashboardKey.value,
        // TODO: https://stackoverflow.com/questions/59483051/how-to-use-custommultichildlayout-customsinglechildlayout-in-flutter
        child: Stack(
          children: [widget.ge.renderUI(context), ...c.cards],
        ),
      ),
    );
  }
}
