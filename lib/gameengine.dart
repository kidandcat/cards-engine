import 'dart:async';
import 'dart:convert';

import 'package:cartas/gamehand.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard.dart';
import 'deck.dart';
import 'gamecard.dart';
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
  Rx<GameCard> cardSelected;
  bool gameStarted = false;
  bool waitingForRefresh = false;
  GamePhase phase = GamePhase.BET_READY;
  Map<String, Deck> playerDeks = {};
  List<double> positions;

  Timer refreshTimer;
  void refreshDashboard() {
    var shouldNotRefresh = c.cards.any((card) => card.value.isMoving);
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

  GameEngine(BuildContext context) {
    positions = [
      10,
      context.size.width / 2,
      context.size.width - GameCard.width - 10
    ];
    center = Deck(
      name: 'Table',
      spacingY: 0.2,
      spacingX: 0.2,
      left: context.size.width / 2 - GameCard.width / 2,
      top: context.size.height / 2 - GameCard.height / 2,
      refreshDashboard: refreshDashboard,
    );
    hand = GameHand(
      name: 'Hand',
      left: context.size.width / 2 - GameCard.width / 2,
      top: context.size.height - GameCard.height - 10,
      refreshDashboard: refreshDashboard,
    );

    center.onTap = (card) {
      card.value.flip();
    };

    hand.onDragUp = (card) {
      print('onDragUp $phase');
      if (phase == GamePhase.PLAY_READY) {
        print('playCard');
        playCard(matchId, hand.indexOf(card));
        cardSelected = card;
      }
    };

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
            hand.newCard(GameCard(
              color: Colors.blue,
              suit: c['suit'],
              number: c['number'],
            ).obs);
          }
          var index = 0;
          // add other player's decks
          for (var p in c.players) {
            if (p.user_id == nk.userdata.user.id) continue;
            // create the deck
            // TODO: reset it on every round may help with leaving players?
            playerDeks[p.user_id] = Deck(
              left: positions[index],
              top: 30,
              refreshDashboard: refreshDashboard,
              name: p.username,
            );
            // add card
            var cardForPlayer = GameCard(
              number: 0,
              suit: 0,
              color: Colors.red,
            ).obs;
            playerDeks[p.user_id].moveOnTop(cardForPlayer);
            cardForPlayer.value.flip();
            index++;
          }
          Get.defaultDialog(
            title: 'Bet:',
            backgroundColor: Colors.teal[900],
            content: Container(
              color: Colors.teal[900],
              child: ListView.builder(
                itemCount: roundCardNumber,
                itemBuilder: (context, index) => ListTile(
                  title: Text('$index'),
                  leading: Radio(
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
            phase = GamePhase.PLAY_DONE;
          } else {
            var cardToPlay = playerDeks[event.data['player']].first();
            cardToPlay.update((val) {
              cardToPlay.value.number = event.data['card']['number'];
              cardToPlay.value.suit = event.data['card']['suit'];
            });
            center.moveOnTop(cardToPlay);
          }
          Get.snackbar('Player Card', json.encode(event.data));
          break;
        case OpCodeServer.PLAY_CARD_PHASE:
          phase = GamePhase.PLAY_READY;
          Get.snackbar('Player Bet', json.encode(event.data));
          break;
        case OpCodeServer.BET_RECEIVED:
          phase = GamePhase.BET_DONE;
          Get.snackbar('Player Bet', json.encode(event.data));
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
}
