import 'package:cartas/gameengine.dart';
import 'package:cartas/lobby.dart';
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
  final GameState c = Get.put(GameState(), permanent: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Create GameEngine when context be ready to get Size
      c.ge.value = GameEngine(context);
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        child: Text('Start'),
                        onPressed: () {
                          c.ge.value.startMatch(widget.game.matchId);
                        },
                      ),
                      TextButton(
                        child: Text('Test'),
                        onPressed: () {
                          c.ge.value.startTest();
                        },
                      ),
                      TextButton(
                        child: Text('Leave'),
                        onPressed: () {
                          c.ge.value.dispose();
                          Get.off(Lobby());
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () {
                          c.ge.value.delete(widget.game.matchId);
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
