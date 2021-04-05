import 'package:cartas/modals.dart';
import 'package:cartas/room.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'gamestate.dart';
import 'networking.dart';
import 'swagger/apigrpc.swagger.dart';

class Lobby extends StatefulWidget {
  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  final Networking nk = Networking();
  final GameState c = Get.put(GameState(), permanent: true);
  List<ApiMatch> matches;

  @override
  void initState() {
    super.initState();
    refreshMatches();
  }

  void refreshMatches() async {
    setState(() {
      matches = null;
    });
    await Future.delayed(Duration(seconds: 1));
    var res = await nk.listMatches();
    setState(() {
      matches = res.matches;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      icon: Icon(Icons.logout),
                      color: Colors.red,
                      onPressed: () => nk.logout(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      icon: Icon(Icons.person),
                      color: Colors.white,
                      onPressed: () {},
                    ),
                  ),
                  Center(child: Text('Lobby')),
                  IconButton(
                    key: Key('lobby_create'),
                    icon: Icon(
                      Icons.add,
                    ),
                    color: Colors.white,
                    onPressed: () async {
                      try {
                        Get.defaultDialog(
                            title: 'Name:',
                            backgroundColor: Colors.teal[900],
                            content: Modal(
                              child: ModalPartRoomName(
                                onSubmit: (value) async {
                                  await nk.createMatch(value);
                                  refreshMatches();
                                  Get.back();
                                },
                              ),
                            ));
                      } on String catch (e) {
                        Get.defaultDialog(title: e);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                    ),
                    color: Colors.white,
                    onPressed: refreshMatches,
                  ),
                ],
              ),
            ),
            Expanded(
              child: matches != null
                  ? ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF1a1f3a),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: Icon(Icons.highlight_remove),
                              color: Colors.red[800],
                              onPressed: () async {
                                c.delete.value = matches[index].matchId;
                                nk.joinMatch(matches[index].matchId);
                                Get.off(GameRoom(matches[index]));
                              },
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              padding: const EdgeInsets.only(right: 20),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Text(
                                      matches[index].label,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text('size: ${matches[index].size}'),
                            TextButton(
                              key: Key('room_${matches[index].label}'),
                              child: Text('Join'),
                              onPressed: () {
                                try {
                                  c.reset();
                                  nk.joinMatch(matches[index].matchId);
                                  Get.off(GameRoom(matches[index]));
                                } on StateError catch (e) {
                                  print(e);
                                  Get.defaultDialog(title: e.message);
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      );
}
