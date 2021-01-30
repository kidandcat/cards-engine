import 'package:flutter/material.dart';

import 'networking.dart';

class Lobby extends StatelessWidget {
  final Networking nk = Networking();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Text('Lobby ${nk.userdata.email}'),
      );
}
