import 'package:cartas/dashboard.dart';
import 'package:cartas/socket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'networking.dart';
import 'swagger/apigrpc.swagger.dart';

class GameRoom extends StatefulWidget {
  final ApiMatch game;
  GameRoom(this.game);

  @override
  _GameRoomState createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  final Networking nk = Networking();
  List<Presence> players = [];

  @override
  void initState() {
    super.initState();
    nk.socketMatchState.stream.listen((event) {
      print('RECEIVED MATCH STATE: $event');
    });

    nk.socketMatchPresence.stream.listen((event) {
      print('RECEIVED socketMatchPresence');
      setState(() {
        if (event.joins != null) {
          players.addAll(event.joins);
        }
        if (event.leaves != null) {
          event.leaves.forEach((p) {
            players.removeWhere((p2) => p2.user_id == p.user_id);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          child: Column(
            children: [
              Text('${widget.game.label} ${widget.game.tickRate}'),
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.all(30),
                    child: Text('${players[index].username}'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: TextButton(
                  child: Text('Start'),
                  onPressed: () {
                    nk.startMatch(widget.game.matchId);
                    Get.off(Dashboard());
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
