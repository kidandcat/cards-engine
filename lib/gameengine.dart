import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cartas/gamehand.dart';
import 'dashboard.dart';
import 'deck.dart';
import 'gamecardv2.dart';
import 'gamestate.dart';
import 'lobby.dart';
import 'modals.dart';
import 'networking.dart';
import 'socket.dart';

enum GamePhase { BET_READY, BET_DONE, PLAY_READY, PLAY_DONE }

class GameEngine {
  final GameState c = Get.put(GameState(), permanent: true);
  final Networking nk = Networking();
  Deck center;
  GameHand hand;

  // current match
  List<StreamSubscription> listeners = [];
  int roundCardNumber = 0;
  String matchId;
  RxString turnPlayerID = ''.obs;
  GameCardV2 cardSelected;
  bool gameStarted = false;
  bool waitingForRefresh = false;
  GamePhase phase = GamePhase.BET_READY;
  int betPlaced = -1;
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
    print('refreshing dashboard');
    c.dashboardKey.value = UniqueKey();
  }

  void dispose() async {
    for (var listener in listeners) {
      await listener.cancel();
    }
  }

  void delete(String matchId) {
    deleteMatch(matchId);
    dispose();
    Get.off(Lobby());
  }

  GameEngine(BuildContext _context) {
    context = _context;
    print('GameEngine created, delete: |${c.delete.value}|');
    if (c.delete.value != '') {
      print('######## DELETING MATCH!! ########');
      delete(c.delete.value);
      return;
    }
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
      name: nk.userdata.user.username,
      left: context.size.width / 2 - GameCardV2.width / 2,
      top: context.size.height - GameCardV2.height - 10,
      refreshDashboard: refreshDashboard,
    );

    center.onTap = (card) {
      card.upward(!card.isUpward);
    };

    center.reloadHandlers();

    hand.onDragUp = (card) {
      if (phase == GamePhase.PLAY_READY) {
        playCard(matchId, hand.indexOf(card));
        cardSelected = card;
      }
    };

    hand.reloadHandlers();
    refreshDashboard();

    listeners.add(nk.socketMatch.stream.listen((event) {
      print('socketMatch received $event');
    }));

    listeners.add(nk.socketMatchPresence.stream.listen((event) {
      if (event.joins != null) {
        c.players.addAll(event.joins);
      }
      if (event.leaves != null) {
        event.leaves.forEach((p) {
          c.players.removeWhere((p2) => p2.user_id == p.user_id);
        });
      }
    }));

    listeners.add(nk.socketMatchData.stream.listen((event) async {
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
          betPlaced = -1;
          if (!gameStarted) {
            Get.off(Dashboard());
            matchId = event.matchId;
            gameStarted = true;
          }
          phase = GamePhase.BET_READY;
          for (var c in event.data['hand']) {
            roundCardNumber++;
            var cardForHand = GameCardV2(
              color: Colors.blue,
              suit: c['suit'],
              number: c['number'],
            );
            hand.moveOnTop(cardForHand);
          }
          var index = 0;

          // add other player's decks
          for (var p in c.players) {
            if (p.user_id == nk.userdata.user.id) {
              // update player points
              hand.points = event.data['points'][p.user_id];
              continue;
            }
            // create the deck
            if (!playerDeks.containsKey(p.user_id)) {
              playerDeks[p.user_id] = Deck(
                left: positions[index],
                top: 30,
                refreshDashboard: refreshDashboard,
                name: p.username,
                playerId: p.user_id,
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
            }
            playerDeks[p.user_id].points = event.data['points'][p.user_id];
            index++;
          }
          refreshDashboard();
          // TODO add animation "play your bets!"
          break;
        case OpCodeServer.CARD_PLAYED:
          // TODO: show who played, add animation
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
            cardToPlay.upward(true);
          }
          turnPlayerID.value = event.data['turn'];
          refreshDashboard();
          break;
        case OpCodeServer.PLAY_CARD_PHASE:
          phase = GamePhase.PLAY_READY;
          turnPlayerID.value = event.data['turn'];
          refreshDashboard();
          break;
        case OpCodeServer.BET_RECEIVED:
          phase = GamePhase.BET_DONE;
          refreshDashboard();
          break;
        case OpCodeServer.TRICK_FINISHED:
          turnPlayerID.value = event.data['turn'];
          refreshDashboard();
          break;
        case OpCodeServer.GAME_FINISHED:
          Get.defaultDialog(
            title: 'Finished!',
            backgroundColor: Colors.teal[900],
            content: Modal(
              child: ModalPartFinished(
                points: event.data['points'],
                players: c.players,
                onSubmit: () {
                  dispose();
                  Get.off(Lobby());
                },
              ),
            ),
          );
          refreshDashboard();
          break;
        default:
          assert(
            false,
            'Server opcode not implemented: ${event.opcode} ${OpCodeServer.values[event.opcode]}',
          );
      }
    }));
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
    Get.off(Dashboard());
  }

  void deleteMatch(String matchId) {
    var ms = MatchData(
      matchId: matchId,
      opcode: OpCodeClient.END_MATCH.index,
    );
    nk.socket.send(ms);
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

  List<Widget> renderUI(BuildContext context) {
    return [
      Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  phase == GamePhase.BET_READY
                      ? 'Place your bet!'
                      : turnPlayerID.value == nk.userdata.user.id
                          ? 'Play your card!'
                          : 'Waiting others',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      if (phase == GamePhase.BET_READY && betPlaced == -1)
        Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              Get.defaultDialog(
                title: 'Bet:',
                backgroundColor: Colors.teal[900],
                content: Modal(
                  child: ModalPartBet(
                    maxBet: roundCardNumber + 1,
                    onBet: (bet) {
                      assert(phase == GamePhase.BET_READY);
                      playBet(matchId, bet);
                      betPlaced = bet;
                      Get.back();
                      refreshDashboard();
                    },
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  centerSlice: Rect.fromLTRB(20, 20, 43, 43),
                  image: AssetImage('assets/circle.png'),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(30),
                child: Text('Make your bet!'),
              ),
            ),
          ),
        )
    ];
  }
}
