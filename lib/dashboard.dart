import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gamecard.dart';
import 'gamestate.dart';

class Dashboard extends StatelessWidget {
  final GameState c = Get.put(GameState());

  @override
  Widget build(BuildContext context) => Container(
        child: Obx(
          () => Stack(
            children: c.cards.map((card) => GameCardWidget(card)).toList(),
          ),
        ),
      );
}
