import 'package:flutter/material.dart';
import 'components/Input.dart';
import 'socket.dart';

class Modal extends StatelessWidget {
  Modal({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Center(
        child: child,
      ),
    );
  }
}

class ModalPartBet extends StatefulWidget {
  final int maxBet;
  final Function(int bet) onBet;

  const ModalPartBet({Key key, this.maxBet, this.onBet}) : super(key: key);

  @override
  _ModalPartBetState createState() => _ModalPartBetState();
}

class _ModalPartBetState extends State<ModalPartBet> {
  var selectedBet;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6 - 40,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.maxBet,
                itemBuilder: (context, index) => ListTile(
                  title: Text('$index'),
                  leading: Radio(
                    groupValue: selectedBet,
                    value: index,
                    onChanged: (value) {
                      setState(() {
                        selectedBet = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            key: Key('submit_bet'),
            onPressed: () => widget.onBet(selectedBet),
            child: Text('Submit'),
          )
        ],
      ),
    );
  }
}

class ModalPartRoomName extends StatefulWidget {
  final Function(String bet) onSubmit;

  const ModalPartRoomName({Key key, this.onSubmit}) : super(key: key);

  @override
  _ModalPartRoomNameState createState() => _ModalPartRoomNameState();
}

class _ModalPartRoomNameState extends State<ModalPartRoomName> {
  var name;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CustomImput(
            key: Key('room_name'),
            title: 'Name',
            description: 'Choose a name for your room',
            onChanged: (val) {
              setState(() {
                name = val;
              });
            },
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: TextButton(
              key: Key('submit_name'),
              onPressed: () => widget.onSubmit(name),
              child: Text('Submit'),
            ),
          )
        ],
      ),
    );
  }
}

class ModalPartFinished extends StatelessWidget {
  final Map<String, dynamic> points;
  final List<Presence> players;
  final Function() onSubmit;
  ModalPartFinished({this.points, this.onSubmit, this.players});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ...points.keys
              .map<Widget>((key) => Text(
                  '${players.firstWhere((p) => p.user_id == key).username}: ${points[key]}'))
              .toList(),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: TextButton(
              key: Key('submit_finish'),
              onPressed: () => onSubmit(),
              child: Text('End'),
            ),
          )
        ],
      ),
    );
  }
}
