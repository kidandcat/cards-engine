import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart' as GetX;
import 'package:cartas/swagger/apigrpc.swagger.dart';
import 'package:chopper/chopper.dart';
import 'package:get_storage/get_storage.dart';
import 'lobby.dart';
import 'socket.dart';

class Networking {
  // Singleton pattern
  static final Networking _singleton = Networking._internal();
  factory Networking() {
    return _singleton;
  }
  Networking._internal() {
    nakama = Apigrpc.create(getClient());

    refreshSession();
  }
  // Singleton end

  Apigrpc nakama;
  ApiSession session;
  ApiAccount userdata;
  Socket socket;

  Future<void> refreshSession() async {
    await refreshToken();
    if (session != null) GetX.Get.off(Lobby());
    // Refresh session when token expires (30s)
    Timer.periodic(Duration(seconds: 20), (_) {
      refreshToken();
    });
    sessionLoaded();
  }

  Future<void> refreshToken() async {
    var box = GetStorage();
    var token = box.read<String>('refreshToken');
    if (token != null) {
      // token refreshing must be done with Authorization Basic
      var basicClient = getBasicClient();
      var nkc = Apigrpc.create(basicClient);
      var response = await nkc.nakamaSessionRefresh(
        body: ApiSessionRefreshRequest(token: token),
      );
      if (response.isSuccessful) {
        session = response.body;
        nakama.client = getClient(); // Refresh client to use session
      } else {
        print('Session not refreshed: ${response.error}');
      }
    }
  }

  ChopperClient getClient() =>
      session != null ? getBearerClient() : getBasicClient();

  ChopperClient getBearerClient() {
    return ChopperClient(
      converter: JsonSerializableConverter(),
      baseUrl: 'https://world.galax.be',
      interceptors: [
        (Request request) async => request.copyWith(
              headers: {'Authorization': 'Bearer ${session.token}'},
            ),
      ],
    );
  }

  ChopperClient getBasicClient() {
    var bytes = utf8.encode('defaultkey:');
    var base64Str = base64.encode(bytes);
    return ChopperClient(
      converter: JsonSerializableConverter(),
      baseUrl: 'https://world.galax.be',
      interceptors: [
        (Request request) async => request.copyWith(
              headers: {'Authorization': 'Basic $base64Str'},
            ),
      ],
    );
  }

  Future<void> login(String email, String password) async {
    var response = await nakama.nakamaAuthenticateEmail(
      body: ApiAccountEmail(
        email: email,
        password: password,
      ),
    );

    if (response.isSuccessful) {
      session = response.body;
      await sessionLoaded();
    } else {
      var j = json.decode(response.error);
      throw j['message'];
    }
  }

  Future<void> createMatch(String name) async {
    var cm = CreateMatch(name: name, numPlayers: 4, openGame: true);
    var response = await nakama.nakamaRpcFunc(
      id: 'create_match',
      body: cm.toJson(),
    );
    if (!response.isSuccessful) {
      print('error creating matches');
      var j = json.decode(response.error);
      throw j['message'];
    }
    print('match created');
  }

  Future<ApiMatchList> listMatches() async {
    var response = await nakama.nakamaListMatches(limit: 50);
    if (response.isSuccessful) {
      return response.body;
    } else {
      throw response.error;
    }
  }

  Future<void> sessionLoaded() async {
    nakama.client = getClient(); // Refresh client to use session
    await getUserData();
    await saveRefreshToken(session.refreshToken);
    connectSocket();
    GetX.Get.off(Lobby());
  }

  void connectSocket() {
    socket = Socket(
        'wss://world.galax.be/ws?token=${session.token}', onSocketMessage);
  }

  void joinMatch(String matchId) {
    assert(socket != null);
    assert(matchId != null);
    var jm = JoinMatch();
    jm.match_id = matchId;
    // jm.token = session.token;
    socket.send(jm);
  }

  Future<void> saveRefreshToken(String token) async {
    var box = GetStorage();
    await box.write('refreshToken', session.refreshToken);
  }

  Future<void> getUserData() async {
    var response = await nakama.nakamaGetAccount();
    if (response.isSuccessful) {
      userdata = response.body;
    } else {
      throw response.error;
    }
  }

  StreamController<MatchPresenceEvent> socketMatchPresence = StreamController();
  StreamController<MatchState> socketMatchState = StreamController();
  StreamController<ApiMatch> socketMatch = StreamController();

  void onSocketMessage(dynamic msg) {
    Map<String, dynamic> map = json.decode(msg);
    if (map.containsKey('match')) {
      socketMatch.add(ApiMatch.fromJson(map));
    } else if (map.containsKey('match_data')) {
      print('<--- match_data_send ---> $map');
    } else if (map.containsKey('match_state')) {
      socketMatchState.add(MatchState.fromMap(map['match_state']));
    } else if (map.containsKey('match_presence_event')) {
      socketMatchPresence
          .add(MatchPresenceEvent.fromMap(map['match_presence_event']));
    } else {
      assert(false, 'Message not implemented: $map');
    }
    print('<--- onSocketMessage ---> $map');
  }
}
