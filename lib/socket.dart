import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:web_socket_channel/io.dart';

import 'swagger/apigrpc.swagger.dart';

class Socket {
  IOWebSocketChannel channel;
  Socket(String uri) {
    channel = IOWebSocketChannel.connect(Uri.parse(uri));

    channel.stream.listen((message) {
      print('Got message $message');
    });
  }

  void send(dynamic data) {
    assert(data != null);
    Map<String, dynamic> template = {'cid': '1'};
    _send(
      JsonMapper.serialize(
        data,
        SerializationOptions(
          template: template,
        ),
      ),
    );
  }

  void _send(String data) {
    print('Sending $data');
    channel.sink.add(data);
  }
}

@jsonSerializable
class Presence {
  String user_id;
  String session_id;
  String username;
  String node;
  Presence({
    this.user_id,
    this.session_id,
    this.username,
    this.node,
  });
}

/// A response fron a channel join operation.
@jsonSerializable
class Channel {
  String id;
  List<Presence> presences;
  Presence self;
  Channel({
    this.id,
    this.presences,
    this.self,
  });
}

/// Join a realtime chat channel.
@jsonSerializable
class ChannelJoin {
  String target;
  int type;
  bool persistence;
  bool hidden;
  ChannelJoin({
    this.target,
    this.type,
    this.persistence,
    this.hidden,
  });
}

/// Leave a realtime chat channel.
@jsonSerializable
class ChannelLeave {
  String channel_id;
  ChannelLeave({
    this.channel_id,
  });
}

/// An incoming message on a realtime chat channel.
@jsonSerializable
class ChannelMessage {
  String channel_id;
  String message_id;
  int code;
  String sender_id;
  String username;
  dynamic content;
  String create_time;
  String update_time;
  bool persistent;
  String group_id;
  String room_name;
  String user_id_one;
  String user_id_two;
  ChannelMessage({
    this.channel_id,
    this.message_id,
    this.code,
    this.sender_id,
    this.username,
    this.content,
    this.create_time,
    this.update_time,
    this.persistent,
    this.group_id,
    this.room_name,
    this.user_id_one,
    this.user_id_two,
  });
}

/// An acknowledgement received in response to sending a message on a chat channel.
@jsonSerializable
class ChannelMessageAck {
  String channel_id;
  String message_id;
  int code;
  String username;
  String create_time;
  String update_time;
  bool persistence;
  ChannelMessageAck({
    this.channel_id,
    this.message_id,
    this.code,
    this.username,
    this.create_time,
    this.update_time,
    this.persistence,
  });
}

/// Send a message to a realtime chat channel.
@jsonSerializable
class ChannelMessageSend {
  String channel_id;
  dynamic content;
  ChannelMessageSend({
    this.channel_id,
    this.content,
  });
}

/// Update a message previously sent to a realtime chat channel.
@jsonSerializable
class ChannelMessageUpdate {
  String channel_id;
  String message_id;
  dynamic content;
  ChannelMessageUpdate({
    this.channel_id,
    this.message_id,
    this.content,
  });
}

/// Remove a message previously sent to a realtime chat channel.
@jsonSerializable
class ChannelMessageRemove {
  String channel_id;
  String message_id;
  ChannelMessageRemove({
    this.channel_id,
    this.message_id,
  });
}

/// Presence update for a particular realtime chat channel.
@jsonSerializable
class ChannelPresenceEvent {
  String channel_id;
  List<Presence> joins;
  List<Presence> leaves;
  ChannelPresenceEvent({
    this.channel_id,
    this.joins,
    this.leaves,
  });
}

/// Stream identifier
@jsonSerializable
class StreamId {
  int mode;
  String subject;
  String descriptor;
  String label;
  StreamId({
    this.mode,
    this.subject,
    this.descriptor,
    this.label,
  });
}

/// Stream data.
@jsonSerializable
class StreamData {
  StreamId stream;
  Presence stream_presence;
  String data;
  StreamData({
    this.stream,
    this.stream_presence,
    this.data,
  });
}

/// Presence updates.
@jsonSerializable
class StreamPresenceEvent {
  StreamId stream;
  List<Presence> joins;
  List<Presence> leaves;
  StreamPresenceEvent({
    this.stream,
    this.joins,
    this.leaves,
  });
}

/// Match presence updates.
@jsonSerializable
class MatchPresenceEvent {
  String match_id;
  List<Presence> joins;
  List<Presence> leaves;
  MatchPresenceEvent({
    this.match_id,
    this.joins,
    this.leaves,
  });
}

/// Start a matchmaking process.
@jsonSerializable
class MatchmakerAdd {
  int min_count;
  int max_count;
  String query;
  Map<String, String> string_properties;
  Map<String, int> numeric_properties;
  MatchmakerAdd({
    this.min_count,
    this.max_count,
    this.query,
    this.string_properties,
    this.numeric_properties,
  });
}

/// Cancel a matchmaking process.
@jsonSerializable
class MatchmakerRemove {
  String ticket;
  MatchmakerRemove({
    this.ticket,
  });
}

/// A reference to a user and their matchmaking properties.
@jsonSerializable
class MatchmakerUser {
  Presence presence;
  Map<String, String> string_properties;
  Map<String, int> numeric_properties;
  MatchmakerUser({
    this.presence,
    this.string_properties,
    this.numeric_properties,
  });
}

/// Matchmaking result.
@jsonSerializable
class MatchmakerMatched {
  String ticket;
  String match_id;
  String token;
  List<MatchmakerUser> users;
  MatchmakerUser self;
  MatchmakerMatched({
    this.ticket,
    this.match_id,
    this.token,
    this.users,
    this.self,
  });
}

/// A realtime match
@jsonSerializable
class Match {
  String match_id;
  bool authoritative;
  String label;
  int size;
  List<Presence> presences;
  Presence self;
  Match({
    this.match_id,
    this.authoritative,
    this.label,
    this.size,
    this.presences,
    this.self,
  });
}

/// Create a multiplayer match.
@jsonSerializable
class CreateMatch {
  String name;
  int numPlayers;
  bool openGame;
  CreateMatch({
    this.name,
    this.numPlayers,
    this.openGame,
  });
}

/// Join a multiplayer match.
@jsonSerializable
@Json(name: 'match_join', ignoreNullMembers: true)
class JoinMatch {
  String match_id;
  String token;
  Map<String, dynamic> metadata;
  JoinMatch({
    this.match_id,
    this.token,
    this.metadata,
  });
}

/// Leave a multiplayer match.
@jsonSerializable
class LeaveMatch {
  String match_id;
  LeaveMatch({
    this.match_id,
  });
}

/// Match data */
@jsonSerializable
class MatchData {
  String match_id;
  int op_code;
  dynamic data;
  List<Presence> presences;
  MatchData({
    this.match_id,
    this.op_code,
    this.data,
    this.presences,
  });
}

/** Send a message contains match data. */
// class  MatchDataSend {
// RequireKeys<MatchData, "match_id" | "op_code" | "data">   match_data_send;
// }

/// Execute an Lua function on the server.
class Rpc {
  ApiRpc rpc;
}

/// A snapshot of statuses for some set of users.
@jsonSerializable
class Status {
  List<Presence> presences;
  Status({
    this.presences,
  });
}

/// Start receiving status updates for some set of users.
@jsonSerializable
class StatusFollow {
  List<String> status_follow;
  StatusFollow({
    this.status_follow,
  });
}

/// A batch of status updates for a given user.
@jsonSerializable
class StatusPresenceEvent {
  List<Presence> joins;
  List<Presence> leaves;
  StatusPresenceEvent({
    this.joins,
    this.leaves,
  });
}

/// Stop receiving status updates for some set of users.
@jsonSerializable
class StatusUnfollow {
  List<String> status_follow;
  StatusUnfollow({
    this.status_follow,
  });
}

/// Set the user's own status.
@jsonSerializable
class StatusUpdate {
  Status status_update;
  StatusUpdate({
    this.status_update,
  });
}
