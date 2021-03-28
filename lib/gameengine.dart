import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cartas/gamehand.dart';

import 'dashboard.dart';
import 'deck.dart';
import 'gamecardv2.dart';
import 'gamestate.dart';
import 'networking.dart';
import 'socket.dart';

enum GamePhase { BET_READY, BET_DONE, PLAY_READY, PLAY_DONE }

class GameEngine {
  final GameState c = Get.put(GameState());
  final Networking nk = Networking();
  Deck center;
  GameHand hand;

  // current match
  int roundCardNumber = 0;
  String matchId;
  RxString turnPlayerID = ''.obs;
  GameCardV2 cardSelected;
  bool gameStarted = false;
  bool waitingForRefresh = false;
  GamePhase phase = GamePhase.BET_READY;
  Map<String, Deck> playerDeks = {};
  List<double> positions;
  BuildContext context;

  Timer refreshTimer;
  void refreshDashboard() {
    var shouldNotRefresh = c.cards.any((card) => card.isMoving.value);
    if (shouldNotRefresh) {
      waitingForRefresh = true;
      if (refreshTimer != null) refreshTimer.cancel();
      refreshTimer = Timer(Duration(seconds: 1), () {
        refreshDashboard();
      });
      return;
    }
    c.dashboardKey.value = UniqueKey();
  }

  GameEngine(BuildContext _context) {
    context = _context;
    GameCardV2.precacheImages(context);
    positions = [
      10,
      context.size.width / 2,
      context.size.width - GameCardV2.width - 10
    ];
    center = Deck(
      name: 'Table',
      spacingY: 0.2,
      spacingX: 0.2,
      left: context.size.width / 2 - GameCardV2.width / 2,
      top: context.size.height / 2 - GameCardV2.height / 2,
      refreshDashboard: refreshDashboard,
    );
    hand = GameHand(
      name: 'Hand',
      left: context.size.width / 2 - GameCardV2.width / 2,
      top: context.size.height - GameCardV2.height - 10,
      refreshDashboard: refreshDashboard,
    );

    center.onTap = (card) {
      card.upward(!card.isUpward);
    };

    center.reloadHandlers();

    hand.onDragUp = (card) {
      print('onDragUp $phase');
      if (phase == GamePhase.PLAY_READY) {
        print('playCard');
        playCard(matchId, hand.indexOf(card));
        cardSelected = card;
      }
    };

    hand.reloadHandlers();
    refreshDashboard();

    nk.socketMatch.stream.listen((event) {
      print('socketMatch received $event');
    });

    nk.socketMatchPresence.stream.listen((event) {
      if (event.joins != null) {
        c.players.addAll(event.joins);
      }
      if (event.leaves != null) {
        event.leaves.forEach((p) {
          c.players.removeWhere((p2) => p2.user_id == p.user_id);
        });
      }
    });

    nk.socketMatchData.stream.listen((event) {
      // deck positions for players
      switch (OpCodeServer.values[event.opcode]) {
        case OpCodeServer.ERROR:
          Get.dialog(Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            child: Text(
              event.data['error'],
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 20,
              ),
            ),
          ));
          break;
        case OpCodeServer.BET_PHASE:
          roundCardNumber = 0;
          if (!gameStarted) {
            Get.off(Dashboard(this));
            matchId = event.matchId;
            gameStarted = true;
          }
          phase = GamePhase.BET_READY;
          for (var c in event.data['hand']) {
            roundCardNumber++;
            hand.newCard(GameCardV2(
              color: Colors.blue,
              suit: c['suit'],
              number: c['number'],
            ));
          }
          var index = 0;
          // add other player's decks
          for (var p in c.players) {
            if (p.user_id == nk.userdata.user.id) continue;
            // create the deck
            if (!playerDeks.containsKey(p.user_id)) {
              playerDeks[p.user_id] = Deck(
                left: positions[index],
                top: 30,
                refreshDashboard: refreshDashboard,
                name: p.username,
              );
            }
            for (var c in event.data['hand']) {
              // add card
              var cardForPlayer = GameCardV2(
                number: 0,
                suit: 0,
                color: Colors.red,
              );
              playerDeks[p.user_id].moveOnTop(cardForPlayer);
              cardForPlayer.upward(false);
              index++;
            }
          }
          refreshDashboard();
          Get.defaultDialog(
            title: 'Bet:',
            backgroundColor: Colors.teal[900],
            content: Container(
              width: 300,
              height: 300,
              color: Colors.teal[900],
              child: ListView.builder(
                itemCount: roundCardNumber + 1,
                itemBuilder: (context, index) => ListTile(
                  title: Text('$index'),
                  leading: Radio(
                    groupValue: -1,
                    value: index,
                    onChanged: (int value) {
                      assert(phase == GamePhase.BET_READY);
                      playBet(event.matchId, value);
                      Get.back();
                    },
                  ),
                ),
              ),
            ),
          );
          break;
        case OpCodeServer.CARD_PLAYED:
          if (event.data['player'] == nk.userdata.user.id) {
            center.moveOnTop(cardSelected);
            if (hand.numberOfCards == 0) {
              phase = GamePhase.PLAY_DONE;
            }
          } else {
            var cardToPlay = playerDeks[event.data['player']].first();
            cardToPlay.number.value = event.data['card']['number'];
            cardToPlay.suit.value = event.data['card']['suit'];
            center.moveOnTop(cardToPlay);
          }
          turnPlayerID.value = event.data['turn'];
          break;
        case OpCodeServer.PLAY_CARD_PHASE:
          phase = GamePhase.PLAY_READY;
          turnPlayerID.value = event.data['turn'];
          break;
        case OpCodeServer.BET_RECEIVED:
          phase = GamePhase.BET_DONE;
          Get.snackbar('Player Bet', json.encode(event.data));
          break;
        case OpCodeServer.TRICK_FINISHED:
          Get.snackbar('Trick finished', json.encode(event.data));
          turnPlayerID.value = event.data['turn'];
          refreshDashboard();
          break;
        case OpCodeServer.GAME_FINISHED:
          Get.snackbar('Game Finished', json.encode(event.data));
          break;
        default:
          assert(
            false,
            'Server opcode not implemented: ${event.opcode} ${OpCodeServer.values[event.opcode]}',
          );
      }
    });
  }

  void startTest() {
    center = Deck(
      name: 'Table',
      spacingY: 5,
      spacingX: 5,
      left: context.size.width / 2 - GameCardV2.width / 2,
      top: context.size.height / 2 - GameCardV2.height / 2,
      refreshDashboard: refreshDashboard,
    );
    hand = GameHand(
      name: 'Hand',
      left: context.size.width / 2 - GameCardV2.width / 2,
      top: context.size.height - GameCardV2.height - 10,
      refreshDashboard: refreshDashboard,
    );

    center.onTap = (card) {
      card.upward(!card.isUpward);
    };

    hand.onDragUp = (card) {
      center.moveOnTop(card);
    };
    hand.onDragDown = (card) {
      center.moveOnBottom(card);
    };
    center.onDragUp = (card) {
      hand.moveOnBottom(card);
    };
    center.onDragDown = (card) {
      hand.moveOnTop(card);
    };

    center.reloadHandlers();
    hand.reloadHandlers();

    for (var i = 0; i < 5; i++) {
      center.newCard(GameCardV2(
        color: Colors.blue,
        suit: 1,
        number: i,
      ).upward(false));
    }
    for (var i = 0; i < 5; i++) {
      hand.newCard(GameCardV2(
        color: Colors.blue,
        suit: 2,
        number: i,
      ));
    }
    phase = GamePhase.BET_READY;
    Get.off(Dashboard(this));
  }

  void startMatch(String matchId) {
    var ms = MatchData(
      matchId: matchId,
      opcode: OpCodeClient.START_GAME.index,
    );
    nk.socket.send(ms);
  }

  void playBet(String matchId, int number) {
    var ms = MatchData(
      matchId: matchId,
      opcode: OpCodeClient.PLAY_BET.index,
      data: {
        'bet': number,
      },
    );
    nk.socket.send(ms);
  }

  void playCard(String matchId, int index) {
    var ms = MatchData(
      matchId: matchId,
      opcode: OpCodeClient.PLAY_CARD.index,
      data: {'card_idx': index},
    );
    nk.socket.send(ms);
  }

  Widget renderUI(BuildContext context) {
    return Obx(
      () => Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Turn: ${turnPlayerID.value == nk.userdata.user.id ? 'Your turn!' : turnPlayerID.value}',
                ),
                Text('$phase'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
