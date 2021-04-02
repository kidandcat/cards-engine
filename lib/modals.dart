import 'package:flutter/material.dart';

class Modal extends StatelessWidget {
  Modal({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal[900],
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
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.maxBet,
          itemBuilder: (context, index) => ListTile(
            title: Text('$index'),
            leading: Radio(
              groupValue: 0,
              value: index,
              onChanged: (value) {
                setState(() {
                  selectedBet = value;
                });
              },
            ),
          ),
        ),
        TextButton(
          key: Key('submit_bet'),
          onPressed: () => widget.onBet(selectedBet),
          child: Text('Submit'),
        )
      ],
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
          TextField(
            key: Key('room_name'),
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