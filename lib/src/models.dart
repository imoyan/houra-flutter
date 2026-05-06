import 'errors.dart';

/// SPEC-001 Discovery / Versions response.
final class OkakaServerVersions {
  const OkakaServerVersions({
    required this.project,
    required this.apiVersion,
    required this.compatibilityLevel,
    required this.features,
  });

  final String project;
  final String apiVersion;
  final String compatibilityLevel;
  final List<String> features;

  factory OkakaServerVersions.fromJson(Map<String, Object?> json) {
    return OkakaServerVersions(
      project: _requiredString(json, 'project'),
      apiVersion: _requiredString(json, 'api_version'),
      compatibilityLevel: _requiredString(json, 'compatibility_level'),
      features: _requiredStringList(json, 'features'),
    );
  }
}

/// SPEC-003 Login Flow Discovery response.
final class OkakaLoginFlows {
  const OkakaLoginFlows({required this.flows});

  final List<OkakaLoginFlow> flows;

  factory OkakaLoginFlows.fromJson(Map<String, Object?> json) {
    final value = json['flows'];
    if (value is! List || value.isEmpty) {
      throw OkakaResponseFormatException(
        'Expected non-empty login flow array "flows".',
      );
    }
    return OkakaLoginFlows(
      flows: List.unmodifiable(
        value.map((item) {
          if (item is Map) {
            return OkakaLoginFlow.fromJson(item.cast<String, Object?>());
          }
          throw OkakaResponseFormatException(
            'Expected login flow object in "flows".',
          );
        }),
      ),
    );
  }
}

/// One supported login flow.
final class OkakaLoginFlow {
  const OkakaLoginFlow({required this.type});

  final String type;

  factory OkakaLoginFlow.fromJson(Map<String, Object?> json) {
    return OkakaLoginFlow(type: _requiredString(json, 'type'));
  }
}

/// SPEC-004 login response.
final class OkakaAuthSession {
  const OkakaAuthSession({
    required this.userId,
    required this.accessToken,
    this.deviceId,
  });

  final String userId;
  final String accessToken;
  final String? deviceId;

  factory OkakaAuthSession.fromJson(Map<String, Object?> json) {
    return OkakaAuthSession(
      userId: _requiredString(json, 'user_id'),
      accessToken: _requiredString(json, 'access_token'),
      deviceId: _optionalString(json, 'device_id'),
    );
  }
}

/// SPEC-004 current token identity response.
final class OkakaWhoami {
  const OkakaWhoami({required this.userId, this.deviceId});

  final String userId;
  final String? deviceId;

  factory OkakaWhoami.fromJson(Map<String, Object?> json) {
    return OkakaWhoami(
      userId: _requiredString(json, 'user_id'),
      deviceId: _optionalString(json, 'device_id'),
    );
  }
}

/// SPEC-006 room membership values.
enum OkakaRoomMembership {
  join('join'),
  invite('invite'),
  leave('leave');

  const OkakaRoomMembership(this.wireName);

  final String wireName;

  static OkakaRoomMembership parse(String value) {
    for (final membership in values) {
      if (membership.wireName == value) {
        return membership;
      }
    }
    throw OkakaResponseFormatException('Unknown room membership "$value".');
  }
}

/// SPEC-006 room object.
final class OkakaRoom {
  const OkakaRoom({
    required this.roomId,
    required this.membership,
    this.name,
  });

  final String roomId;
  final OkakaRoomMembership membership;
  final String? name;

  factory OkakaRoom.fromJson(Map<String, Object?> json) {
    return OkakaRoom(
      roomId: _requiredString(json, 'room_id'),
      name: _optionalString(json, 'name'),
      membership: OkakaRoomMembership.parse(
        _requiredString(json, 'membership'),
      ),
    );
  }
}

/// SPEC-006 room state response.
final class OkakaRoomState {
  const OkakaRoomState({required this.events});

  final List<OkakaEvent> events;

  factory OkakaRoomState.fromJson(Map<String, Object?> json) {
    return OkakaRoomState(events: _requiredEventList(json, 'events'));
  }
}

/// SPEC-007 event object.
final class OkakaEvent {
  const OkakaEvent({
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

  factory OkakaEvent.fromJson(Map<String, Object?> json) {
    return OkakaEvent(
      eventId: _requiredString(json, 'event_id'),
      roomId: _requiredString(json, 'room_id'),
      sender: _requiredString(json, 'sender'),
      originServerTs: _requiredInt(json, 'origin_server_ts'),
      type: _requiredString(json, 'type'),
      content: _requiredJsonObject(json, 'content'),
    );
  }

  OkakaTextMessageEvent? get textMessage {
    if (type != 'chawan.room.message') {
      return null;
    }
    final msgtype = content['msgtype'];
    if (msgtype != 'chawan.text') {
      return null;
    }
    return OkakaTextMessageEvent(
      event: this,
      body: _requiredString(content, 'body'),
    );
  }
}

/// Typed view of a SPEC-007 text message event.
final class OkakaTextMessageEvent {
  const OkakaTextMessageEvent({required this.event, required this.body});

  final OkakaEvent event;
  final String body;
}

/// SPEC-008 send message response.
final class OkakaSendMessageResponse {
  const OkakaSendMessageResponse({required this.eventId});

  final String eventId;

  factory OkakaSendMessageResponse.fromJson(Map<String, Object?> json) {
    return OkakaSendMessageResponse(
      eventId: _requiredString(json, 'event_id'),
    );
  }
}

/// SPEC-009 room list response.
final class OkakaRoomList {
  const OkakaRoomList({required this.rooms});

  final List<OkakaRoom> rooms;

  factory OkakaRoomList.fromJson(Map<String, Object?> json) {
    return OkakaRoomList(
      rooms: List.unmodifiable(
        _requiredObjectList(json, 'rooms').map(OkakaRoom.fromJson),
      ),
    );
  }
}

/// SPEC-010 room timeline response.
final class OkakaTimelinePage {
  const OkakaTimelinePage({
    required this.events,
    required this.start,
    this.end,
  });

  final List<OkakaEvent> events;
  final String start;
  final String? end;

  factory OkakaTimelinePage.fromJson(Map<String, Object?> json) {
    return OkakaTimelinePage(
      events: _requiredEventList(json, 'events'),
      start: _requiredString(json, 'start'),
      end: _optionalString(json, 'end'),
    );
  }
}

/// SPEC-011 incremental sync response.
final class OkakaSyncBatch {
  const OkakaSyncBatch({required this.nextBatch, required this.rooms});

  final String nextBatch;
  final List<OkakaSyncRoom> rooms;

  factory OkakaSyncBatch.fromJson(Map<String, Object?> json) {
    return OkakaSyncBatch(
      nextBatch: _requiredString(json, 'next_batch'),
      rooms: List.unmodifiable(
        _requiredObjectList(json, 'rooms').map(OkakaSyncRoom.fromJson),
      ),
    );
  }
}

/// One room entry in a SPEC-011 sync response.
final class OkakaSyncRoom {
  const OkakaSyncRoom({required this.roomId, required this.timeline});

  final String roomId;
  final OkakaSyncTimeline timeline;

  factory OkakaSyncRoom.fromJson(Map<String, Object?> json) {
    return OkakaSyncRoom(
      roomId: _requiredString(json, 'room_id'),
      timeline: OkakaSyncTimeline.fromJson(
        _requiredJsonObject(json, 'timeline'),
      ),
    );
  }
}

/// Timeline portion of one sync room entry.
final class OkakaSyncTimeline {
  const OkakaSyncTimeline({required this.events});

  final List<OkakaEvent> events;

  factory OkakaSyncTimeline.fromJson(Map<String, Object?> json) {
    return OkakaSyncTimeline(events: _requiredEventList(json, 'events'));
  }
}

/// SPEC-020 media upload response.
final class OkakaMediaUpload {
  const OkakaMediaUpload({required this.mediaId, required this.contentUri});

  final String mediaId;
  final String contentUri;

  factory OkakaMediaUpload.fromJson(Map<String, Object?> json) {
    return OkakaMediaUpload(
      mediaId: _requiredString(json, 'media_id'),
      contentUri: _requiredString(json, 'content_uri'),
    );
  }
}

/// SPEC-020 media metadata response.
final class OkakaMediaMetadata {
  const OkakaMediaMetadata({
    required this.mediaId,
    required this.contentType,
    required this.downloadUrl,
    this.filename,
  });

  final String mediaId;
  final String? filename;
  final String contentType;
  final String downloadUrl;

  factory OkakaMediaMetadata.fromJson(Map<String, Object?> json) {
    return OkakaMediaMetadata(
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
  throw OkakaResponseFormatException('Expected non-empty string "$key".');
}

int _requiredInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  throw OkakaResponseFormatException('Expected integer "$key".');
}

Map<String, Object?> _requiredJsonObject(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is Map) {
    return Map<String, Object?>.unmodifiable(value.cast<String, Object?>());
  }
  throw OkakaResponseFormatException('Expected object "$key".');
}

List<Map<String, Object?>> _requiredObjectList(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is! List) {
    throw OkakaResponseFormatException('Expected object array "$key".');
  }
  return List<Map<String, Object?>>.unmodifiable(
    value.map((item) {
      if (item is Map) {
        return Map<String, Object?>.unmodifiable(
          item.cast<String, Object?>(),
        );
      }
      throw OkakaResponseFormatException('Expected object array "$key".');
    }),
  );
}

List<OkakaEvent> _requiredEventList(Map<String, Object?> json, String key) {
  return List.unmodifiable(
    _requiredObjectList(json, key).map(OkakaEvent.fromJson),
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
  throw OkakaResponseFormatException('Expected optional string "$key".');
}

List<String> _requiredStringList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List) {
    throw OkakaResponseFormatException('Expected string array "$key".');
  }
  final result = <String>[];
  for (final item in value) {
    if (item is! String || item.isEmpty) {
      throw OkakaResponseFormatException('Expected string array "$key".');
    }
    result.add(item);
  }
  return List.unmodifiable(result);
}
