import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'swagger/apigrpc.swagger.dart';

class Socket {
  IOWebSocketChannel channel;
  Socket(String uri, Function(dynamic) onMessage) {
    channel = IOWebSocketChannel.connect(Uri.parse(uri));

    channel.stream.listen(onMessage);
  }

  void send(Serializable data) {
    assert(data != null);
    _send(data.toJson());
  }

  void _send(String data) {
    print('Sending $data');
    channel.sink.add(data);
  }
}

class Presence implements Serializable {
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

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'session_id': session_id,
      'username': username,
      'node': node,
    };
  }

  factory Presence.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Presence(
      user_id: map['user_id'],
      session_id: map['session_id'],
      username: map['username'],
      node: map['node'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Presence.fromJson(String source) =>
      Presence.fromMap(json.decode(source));
}

enum OpCode { START_GAME, PLAY_BET, PLAY_CARD }

class MatchState implements Serializable {
  String matchId;
  OpCode opCode;
  String payload;
  MatchState({
    this.matchId,
    this.opCode,
    this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'match_data_send': {
        'match_id': matchId,
        'op_code': opCode.index,
        'payload': payload,
      }
    };
  }

  factory MatchState.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return MatchState(
      matchId: map['match_id'],
      opCode: map['op_code'],
      payload: map['payload'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MatchState.fromJson(String source) =>
      MatchState.fromMap(json.decode(source));
}

/// A response fron a channel join operation.

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

class ChannelLeave {
  String channel_id;
  ChannelLeave({
    this.channel_id,
  });
}

/// An incoming message on a realtime chat channel.

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
class ChannelMessageSend {
  String channel_id;
  dynamic content;
  ChannelMessageSend({
    this.channel_id,
    this.content,
  });
}

/// Update a message previously sent to a realtime chat channel.
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
class ChannelMessageRemove {
  String channel_id;
  String message_id;
  ChannelMessageRemove({
    this.channel_id,
    this.message_id,
  });
}

/// Presence update for a particular realtime chat channel.
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
class MatchPresenceEvent implements Serializable {
  String match_id;
  List<Presence> joins;
  List<Presence> leaves;
  MatchPresenceEvent({
    this.match_id,
    this.joins,
    this.leaves,
  });

  Map<String, dynamic> toMap() {
    return {
      'match_id': match_id,
      'joins': joins?.map((x) => x?.toMap())?.toList(),
      'leaves': leaves?.map((x) => x?.toMap())?.toList(),
    };
  }

  factory MatchPresenceEvent.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return MatchPresenceEvent(
      match_id: map['match_id'],
      joins: map['joins'] != null
          ? List<Presence>.from(map['joins']?.map((x) => Presence.fromMap(x)))
          : [],
      leaves: map['leaves'] != null
          ? List<Presence>.from(map['leaves']?.map((x) => Presence.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory MatchPresenceEvent.fromJson(String source) =>
      MatchPresenceEvent.fromMap(json.decode(source));
}

/// Start a matchmaking process.

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

class MatchmakerRemove {
  String ticket;
  MatchmakerRemove({
    this.ticket,
  });
}

/// A reference to a user and their matchmaking properties.

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

class CreateMatch {
  String name;
  int numPlayers;
  bool openGame;
  CreateMatch({
    this.name,
    this.numPlayers,
    this.openGame,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'numPlayers': numPlayers,
      'openGame': openGame,
    };
  }

  factory CreateMatch.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return CreateMatch(
      name: map['name'],
      numPlayers: map['numPlayers'],
      openGame: map['openGame'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CreateMatch.fromJson(String source) =>
      CreateMatch.fromMap(json.decode(source));
}

/// Join a multiplayer match.
class JoinMatch implements Serializable {
  String match_id;
  String token;
  Map<String, dynamic> metadata;
  JoinMatch({
    this.match_id,
    this.token,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'match_join': {
        'match_id': match_id,
        'token': token,
        'metadata': metadata,
      }
    };
  }

  factory JoinMatch.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return JoinMatch(
      match_id: map['match_id'],
      token: map['token'],
      metadata: Map<String, dynamic>.from(map['metadata']),
    );
  }

  String toJson() => json.encode(toMap());

  factory JoinMatch.fromJson(String source) =>
      JoinMatch.fromMap(json.decode(source));
}

/// Leave a multiplayer match.

class LeaveMatch {
  String match_id;
  LeaveMatch({
    this.match_id,
  });
}

/// Match data */

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

class Status {
  List<Presence> presences;
  Status({
    this.presences,
  });
}

/// Start receiving status updates for some set of users.

class StatusFollow {
  List<String> status_follow;
  StatusFollow({
    this.status_follow,
  });
}

/// A batch of status updates for a given user.

class StatusPresenceEvent {
  List<Presence> joins;
  List<Presence> leaves;
  StatusPresenceEvent({
    this.joins,
    this.leaves,
  });
}

/// Stop receiving status updates for some set of users.

class StatusUnfollow {
  List<String> status_follow;
  StatusUnfollow({
    this.status_follow,
  });
}

/// Set the user's own status.

class StatusUpdate {
  Status status_update;
  StatusUpdate({
    this.status_update,
  });
}

abstract class Serializable {
  String toJson();
}
