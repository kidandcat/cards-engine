import 'package:cartas/swagger/apigrpc.swagger.dart';

class Networking {
  // Singleton pattern
  static final Networking _singleton = Networking._internal();
  factory Networking() {
    return _singleton;
  }
  Networking._internal();
  // Singleton end

  Apigrpc nakama = Apigrpc.create();

  void login() async {
    var response = await nakama.nakamaAuthenticateEmail(
      body: ApiAccountEmail(
        email: 'jairo@email.com',
        password: '12341234',
      ),
    );
    print('Got response $response');

    if (response.isSuccessful) {
      var session = response.body;
      print('Got session $session');
    } else {
      print('Got error ${response.error}');
    }
  }
}
