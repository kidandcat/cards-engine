import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'deck.dart';
import 'gamecard.dart';
import 'painters.dart';

class GameState extends GetxController {
  //Dashboard

  GameState() {
    topLeft.value.append(GameCard(color: Colors.blue, name: 'One'));
    topLeft.value.append(GameCard(color: Colors.blue, name: 'One'));
    topLeft.value.append(GameCard(color: Colors.blue, name: 'One'));

    topRight.value.append(GameCard(color: Colors.red, name: 'One'));
    topRight.value.append(GameCard(color: Colors.red, name: 'One'));
    topRight.value.append(GameCard(color: Colors.red, name: 'One'));
    topRight.value.append(GameCard(color: Colors.red, name: 'One'));
    topRight.value.append(GameCard(color: Colors.red, name: 'One'));

    center.value.append(GameCard(color: Colors.yellow, name: 'One'));
    center.value.append(GameCard(color: Colors.yellow, name: 'One'));
    center.value.append(GameCard(color: Colors.yellow, name: 'One'));
  }

  // ignore: close_sinks
  var animations = StreamController<GameAnimation>();

  var topLeft = Deck(
    name: 'TopLeft',
    cardHeight: 200 * 0.8,
    cardWidth: 123 * 0.8,
    painter: PainterTopLeft(),
  ).obs;
  var topRight = Deck(
    name: 'TopRight',
    cardHeight: 200,
    cardWidth: 123,
    spacingX: 10,
    painter: PainterTopRight(),
  ).obs;
  var center = Deck(
    name: 'Center',
    cardHeight: 170,
    cardWidth: 100,
    spacingX: 105,
    spacingY: 0,
    painter: PainterCenter(),
  ).obs;
}
