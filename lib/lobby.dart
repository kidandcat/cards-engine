import 'package:cartas/room.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'networking.dart';
import 'swagger/apigrpc.swagger.dart';

class Lobby extends StatefulWidget {
  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  final Networking nk = Networking();
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
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                  ),
                  color: Colors.white,
                  onPressed: refreshMatches,
                ),
                Center(child: Text('Lobby')),
                TextButton(
                  child: Text('Create'),
                  onPressed: () async {
                    try {
                      await nk.createMatch('Test');
                      refreshMatches();
                    } on String catch (e) {
                      Get.defaultDialog(title: e);
                    }
                  },
                )
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
                          Container(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              matches[index].label,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Text('size: ${matches[index].size}'),
                          TextButton(
                            child: Text('Join'),
                            onPressed: () {
                              try {
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
      ));
}
