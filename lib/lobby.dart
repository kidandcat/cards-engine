import 'package:flutter/material.dart';

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
    nk.listMatches().then((value) {
      setState(() {
        matches = value.matches;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: matches != null
            ? Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: Text('Lobby ${nk.userdata.email}'),
                  ),
                  Expanded(
                    child: ListView.builder(
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
                                nk.joinMatch(matches[index].matchId);
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      );
}
