import 'dart:convert';
import 'package:get/get.dart' as GetX;
import 'package:cartas/swagger/apigrpc.swagger.dart';
import 'package:chopper/chopper.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart'
    show JsonMapper, jsonSerializable, JsonProperty;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
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
    checkExistingSession();
  }
  // Singleton end

  Apigrpc nakama;
  ApiSession session;
  ApiAccount userdata;
  Socket socket;

  Future<void> checkExistingSession() async {
    var box = GetStorage();
    var token = box.read<String>('refreshToken');
    if (token != null) {
      var response = await nakama.nakamaSessionRefresh(
        body: ApiSessionRefreshRequest(token: token),
      );
      if (response.isSuccessful) {
        session = response.body;
        await sessionLoaded();
      }
    }
  }

  ChopperClient getClient() {
    if (session != null) {
      return ChopperClient(
        converter: JsonSerializableConverter(),
        baseUrl: 'https://world.galax.be',
        interceptors: [
          (Request request) async => request.copyWith(
                headers: {'Authorization': 'Bearer ${session.token}'},
              ),
        ],
      );
    } else {
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
    socket = Socket('wss://world.galax.be/ws?token=${session.token}');
  }

  void joinMatch(String matchId) {
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
}
