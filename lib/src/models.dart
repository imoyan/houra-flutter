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
  const HouraRoom({required this.roomId, required this.membership, this.name});

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
    if (type != 'houra.room.message') {
      return null;
    }
    final msgtype = content['msgtype'];
    if (msgtype != 'houra.text') {
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
    return HouraSendMessageResponse(eventId: _requiredString(json, 'event_id'));
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

/// SPEC-069 Matrix device key query response.
final class HouraDeviceKeyQueryResponse {
  const HouraDeviceKeyQueryResponse({
    required this.failures,
    required this.deviceKeys,
  });

  /// Remote homeserver failures, keyed by homeserver name.
  final Map<String, Object?> failures;

  /// Public device keys keyed by Matrix user id, then device id.
  final Map<String, Map<String, HouraMatrixDeviceKey>> deviceKeys;

  factory HouraDeviceKeyQueryResponse.fromJson(Map<String, Object?> json) {
    return HouraDeviceKeyQueryResponse(
      failures: _requiredJsonObject(json, 'failures'),
      deviceKeys: _requiredDeviceKeyUsers(json, 'device_keys'),
    );
  }
}

/// Public Matrix device key object from SPEC-069.
final class HouraMatrixDeviceKey {
  const HouraMatrixDeviceKey({
    required this.userId,
    required this.deviceId,
    required this.algorithms,
    required this.keys,
    required this.signatures,
    required this.raw,
    this.unsigned,
  });

  final String userId;
  final String deviceId;
  final List<String> algorithms;
  final Map<String, String> keys;
  final Map<String, Map<String, String>> signatures;

  /// Optional unsigned metadata such as device display name.
  final Map<String, Object?>? unsigned;

  /// Original public object, preserved for unknown field round-tripping.
  final Map<String, Object?> raw;

  factory HouraMatrixDeviceKey.fromJson(Map<String, Object?> json) {
    return HouraMatrixDeviceKey(
      userId: _requiredString(json, 'user_id'),
      deviceId: _requiredString(json, 'device_id'),
      algorithms: _requiredStringList(json, 'algorithms'),
      keys: _requiredStringMap(json, 'keys'),
      signatures: _requiredNestedStringMap(json, 'signatures'),
      unsigned: _optionalJsonObject(json, 'unsigned'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'user_id': userId,
        'device_id': deviceId,
        'algorithms': algorithms,
        'keys': keys,
        'signatures': signatures,
        if (unsigned != null) 'unsigned': unsigned,
      };
}

/// SPEC-051 Matrix key upload response.
final class HouraKeyUploadResponse {
  const HouraKeyUploadResponse({required this.oneTimeKeyCounts});

  final Map<String, int> oneTimeKeyCounts;

  factory HouraKeyUploadResponse.fromJson(Map<String, Object?> json) {
    return HouraKeyUploadResponse(
      oneTimeKeyCounts: _requiredIntMap(json, 'one_time_key_counts'),
    );
  }
}

/// SPEC-051 Matrix key claim response.
final class HouraKeyClaimResponse {
  const HouraKeyClaimResponse({
    required this.failures,
    required this.oneTimeKeys,
  });

  /// Remote homeserver failures, keyed by homeserver name.
  final Map<String, Object?> failures;

  /// Public one-time or fallback keys keyed by user id, device id, and key id.
  final Map<String, Map<String, Map<String, HouraMatrixSignedKey>>> oneTimeKeys;

  factory HouraKeyClaimResponse.fromJson(Map<String, Object?> json) {
    return HouraKeyClaimResponse(
      failures: _requiredJsonObject(json, 'failures'),
      oneTimeKeys: _requiredClaimKeyUsers(json, 'one_time_keys'),
    );
  }
}

/// Public Matrix signed one-time or fallback key object from SPEC-051.
final class HouraMatrixSignedKey {
  const HouraMatrixSignedKey({
    required this.key,
    required this.signatures,
    required this.raw,
    this.fallback,
  });

  final String key;
  final bool? fallback;
  final Map<String, Map<String, String>> signatures;

  /// Original public object, preserved for unknown field round-tripping.
  final Map<String, Object?> raw;

  factory HouraMatrixSignedKey.fromJson(Map<String, Object?> json) {
    return HouraMatrixSignedKey(
      key: _requiredString(json, 'key'),
      fallback: _optionalBool(json, 'fallback'),
      signatures: _requiredNestedStringMap(json, 'signatures'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'key': key,
        'signatures': signatures,
        if (fallback != null) 'fallback': fallback,
      };
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

Map<String, Object?>? _optionalJsonObject(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is Map) {
    return Map<String, Object?>.unmodifiable(value.cast<String, Object?>());
  }
  throw HouraResponseFormatException('Expected optional object "$key".');
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
        return Map<String, Object?>.unmodifiable(item.cast<String, Object?>());
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

bool? _optionalBool(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value;
  }
  throw HouraResponseFormatException('Expected optional boolean "$key".');
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

Map<String, String> _requiredStringMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! Map) {
    throw HouraResponseFormatException('Expected string map "$key".');
  }
  return Map<String, String>.unmodifiable(
    value.cast<String, Object?>().map((mapKey, mapValue) {
      if (mapValue is! String || mapValue.isEmpty) {
        throw HouraResponseFormatException('Expected string map "$key".');
      }
      return MapEntry(mapKey, mapValue);
    }),
  );
}

Map<String, int> _requiredIntMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! Map) {
    throw HouraResponseFormatException('Expected integer map "$key".');
  }
  return Map<String, int>.unmodifiable(
    value.cast<String, Object?>().map((mapKey, mapValue) {
      if (mapValue is! int || mapValue < 0) {
        throw HouraResponseFormatException('Expected integer map "$key".');
      }
      return MapEntry(mapKey, mapValue);
    }),
  );
}

Map<String, Map<String, String>> _requiredNestedStringMap(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is! Map) {
    throw HouraResponseFormatException('Expected nested string map "$key".');
  }
  return Map<String, Map<String, String>>.unmodifiable(
    value.cast<String, Object?>().map((mapKey, mapValue) {
      if (mapValue is! Map) {
        throw HouraResponseFormatException(
          'Expected nested string map "$key".',
        );
      }
      final inner = mapValue.cast<String, Object?>().map((
        innerKey,
        innerValue,
      ) {
        if (innerValue is! String || innerValue.isEmpty) {
          throw HouraResponseFormatException(
            'Expected nested string map "$key".',
          );
        }
        return MapEntry(innerKey, innerValue);
      });
      return MapEntry(mapKey, Map<String, String>.unmodifiable(inner));
    }),
  );
}

Map<String, Map<String, HouraMatrixDeviceKey>> _requiredDeviceKeyUsers(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is! Map) {
    throw HouraResponseFormatException('Expected device key map "$key".');
  }
  return Map<String, Map<String, HouraMatrixDeviceKey>>.unmodifiable(
    value.cast<String, Object?>().map((userId, devicesValue) {
      if (devicesValue is! Map) {
        throw HouraResponseFormatException('Expected device key map "$key".');
      }
      final devices = devicesValue.cast<String, Object?>().map((
        deviceId,
        deviceValue,
      ) {
        if (deviceValue is! Map) {
          throw HouraResponseFormatException('Expected device key object.');
        }
        return MapEntry(
          deviceId,
          HouraMatrixDeviceKey.fromJson(deviceValue.cast<String, Object?>()),
        );
      });
      return MapEntry(
        userId,
        Map<String, HouraMatrixDeviceKey>.unmodifiable(devices),
      );
    }),
  );
}

Map<String, Map<String, Map<String, HouraMatrixSignedKey>>>
    _requiredClaimKeyUsers(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! Map) {
    throw HouraResponseFormatException('Expected claim key map "$key".');
  }
  return Map<String,
      Map<String, Map<String, HouraMatrixSignedKey>>>.unmodifiable(
    value.cast<String, Object?>().map((userId, devicesValue) {
      if (devicesValue is! Map) {
        throw HouraResponseFormatException('Expected claim key map "$key".');
      }
      final devices = devicesValue.cast<String, Object?>().map((
        deviceId,
        keysValue,
      ) {
        if (keysValue is! Map) {
          throw HouraResponseFormatException('Expected claim key map "$key".');
        }
        final keys = keysValue.cast<String, Object?>().map((keyId, keyValue) {
          if (keyValue is! Map) {
            throw HouraResponseFormatException('Expected signed key object.');
          }
          return MapEntry(
            keyId,
            HouraMatrixSignedKey.fromJson(keyValue.cast<String, Object?>()),
          );
        });
        return MapEntry(
          deviceId,
          Map<String, HouraMatrixSignedKey>.unmodifiable(keys),
        );
      });
      return MapEntry(
        userId,
        Map<String, Map<String, HouraMatrixSignedKey>>.unmodifiable(devices),
      );
    }),
  );
}
