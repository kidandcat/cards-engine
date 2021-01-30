import 'dart:convert';

import 'package:cartas/swagger/apigrpc.swagger.dart';
import 'package:chopper/chopper.dart';

class Networking {
  // Singleton pattern
  static final Networking _singleton = Networking._internal();
  factory Networking() {
    return _singleton;
  }
  Networking._internal() {
    nakama = Apigrpc.create(getClient());
  }
  // Singleton end

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

  Apigrpc nakama;
  ApiSession session;
  ApiAccount userdata;

  Future<void> login(String email, String password) async {
    var response = await nakama.nakamaAuthenticateEmail(
      body: ApiAccountEmail(
        email: email,
        password: password,
      ),
    );

    if (response.isSuccessful) {
      session = response.body;
      nakama.client = getClient(); // Refresh client to use session
      await getUserData();
    } else {
      throw response.error;
    }
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
