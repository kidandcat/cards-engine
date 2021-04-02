// Imports the Flutter Driver API.
import 'dart:convert';
import 'dart:math';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Load test screen', () {
    final emailField = find.byValueKey('email');
    final passwordField = find.byValueKey('password');
    final loginButton = find.byValueKey('login_button');
    final lobbyCreateButton = find.byValueKey('lobby_create');
    final roomNameModalField = find.byValueKey('room_name');
    final roomNameModalButton = find.byValueKey('submit_name');
    final submitBetModalField = find.byValueKey('submit_bet');
    String roomName;

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Log in', () async {
      // Use the `driver.getText` method to verify the counter starts at 0
      await driver.waitUntilFirstFrameRasterized();
      await driver.tap(emailField);
      await driver.enterText('test1@test1.com');
      await driver.tap(passwordField);
      await driver.enterText('12341234');
      await driver.tap(loginButton);
      await driver.waitFor(lobbyCreateButton);
    });

    test('Create match', () async {
      roomName = 'testRoom${getRandString(8)}';
      await driver.tap(lobbyCreateButton);
      await driver.tap(roomNameModalField);
      await driver.enterText(roomName);
      await driver.tap(roomNameModalButton);
    });

    test('join match', () async {
      var roomNameModalField = find.byValueKey('room_$roomName');
      await driver.waitFor(roomNameModalField);
      await driver.tap(roomNameModalField);
    });

    test('submit bet', () async {
      await driver.tap(submitBetModalField);
    });
  });
}

String getRandString(int len) {
  var random = Random.secure();
  var values = List<int>.generate(len, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}
