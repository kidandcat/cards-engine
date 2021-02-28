import 'dart:html';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel initChannel(String uri) {
  final webSocket = WebSocket(uri);
  final channel = HtmlWebSocketChannel(webSocket);
  return channel;
}
