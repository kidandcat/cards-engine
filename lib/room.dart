import 'package:cartas/dashboard.dart';
import 'package:cartas/gameengine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'gamestate.dart';
import 'swagger/apigrpc.swagger.dart';

class GameRoom extends StatefulWidget {
  final ApiMatch game;
  GameRoom(this.game);

  @override
  _GameRoomState createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  final GameState c = Get.put(GameState());
  GameEngine ge;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Create GameEngine when context be ready to get Size
      ge = GameEngine(context);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          child: Obx(
            () => Column(
              children: [
                Text('${widget.game.label} ${widget.game.tickRate}'),
                Expanded(
                  child: ListView.builder(
                    itemCount: c.players.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.all(30),
                      child: Text('${c.players[index].username}'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: TextButton(
                    child: Text('Start'),
                    onPressed: () {
                      ge.startMatch(widget.game.matchId);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
