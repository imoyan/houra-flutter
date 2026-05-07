import 'errors.dart';

/// SPEC-001 Discovery / Versions response.
final class HouraServerVersions {
  const HouraServerVersions({
    required this.project,
    required this.apiVersion,
    required this.compatibilityLevel,
    required this.features,
  });

  final String project;
  final String apiVersion;
  final String compatibilityLevel;
  final List<String> features;

  factory HouraServerVersions.fromJson(Map<String, Object?> json) {
    return HouraServerVersions(
      project: _requiredString(json, 'project'),
      apiVersion: _requiredString(json, 'api_version'),
      compatibilityLevel: _requiredString(json, 'compatibility_level'),
      features: _requiredStringList(json, 'features'),
    );
  }
}

/// SPEC-003 Login Flow Discovery response.
final class HouraLoginFlows {
  const HouraLoginFlows({required this.flows});

  final List<HouraLoginFlow> flows;

  factory HouraLoginFlows.fromJson(Map<String, Object?> json) {
    final value = json['flows'];
    if (value is! List || value.isEmpty) {
      throw HouraResponseFormatException(
        'Expected non-empty login flow array "flows".',
      );
    }
    return HouraLoginFlows(
      flows: List.unmodifiable(
        value.map((item) {
          if (item is Map) {
            return HouraLoginFlow.fromJson(item.cast<String, Object?>());
          }
          throw HouraResponseFormatException(
            'Expected login flow object in "flows".',
          );
        }),
      ),
    );
  }
}

/// One supported login flow.
final class HouraLoginFlow {
  const HouraLoginFlow({required this.type});

  final String type;

  factory HouraLoginFlow.fromJson(Map<String, Object?> json) {
    return HouraLoginFlow(type: _requiredString(json, 'type'));
  }
}

/// SPEC-004 login response.
final class HouraAuthSession {
  const HouraAuthSession({
    required this.userId,
    required this.accessToken,
    this.deviceId,
  });

  final String userId;
  final String accessToken;
  final String? deviceId;

  factory HouraAuthSession.fromJson(Map<String, Object?> json) {
    return HouraAuthSession(
      userId: _requiredString(json, 'user_id'),
      accessToken: _requiredString(json, 'access_token'),
      deviceId: _optionalString(json, 'device_id'),
    );
  }
}

/// SPEC-004 current token identity response.
final class HouraWhoami {
  const HouraWhoami({required this.userId, this.deviceId});

  final String userId;
  final String? deviceId;

  factory HouraWhoami.fromJson(Map<String, Object?> json) {
    return HouraWhoami(
      userId: _requiredString(json, 'user_id'),
      deviceId: _optionalString(json, 'device_id'),
    );
  }
}

/// SPEC-006 room membership values.
enum HouraRoomMembership {
  join('join'),
  invite('invite'),
  leave('leave');

  const HouraRoomMembership(this.wireName);

  final String wireName;

  static HouraRoomMembership parse(String value) {
    for (final membership in values) {
      if (membership.wireName == value) {
        return membership;
      }
    }
    throw HouraResponseFormatException('Unknown room membership "$value".');
  }
}

/// SPEC-006 room object.
final class HouraRoom {
  const HouraRoom({
    required this.roomId,
    required this.membership,
    this.name,
  });

  final String roomId;
  final HouraRoomMembership membership;
  final String? name;

  factory HouraRoom.fromJson(Map<String, Object?> json) {
    return HouraRoom(
      roomId: _requiredString(json, 'room_id'),
      name: _optionalString(json, 'name'),
      membership: HouraRoomMembership.parse(
        _requiredString(json, 'membership'),
      ),
    );
  }
}

/// SPEC-006 room state response.
final class HouraRoomState {
  const HouraRoomState({required this.events});

  final List<HouraEvent> events;

  factory HouraRoomState.fromJson(Map<String, Object?> json) {
    return HouraRoomState(events: _requiredEventList(json, 'events'));
  }
}

/// SPEC-007 event object.
final class HouraEvent {
  const HouraEvent({
    required this.eventId,
    required this.roomId,
    required this.sender,
    required this.originServerTs,
    required this.type,
    required this.content,
  });

  final String eventId;
  final String roomId;
  final String sender;
  final int originServerTs;
  final String type;
  final Map<String, Object?> content;

  factory HouraEvent.fromJson(Map<String, Object?> json) {
    return HouraEvent(
      eventId: _requiredString(json, 'event_id'),
      roomId: _requiredString(json, 'room_id'),
      sender: _requiredString(json, 'sender'),
      originServerTs: _requiredInt(json, 'origin_server_ts'),
      type: _requiredString(json, 'type'),
      content: _requiredJsonObject(json, 'content'),
    );
  }

  HouraTextMessageEvent? get textMessage {
    if (type != 'ichigo.room.message') {
      return null;
    }
    final msgtype = content['msgtype'];
    if (msgtype != 'ichigo.text') {
      return null;
    }
    return HouraTextMessageEvent(
      event: this,
      body: _requiredString(content, 'body'),
    );
  }
}

/// Typed view of a SPEC-007 text message event.
final class HouraTextMessageEvent {
  const HouraTextMessageEvent({required this.event, required this.body});

  final HouraEvent event;
  final String body;
}

/// SPEC-008 send message response.
final class HouraSendMessageResponse {
  const HouraSendMessageResponse({required this.eventId});

  final String eventId;

  factory HouraSendMessageResponse.fromJson(Map<String, Object?> json) {
    return HouraSendMessageResponse(
      eventId: _requiredString(json, 'event_id'),
    );
  }
}

/// SPEC-009 room list response.
final class HouraRoomList {
  const HouraRoomList({required this.rooms});

  final List<HouraRoom> rooms;

  factory HouraRoomList.fromJson(Map<String, Object?> json) {
    return HouraRoomList(
      rooms: List.unmodifiable(
        _requiredObjectList(json, 'rooms').map(HouraRoom.fromJson),
      ),
    );
  }
}

/// SPEC-010 room timeline response.
final class HouraTimelinePage {
  const HouraTimelinePage({
    required this.events,
    required this.start,
    this.end,
  });

  final List<HouraEvent> events;
  final String start;
  final String? end;

  factory HouraTimelinePage.fromJson(Map<String, Object?> json) {
    return HouraTimelinePage(
      events: _requiredEventList(json, 'events'),
      start: _requiredString(json, 'start'),
      end: _optionalString(json, 'end'),
    );
  }
}

/// SPEC-011 incremental sync response.
final class HouraSyncBatch {
  const HouraSyncBatch({required this.nextBatch, required this.rooms});

  final String nextBatch;
  final List<HouraSyncRoom> rooms;

  factory HouraSyncBatch.fromJson(Map<String, Object?> json) {
    return HouraSyncBatch(
      nextBatch: _requiredString(json, 'next_batch'),
      rooms: List.unmodifiable(
        _requiredObjectList(json, 'rooms').map(HouraSyncRoom.fromJson),
      ),
    );
  }
}

/// One room entry in a SPEC-011 sync response.
final class HouraSyncRoom {
  const HouraSyncRoom({required this.roomId, required this.timeline});

  final String roomId;
  final HouraSyncTimeline timeline;

  factory HouraSyncRoom.fromJson(Map<String, Object?> json) {
    return HouraSyncRoom(
      roomId: _requiredString(json, 'room_id'),
      timeline: HouraSyncTimeline.fromJson(
        _requiredJsonObject(json, 'timeline'),
      ),
    );
  }
}

/// Timeline portion of one sync room entry.
final class HouraSyncTimeline {
  const HouraSyncTimeline({required this.events});

  final List<HouraEvent> events;

  factory HouraSyncTimeline.fromJson(Map<String, Object?> json) {
    return HouraSyncTimeline(events: _requiredEventList(json, 'events'));
  }
}

/// SPEC-020 media upload response.
final class HouraMediaUpload {
  const HouraMediaUpload({required this.mediaId, required this.contentUri});

  final String mediaId;
  final String contentUri;

  factory HouraMediaUpload.fromJson(Map<String, Object?> json) {
    return HouraMediaUpload(
      mediaId: _requiredString(json, 'media_id'),
      contentUri: _requiredString(json, 'content_uri'),
    );
  }
}

/// SPEC-020 media metadata response.
final class HouraMediaMetadata {
  const HouraMediaMetadata({
    required this.mediaId,
    required this.contentType,
    required this.downloadUrl,
    this.filename,
  });

  final String mediaId;
  final String? filename;
  final String contentType;
  final String downloadUrl;

  factory HouraMediaMetadata.fromJson(Map<String, Object?> json) {
    return HouraMediaMetadata(
      mediaId: _requiredString(json, 'media_id'),
      filename: _optionalString(json, 'filename'),
      contentType: _requiredString(json, 'content_type'),
      downloadUrl: _requiredString(json, 'download_url'),
    );
  }
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw HouraResponseFormatException('Expected non-empty string "$key".');
}

int _requiredInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  throw HouraResponseFormatException('Expected integer "$key".');
}

Map<String, Object?> _requiredJsonObject(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is Map) {
    return Map<String, Object?>.unmodifiable(value.cast<String, Object?>());
  }
  throw HouraResponseFormatException('Expected object "$key".');
}

List<Map<String, Object?>> _requiredObjectList(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is! List) {
    throw HouraResponseFormatException('Expected object array "$key".');
  }
  return List<Map<String, Object?>>.unmodifiable(
    value.map((item) {
      if (item is Map) {
        return Map<String, Object?>.unmodifiable(
          item.cast<String, Object?>(),
        );
      }
      throw HouraResponseFormatException('Expected object array "$key".');
    }),
  );
}

List<HouraEvent> _requiredEventList(Map<String, Object?> json, String key) {
  return List.unmodifiable(
    _requiredObjectList(json, key).map(HouraEvent.fromJson),
  );
}

String? _optionalString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw HouraResponseFormatException('Expected optional string "$key".');
}

List<String> _requiredStringList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List) {
    throw HouraResponseFormatException('Expected string array "$key".');
  }
  final result = <String>[];
  for (final item in value) {
    if (item is! String || item.isEmpty) {
      throw HouraResponseFormatException('Expected string array "$key".');
    }
    result.add(item);
  }
  return List.unmodifiable(result);
}
