import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart' as GetX;
import 'package:cartas/swagger/apigrpc.swagger.dart';
import 'package:chopper/chopper.dart';
import 'package:get_storage/get_storage.dart';
import 'lobby.dart';
import 'login.dart';
import 'socket.dart';

class Networking {
  // Singleton pattern
  static final Networking _singleton = Networking._internal();
  factory Networking() {
    return _singleton;
  }
  Networking._internal() {
    nakama = Apigrpc.create(getClient());
    box = GetStorage();
    refreshSession();
  }
  // Singleton end

  Apigrpc nakama;
  ApiSession session;
  ApiAccount userdata;
  Socket socket;
  GetStorage box;

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
        GetX.Get.off(Login());
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
      username: email,
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
    var cm = CreateMatch(name: name, numMaxPlayers: 4, openGame: true);
    var response = await nakama.nakamaRpcFunc(
      id: 'create_match',
      body: cm.toJson(),
    );
    if (!response.isSuccessful) {
      var j = json.decode(response.error);
      throw j['message'];
    }
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
    socket.send(jm);
  }

  Future<void> saveRefreshToken(String token) async {
    await box.write('refreshToken', session.refreshToken);
  }

  Future<void> logout() async {
    await box.remove('refreshToken');
    refreshToken();
  }

  Future<void> getUserData() async {
    var response = await nakama.nakamaGetAccount();
    if (response.isSuccessful) {
      userdata = response.body;
    } else {
      throw response.error;
    }
  }

  StreamController<MatchPresenceEvent> socketMatchPresence =
      StreamController.broadcast();
  StreamController<ApiMatch> socketMatch = StreamController.broadcast();
  StreamController<MatchData> socketMatchData = StreamController.broadcast();

  void onSocketMessage(dynamic msg) {
    print('<------ $msg');
    Map<String, dynamic> map = json.decode(msg);
    if (map.containsKey('match')) {
      var match = ApiMatch.fromJson(map['match']);
      socketMatch.add(match);
      if (map['match']['presences'] != null) {
        List<dynamic> p = map['match']['presences'];
        List<Presence> presences = p.map((e) => Presence.fromMap(e)).toList();
        socketMatchPresence.add(MatchPresenceEvent(
          joins: presences,
          match_id: match.matchId,
        ));
      }
    } else if (map.containsKey('match_data')) {
      socketMatchData.add(MatchData.fromMap(map['match_data']));
    } else if (map.containsKey('match_presence_event')) {
      socketMatchPresence
          .add(MatchPresenceEvent.fromMap(map['match_presence_event']));
    } else {
      assert(false, 'Message not implemented: $map');
    }
  }
}
