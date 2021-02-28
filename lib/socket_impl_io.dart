import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel initChannel(String uri) {
  WebSocketChannel channel = IOWebSocketChannel.connect(Uri.parse(uri));
  return channel;
}
