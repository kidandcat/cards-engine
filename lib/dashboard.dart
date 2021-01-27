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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Create GameEngine when context be ready to get Size
      ge = GameEngine(context);
      // Refresh Dashboard when GameEngine tell us to do it
      ge.dashboardRefresher.stream.listen((event) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   print('called after BUILD?');
    // });
    return Container(
      child: Stack(
        children: c.cards.map((card) => GameCardWidget(card)).toList(),
      ),
    );
  }
}
