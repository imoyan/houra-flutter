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

  HouraEncryptedPayload? get encryptedPayload {
    if (type != 'm.room.encrypted') {
      return null;
    }
    return HouraEncryptedPayload.fromJson(content);
  }
}

/// SPEC-085 Matrix ClientEvent parser-only envelope.
final class HouraMatrixClientEvent {
  const HouraMatrixClientEvent({
    required this.eventId,
    required this.roomId,
    required this.sender,
    required this.originServerTs,
    required this.type,
    required this.content,
    required this.raw,
    this.stateKey,
    this.unsigned,
  });

  final String eventId;
  final String roomId;
  final String sender;
  final int originServerTs;
  final String type;
  final Map<String, Object?> content;
  final String? stateKey;
  final Map<String, Object?>? unsigned;

  /// Original Matrix event object, preserved for unknown field inspection.
  final Map<String, Object?> raw;

  factory HouraMatrixClientEvent.fromJson(Map<String, Object?> json) {
    return HouraMatrixClientEvent(
      eventId: _requiredString(json, 'event_id'),
      roomId: _requiredString(json, 'room_id'),
      sender: _requiredString(json, 'sender'),
      originServerTs: _requiredNonNegativeInt(json, 'origin_server_ts'),
      type: _requiredString(json, 'type'),
      stateKey: _optionalString(json, 'state_key'),
      content: _requiredJsonObject(json, 'content'),
      unsigned: _optionalJsonObject(json, 'unsigned'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  bool get isMembershipEvent => type == 'm.room.member';

  String? get membership {
    if (!isMembershipEvent) {
      return null;
    }
    final value = content['membership'];
    if (value is String && _isMatrixMembershipValue(value)) {
      return value;
    }
    throw HouraResponseFormatException(
      'Expected Matrix membership value "content.membership".',
    );
  }

  HouraMatrixReactionRelation? get reactionRelation {
    if (type != 'm.reaction') {
      return null;
    }
    final relatesTo = _requiredJsonObject(content, 'm.relates_to');
    final relType = _requiredString(relatesTo, 'rel_type');
    if (relType != 'm.annotation') {
      throw HouraResponseFormatException(
        'Expected Matrix relation type "m.annotation".',
      );
    }
    return HouraMatrixReactionRelation(
      eventId: _requiredString(relatesTo, 'event_id'),
      key: _requiredString(relatesTo, 'key'),
    );
  }

  HouraMatrixThreadSummary? get threadSummary {
    final unsigned = this.unsigned;
    if (unsigned == null) {
      return null;
    }
    final relations = unsigned['m.relations'];
    if (relations is! Map) {
      return null;
    }
    final thread = relations['m.thread'];
    if (thread is! Map) {
      return null;
    }
    return HouraMatrixThreadSummary.fromJson(thread.cast<String, Object?>());
  }

  HouraMatrixEditRelation? get editRelation {
    final relatesTo = content['m.relates_to'];
    if (relatesTo is! Map) {
      return null;
    }
    final relation = relatesTo.cast<String, Object?>();
    final relType = relation['rel_type'];
    if (relType != 'm.replace') {
      return null;
    }
    final newContent = content['m.new_content'];
    if (newContent is! Map) {
      throw HouraResponseFormatException(
        'Expected object "content.m.new_content".',
      );
    }
    return HouraMatrixEditRelation(
      eventId: _requiredString(relation, 'event_id'),
      newContent: Map<String, Object?>.unmodifiable(
        newContent.cast<String, Object?>(),
      ),
    );
  }

  String? get replyToEventId {
    final relatesTo = content['m.relates_to'];
    if (relatesTo is! Map) {
      return null;
    }
    final reply = relatesTo['m.in_reply_to'];
    if (reply is! Map) {
      return null;
    }
    return _requiredString(reply.cast<String, Object?>(), 'event_id');
  }
}

/// SPEC-090 Matrix relation chunk response.
final class HouraMatrixRelationChunk {
  const HouraMatrixRelationChunk({
    required this.chunk,
    this.nextBatch,
    this.prevBatch,
  });

  final List<HouraMatrixClientEvent> chunk;
  final String? nextBatch;
  final String? prevBatch;

  factory HouraMatrixRelationChunk.fromJson(Map<String, Object?> json) {
    final events = _requiredObjectList(json, 'chunk')
        .map((event) => HouraMatrixClientEvent.fromJson(event))
        .toList(growable: false);
    for (final event in events) {
      if (event.type == 'm.reaction') {
        event.reactionRelation;
      }
    }
    return HouraMatrixRelationChunk(
      chunk: List.unmodifiable(events),
      nextBatch: _optionalString(json, 'next_batch'),
      prevBatch: _optionalString(json, 'prev_batch'),
    );
  }
}

/// SPEC-090 Matrix thread roots response.
final class HouraMatrixThreadRoots {
  const HouraMatrixThreadRoots({required this.chunk, this.nextBatch});

  final List<HouraMatrixClientEvent> chunk;
  final String? nextBatch;

  factory HouraMatrixThreadRoots.fromJson(Map<String, Object?> json) {
    final events = _requiredObjectList(json, 'chunk')
        .map((event) => HouraMatrixClientEvent.fromJson(event))
        .toList(growable: false);
    for (final event in events) {
      if (event.threadSummary == null) {
        throw HouraResponseFormatException(
          'Expected Matrix thread summary in "unsigned.m.relations.m.thread".',
        );
      }
    }
    return HouraMatrixThreadRoots(
      chunk: List.unmodifiable(events),
      nextBatch: _optionalString(json, 'next_batch'),
    );
  }
}

final class HouraMatrixReactionRelation {
  const HouraMatrixReactionRelation({required this.eventId, required this.key});

  final String eventId;
  final String key;
}

final class HouraMatrixThreadSummary {
  const HouraMatrixThreadSummary({
    required this.count,
    required this.currentUserParticipated,
    required this.latestEvent,
  });

  final int count;
  final bool currentUserParticipated;
  final HouraMatrixClientEvent latestEvent;

  factory HouraMatrixThreadSummary.fromJson(Map<String, Object?> json) {
    return HouraMatrixThreadSummary(
      count: _requiredNonNegativeInt(json, 'count'),
      currentUserParticipated: _requiredBool(json, 'current_user_participated'),
      latestEvent: HouraMatrixClientEvent.fromJson(
        _requiredJsonObject(json, 'latest_event'),
      ),
    );
  }
}

final class HouraMatrixEditRelation {
  const HouraMatrixEditRelation({
    required this.eventId,
    required this.newContent,
  });

  final String eventId;
  final Map<String, Object?> newContent;
}

/// SPEC-085 Matrix joined_members response.
final class HouraMatrixJoinedMembers {
  const HouraMatrixJoinedMembers({required this.joined});

  final Map<String, HouraMatrixJoinedMember> joined;

  factory HouraMatrixJoinedMembers.fromJson(Map<String, Object?> json) {
    final value = json['joined'];
    if (value is! Map || value.isEmpty) {
      throw HouraResponseFormatException('Expected non-empty object "joined".');
    }
    return HouraMatrixJoinedMembers(
      joined: Map<String, HouraMatrixJoinedMember>.unmodifiable(
        value.cast<String, Object?>().map((userId, memberValue) {
          if (memberValue is! Map) {
            throw HouraResponseFormatException(
              'Expected joined member object.',
            );
          }
          return MapEntry(
            userId,
            HouraMatrixJoinedMember.fromJson(
              memberValue.cast<String, Object?>(),
            ),
          );
        }),
      ),
    );
  }
}

/// SPEC-085 Matrix joined member profile fields.
final class HouraMatrixJoinedMember {
  const HouraMatrixJoinedMember({this.displayName, this.avatarUrl});

  final String? displayName;
  final String? avatarUrl;

  factory HouraMatrixJoinedMember.fromJson(Map<String, Object?> json) {
    return HouraMatrixJoinedMember(
      displayName: _optionalString(json, 'display_name'),
      avatarUrl: _optionalString(json, 'avatar_url'),
    );
  }
}

/// SPEC-085 Matrix members response.
final class HouraMatrixMembers {
  const HouraMatrixMembers({required this.chunk});

  final List<HouraMatrixClientEvent> chunk;

  factory HouraMatrixMembers.fromJson(Map<String, Object?> json) {
    final events = _requiredObjectList(json, 'chunk')
        .map((event) => HouraMatrixClientEvent.fromJson(event))
        .toList(growable: false);
    for (final event in events) {
      if (!event.isMembershipEvent || event.stateKey == null) {
        throw HouraResponseFormatException(
          'Expected m.room.member state events in "chunk".',
        );
      }
      final membership = event.membership;
      if (membership == null) {
        throw HouraResponseFormatException(
          'Expected Matrix membership value "content.membership".',
        );
      }
    }
    return HouraMatrixMembers(chunk: List.unmodifiable(events));
  }
}

/// SPEC-085 Matrix timestamp_to_event response.
final class HouraMatrixTimestampToEvent {
  const HouraMatrixTimestampToEvent({
    required this.eventId,
    required this.originServerTs,
  });

  final String eventId;
  final int originServerTs;

  factory HouraMatrixTimestampToEvent.fromJson(Map<String, Object?> json) {
    return HouraMatrixTimestampToEvent(
      eventId: _requiredString(json, 'event_id'),
      originServerTs: _requiredNonNegativeInt(json, 'origin_server_ts'),
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

/// SPEC-052 Matrix sync response subset for to-device delivery.
final class HouraMatrixSyncBatch {
  const HouraMatrixSyncBatch({
    required this.nextBatch,
    required this.toDeviceEvents,
    this.presenceEvents = const [],
    this.deviceLists = const HouraMatrixDeviceLists(changed: [], left: []),
    this.deviceOneTimeKeysCount = const {},
    this.rooms = const HouraMatrixSyncRooms(
      join: {},
      invite: {},
      leave: {},
      knock: {},
    ),
  });

  final String nextBatch;
  final List<HouraMatrixBasicEvent> presenceEvents;
  final List<HouraMatrixToDeviceEvent> toDeviceEvents;
  final HouraMatrixDeviceLists deviceLists;
  final Map<String, int> deviceOneTimeKeysCount;
  final HouraMatrixSyncRooms rooms;

  factory HouraMatrixSyncBatch.fromJson(Map<String, Object?> json) {
    return HouraMatrixSyncBatch(
      nextBatch: _requiredString(json, 'next_batch'),
      presenceEvents: _optionalMatrixBasicEvents(json, 'presence'),
      toDeviceEvents: _optionalToDeviceEvents(json),
      deviceLists: HouraMatrixDeviceLists.fromJson(
        _optionalJsonObject(json, 'device_lists') ?? const <String, Object?>{},
      ),
      deviceOneTimeKeysCount: _optionalNonNegativeIntMap(
        json,
        'device_one_time_keys_count',
      ),
      rooms: HouraMatrixSyncRooms.fromJson(
        _optionalJsonObject(json, 'rooms') ?? const <String, Object?>{},
      ),
    );
  }
}

/// SPEC-093 parser-only Matrix sync request descriptor.
final class HouraMatrixSyncRequestDescriptor {
  const HouraMatrixSyncRequestDescriptor({
    required this.method,
    required this.path,
    required this.queryParams,
    required this.requiresAuth,
    required this.responseParser,
    required this.adoptedRuntimeBehavior,
  });

  final String method;
  final String path;
  final Map<String, Object?> queryParams;
  final bool requiresAuth;
  final String responseParser;
  final bool adoptedRuntimeBehavior;

  factory HouraMatrixSyncRequestDescriptor.fromJson(Map<String, Object?> json) {
    final descriptor = HouraMatrixSyncRequestDescriptor(
      method: _requiredString(json, 'method'),
      path: _requiredString(json, 'path'),
      queryParams: _requiredJsonObject(json, 'query_params'),
      requiresAuth: _requiredBool(json, 'requires_auth'),
      responseParser: _requiredString(json, 'response_parser'),
      adoptedRuntimeBehavior: _requiredBool(json, 'adopted_runtime_behavior'),
    );
    if (descriptor.method != 'GET' ||
        descriptor.path != '/_matrix/client/v3/sync' ||
        descriptor.responseParser != 'sync_extensions' ||
        descriptor.adoptedRuntimeBehavior) {
      throw HouraResponseFormatException(
        'Unsupported Matrix sync request descriptor.',
      );
    }
    _validateMatrixSyncQueryParams(descriptor.queryParams);
    return descriptor;
  }
}

/// SPEC-093 Matrix sync basic event used by presence and room-state snippets.
final class HouraMatrixBasicEvent {
  const HouraMatrixBasicEvent({
    required this.type,
    required this.content,
    required this.raw,
    this.sender,
    this.stateKey,
  });

  final String type;
  final String? sender;
  final String? stateKey;
  final Map<String, Object?> content;
  final Map<String, Object?> raw;

  factory HouraMatrixBasicEvent.fromJson(Map<String, Object?> json) {
    return HouraMatrixBasicEvent(
      type: _requiredString(json, 'type'),
      sender: _optionalString(json, 'sender'),
      stateKey: _optionalString(json, 'state_key'),
      content: _requiredJsonObject(json, 'content'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }
}

/// SPEC-093 Matrix sync device list changes.
final class HouraMatrixDeviceLists {
  const HouraMatrixDeviceLists({required this.changed, required this.left});

  final List<String> changed;
  final List<String> left;

  factory HouraMatrixDeviceLists.fromJson(Map<String, Object?> json) {
    return HouraMatrixDeviceLists(
      changed: _optionalMatrixUserIdList(json, 'changed'),
      left: _optionalMatrixUserIdList(json, 'left'),
    );
  }
}

/// SPEC-093 Matrix sync room section maps.
final class HouraMatrixSyncRooms {
  const HouraMatrixSyncRooms({
    required this.join,
    required this.invite,
    required this.leave,
    required this.knock,
  });

  final Map<String, Map<String, Object?>> join;
  final Map<String, Map<String, Object?>> invite;
  final Map<String, Map<String, Object?>> leave;
  final Map<String, Map<String, Object?>> knock;

  factory HouraMatrixSyncRooms.fromJson(Map<String, Object?> json) {
    return HouraMatrixSyncRooms(
      join: _optionalObjectMap(json, 'join'),
      invite: _optionalObjectMap(json, 'invite'),
      leave: _optionalObjectMap(json, 'leave'),
      knock: _optionalObjectMap(json, 'knock'),
    );
  }
}

/// SPEC-052 Matrix to-device event envelope.
final class HouraMatrixToDeviceEvent {
  const HouraMatrixToDeviceEvent({
    required this.sender,
    required this.type,
    required this.content,
    required this.raw,
  });

  final String sender;
  final String type;
  final Map<String, Object?> content;
  final Map<String, Object?> raw;

  factory HouraMatrixToDeviceEvent.fromJson(Map<String, Object?> json) {
    return HouraMatrixToDeviceEvent(
      sender: _requiredString(json, 'sender'),
      type: _requiredString(json, 'type'),
      content: _requiredJsonObject(json, 'content'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  HouraEncryptedPayload? get encryptedPayload {
    if (type != 'm.room.encrypted') {
      return null;
    }
    return HouraEncryptedPayload.fromJson(content);
  }
}

/// SPEC-052 Matrix encrypted event payload envelope.
final class HouraEncryptedPayload {
  const HouraEncryptedPayload({
    required this.algorithm,
    required this.raw,
    this.senderKey,
    this.megolmCiphertext,
    this.sessionId,
    this.deviceId,
    this.olmCiphertext,
  });

  final String algorithm;
  final String? senderKey;
  final String? megolmCiphertext;
  final String? sessionId;
  final String? deviceId;
  final Map<String, HouraOlmCiphertext>? olmCiphertext;
  final Map<String, Object?> raw;

  factory HouraEncryptedPayload.fromJson(Map<String, Object?> json) {
    final algorithm = _requiredString(json, 'algorithm');
    if (algorithm == 'm.megolm.v1.aes-sha2') {
      return HouraEncryptedPayload(
        algorithm: algorithm,
        senderKey: _requiredString(json, 'sender_key'),
        megolmCiphertext: _requiredString(json, 'ciphertext'),
        sessionId: _requiredString(json, 'session_id'),
        deviceId: _requiredString(json, 'device_id'),
        raw: Map<String, Object?>.unmodifiable(json),
      );
    }
    if (algorithm == 'm.olm.v1.curve25519-aes-sha2') {
      return HouraEncryptedPayload(
        algorithm: algorithm,
        senderKey: _requiredString(json, 'sender_key'),
        olmCiphertext: _requiredOlmCiphertextMap(json, 'ciphertext'),
        raw: Map<String, Object?>.unmodifiable(json),
      );
    }
    throw HouraResponseFormatException(
      'Unsupported encrypted payload algorithm "$algorithm".',
    );
  }

  Map<String, Object?> toJson() {
    if (algorithm == 'm.megolm.v1.aes-sha2') {
      return {
        ...raw,
        'algorithm': algorithm,
        'sender_key': _requiredToJsonString(senderKey, 'sender_key'),
        'ciphertext': _requiredToJsonString(megolmCiphertext, 'ciphertext'),
        'session_id': _requiredToJsonString(sessionId, 'session_id'),
        'device_id': _requiredToJsonString(deviceId, 'device_id'),
      };
    }
    if (algorithm == 'm.olm.v1.curve25519-aes-sha2') {
      final ciphertext = olmCiphertext;
      if (ciphertext == null || ciphertext.isEmpty) {
        throw HouraResponseFormatException(
          'Expected non-empty encrypted payload "ciphertext".',
        );
      }
      return {
        ...raw,
        'algorithm': algorithm,
        'sender_key': _requiredToJsonString(senderKey, 'sender_key'),
        'ciphertext': ciphertext.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      };
    }
    throw HouraResponseFormatException(
      'Unsupported encrypted payload algorithm "$algorithm".',
    );
  }
}

/// One recipient-key-indexed Olm ciphertext object.
final class HouraOlmCiphertext {
  const HouraOlmCiphertext({
    required this.type,
    required this.body,
    required this.raw,
  });

  final int type;
  final String body;
  final Map<String, Object?> raw;

  factory HouraOlmCiphertext.fromJson(Map<String, Object?> json) {
    final type = _requiredInt(json, 'type');
    if (type < 0) {
      throw HouraResponseFormatException('Expected non-negative "type".');
    }
    return HouraOlmCiphertext(
      type: type,
      body: _requiredString(json, 'body'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {...raw, 'type': type, 'body': body};
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

/// SPEC-095 parser-only Matrix media repository request descriptor.
final class HouraMatrixMediaRequestDescriptor {
  const HouraMatrixMediaRequestDescriptor({
    required this.id,
    required this.method,
    required this.path,
    required this.pathParams,
    required this.queryParams,
    required this.requiresAuth,
    required this.responseParser,
    required this.adoptedRuntimeBehavior,
  });

  final String id;
  final String method;
  final String path;
  final Map<String, Object?> pathParams;
  final Map<String, Object?> queryParams;
  final bool requiresAuth;
  final String responseParser;
  final bool adoptedRuntimeBehavior;

  factory HouraMatrixMediaRequestDescriptor.fromJson(
    Map<String, Object?> json,
  ) {
    final descriptor = HouraMatrixMediaRequestDescriptor(
      id: _requiredString(json, 'id'),
      method: _requiredString(json, 'method'),
      path: _requiredString(json, 'path'),
      pathParams: _optionalJsonObject(json, 'path_params') ?? const {},
      queryParams: _requiredJsonObject(json, 'query_params'),
      requiresAuth: _requiredBool(json, 'requires_auth'),
      responseParser: _requiredString(json, 'response_parser'),
      adoptedRuntimeBehavior: _requiredBool(json, 'adopted_runtime_behavior'),
    );
    _validateMatrixMediaDescriptor(descriptor);
    return descriptor;
  }
}

/// SPEC-095 Matrix media config metadata.
final class HouraMatrixMediaConfig {
  const HouraMatrixMediaConfig({this.uploadSize});

  final int? uploadSize;

  factory HouraMatrixMediaConfig.fromJson(Map<String, Object?> json) {
    final uploadSize = json['m.upload.size'];
    if (uploadSize != null && (uploadSize is! int || uploadSize < 0)) {
      throw HouraResponseFormatException(
        'Expected non-negative integer "m.upload.size".',
      );
    }
    return HouraMatrixMediaConfig(uploadSize: uploadSize as int?);
  }
}

/// SPEC-095 URL preview metadata parser boundary.
final class HouraMatrixMediaPreviewMetadata {
  const HouraMatrixMediaPreviewMetadata({required this.fields});

  final Map<String, Object?> fields;

  String? get imageUri => fields['og:image'] as String?;

  factory HouraMatrixMediaPreviewMetadata.fromJson(Map<String, Object?> json) {
    final imageUri = json['og:image'];
    if (imageUri != null) {
      _parseMatrixMediaContentUri(imageUri);
    }
    for (final key in const [
      'matrix:image:size',
      'og:image:width',
      'og:image:height',
    ]) {
      final value = json[key];
      if (value != null && (value is! int || value < 0)) {
        throw HouraResponseFormatException(
          'Expected non-negative integer "$key".',
        );
      }
    }
    return HouraMatrixMediaPreviewMetadata(
      fields: Map<String, Object?>.unmodifiable(json),
    );
  }
}

/// SPEC-095 thumbnail metadata parser boundary.
final class HouraMatrixMediaThumbnailMetadata {
  const HouraMatrixMediaThumbnailMetadata({
    required this.contentUri,
    required this.contentType,
    required this.width,
    required this.height,
    required this.method,
    this.animated,
  });

  final String contentUri;
  final String contentType;
  final int width;
  final int height;
  final String method;
  final bool? animated;

  factory HouraMatrixMediaThumbnailMetadata.fromJson(
    Map<String, Object?> json,
  ) {
    final method = _requiredString(json, 'method');
    if (method != 'scale' && method != 'crop') {
      throw HouraResponseFormatException(
        'Expected supported thumbnail method.',
      );
    }
    final contentUri = _requiredString(json, 'content_uri');
    _parseMatrixMediaContentUri(contentUri);
    return HouraMatrixMediaThumbnailMetadata(
      contentUri: contentUri,
      contentType: _requiredString(json, 'content_type'),
      width: _requiredNonNegativeInt(json, 'width'),
      height: _requiredNonNegativeInt(json, 'height'),
      method: method,
      animated: _optionalBool(json, 'animated'),
    );
  }
}

/// SPEC-095 async upload metadata parser boundary.
final class HouraMatrixMediaAsyncUploadMetadata {
  const HouraMatrixMediaAsyncUploadMetadata({
    required this.contentUri,
    this.unusedExpiresAt,
  });

  final String contentUri;
  final int? unusedExpiresAt;

  factory HouraMatrixMediaAsyncUploadMetadata.fromJson(
    Map<String, Object?> json,
  ) {
    final contentUri = _requiredString(json, 'content_uri');
    _parseMatrixMediaContentUri(contentUri);
    final unusedExpiresAt = json['unused_expires_at'];
    if (unusedExpiresAt != null &&
        (unusedExpiresAt is! int || unusedExpiresAt < 0)) {
      throw HouraResponseFormatException(
        'Expected non-negative integer "unused_expires_at".',
      );
    }
    return HouraMatrixMediaAsyncUploadMetadata(
      contentUri: contentUri,
      unusedExpiresAt: unusedExpiresAt as int?,
    );
  }
}

/// SPEC-095 safe Content-Disposition filename result.
final class HouraMatrixMediaContentDisposition {
  const HouraMatrixMediaContentDisposition({
    required this.disposition,
    required this.filename,
  });

  final String disposition;
  final String filename;

  factory HouraMatrixMediaContentDisposition.parse(String value) {
    final parts = value.split(';').map((part) => part.trim()).toList();
    if (parts.length != 2 ||
        (parts.first != 'inline' && parts.first != 'attachment')) {
      throw HouraResponseFormatException(
        'Expected supported Content-Disposition.',
      );
    }
    const prefix = 'filename="';
    final filenamePart = parts[1];
    if (!filenamePart.startsWith(prefix) || !filenamePart.endsWith('"')) {
      throw HouraResponseFormatException('Expected quoted filename.');
    }
    final rawFilename = filenamePart.substring(
      prefix.length,
      filenamePart.length - 1,
    );
    if (rawFilename.contains('%')) {
      throw HouraResponseFormatException('Expected safe media filename.');
    }
    final filename = _decodeMediaFilename(rawFilename);
    _validateSafeMediaFilename(filename);
    return HouraMatrixMediaContentDisposition(
      disposition: parts.first,
      filename: filename,
    );
  }
}

/// SPEC-098 parser-only Push Gateway pusher descriptor.
final class HouraMatrixPushPusherDescriptor {
  const HouraMatrixPushPusherDescriptor({
    required this.kind,
    required this.appId,
    required this.appDisplayName,
    required this.deviceDisplayName,
    required this.lang,
    required this.url,
    required this.replacementPolicy,
    this.profileTag,
    this.format,
  });

  final String kind;
  final String appId;
  final String appDisplayName;
  final String deviceDisplayName;
  final String lang;
  final Uri url;
  final String replacementPolicy;
  final String? profileTag;
  final String? format;

  factory HouraMatrixPushPusherDescriptor.fromJson(
    Map<String, Object?> json,
  ) {
    final kind = _requiredString(json, 'kind');
    if (kind != 'http_pusher') {
      throw HouraResponseFormatException('Expected HTTP pusher descriptor.');
    }
    final url = _parseMatrixPushNotifyUrl(_requiredString(json, 'url'));
    return HouraMatrixPushPusherDescriptor(
      kind: kind,
      appId: _requiredString(json, 'app_id'),
      appDisplayName: _requiredString(json, 'app_display_name'),
      deviceDisplayName: _requiredString(json, 'device_display_name'),
      lang: _requiredString(json, 'lang'),
      profileTag: _optionalString(json, 'profile_tag'),
      format: _optionalString(json, 'format'),
      url: url,
      replacementPolicy: _requiredString(json, 'replacement_policy'),
    );
  }
}

/// SPEC-098 parser-only Push Gateway push-rule descriptor.
final class HouraMatrixPushRuleDescriptor {
  const HouraMatrixPushRuleDescriptor({
    required this.kind,
    required this.ruleId,
    required this.enabled,
    required this.conditions,
    required this.actions,
    required this.tweaks,
  });

  final String kind;
  final String ruleId;
  final bool enabled;
  final List<Map<String, Object?>> conditions;
  final List<Object?> actions;
  final Map<String, Object?> tweaks;

  factory HouraMatrixPushRuleDescriptor.fromJson(
    Map<String, Object?> json,
  ) {
    final kind = _requiredString(json, 'kind');
    if (!const {'override', 'content', 'room', 'sender', 'underride'}
        .contains(kind)) {
      throw HouraResponseFormatException('Unsupported Matrix push rule kind.');
    }
    final ruleId = _requiredString(json, 'rule_id');
    _validateMatrixPushRuleId(ruleId);
    final actions = _requiredArray(json, 'actions');
    for (final action in actions) {
      if (action is String) {
        if (action.isEmpty) {
          throw HouraResponseFormatException(
            'Expected Matrix push rule action.',
          );
        }
      } else if (action is Map) {
        final actionMap = action.cast<String, Object?>();
        final setTweak = _requiredString(actionMap, 'set_tweak');
        if (setTweak.isEmpty) {
          throw HouraResponseFormatException(
            'Expected Matrix push rule tweak.',
          );
        }
      } else {
        throw HouraResponseFormatException(
          'Expected Matrix push rule action.',
        );
      }
    }
    return HouraMatrixPushRuleDescriptor(
      kind: kind,
      ruleId: ruleId,
      enabled: _requiredBool(json, 'enabled'),
      conditions: _requiredObjectList(json, 'conditions'),
      actions: List<Object?>.unmodifiable(actions),
      tweaks: _optionalJsonObject(json, 'tweaks') ?? const {},
    );
  }
}

/// SPEC-098 parser-only Push Gateway evidence case.
final class HouraMatrixPushParserEvidenceCase {
  const HouraMatrixPushParserEvidenceCase({
    required this.id,
    required this.kind,
    required this.inputSurface,
    required this.status,
    required this.normalizedFields,
    required this.redactedFields,
    required this.result,
    this.errcode,
  });

  final String id;
  final String kind;
  final String inputSurface;
  final int status;
  final List<String> normalizedFields;
  final List<String> redactedFields;
  final String result;
  final String? errcode;

  factory HouraMatrixPushParserEvidenceCase.fromJson(
    Map<String, Object?> json,
  ) {
    final kind = _requiredString(json, 'kind');
    if (!const {
      'pusher_descriptor',
      'push_rule_descriptor',
      'sync_visibility_descriptor',
      'malformed_descriptor',
      'redaction_helper',
    }.contains(kind)) {
      throw HouraResponseFormatException(
        'Unsupported Matrix push parser evidence kind.',
      );
    }
    final result = _requiredString(json, 'result');
    if (result != 'accepted' && result != 'rejected') {
      throw HouraResponseFormatException(
        'Unsupported Matrix push parser evidence result.',
      );
    }
    return HouraMatrixPushParserEvidenceCase(
      id: _requiredString(json, 'id'),
      kind: kind,
      inputSurface: _requiredString(json, 'input_surface'),
      status: _requiredNonNegativeInt(json, 'status'),
      errcode: _optionalString(json, 'errcode'),
      normalizedFields: _requiredStringList(json, 'normalized_fields'),
      redactedFields: _requiredStringList(json, 'redacted_fields'),
      result: result,
    );
  }
}

/// SPEC-059 parser-only Identity Service request descriptor.
final class HouraMatrixIdentityRequestDescriptor {
  const HouraMatrixIdentityRequestDescriptor({
    required this.method,
    required this.path,
    required this.query,
    required this.body,
    required this.authorizationScheme,
  });

  final String method;
  final String path;
  final Map<String, Object?> query;
  final Map<String, Object?> body;
  final String? authorizationScheme;

  factory HouraMatrixIdentityRequestDescriptor.fromJson(
    Map<String, Object?> json,
  ) {
    final method = _requiredString(json, 'method');
    if (!const {'GET', 'POST'}.contains(method)) {
      throw HouraResponseFormatException(
        'Unsupported Matrix Identity Service method.',
      );
    }
    final path = _requiredString(json, 'path');
    _validateMatrixIdentityPath(path);
    final authorization = _optionalJsonObject(json, 'authorization');
    final scheme =
        authorization == null ? null : _requiredString(authorization, 'scheme');
    if (scheme != null && scheme != 'Bearer') {
      throw HouraResponseFormatException(
        'Expected Matrix Identity Service bearer auth.',
      );
    }
    return HouraMatrixIdentityRequestDescriptor(
      method: method,
      path: path,
      query: _optionalJsonObject(json, 'query') ?? const {},
      body: _optionalJsonObject(json, 'body') ?? const {},
      authorizationScheme: scheme,
    );
  }
}

/// SPEC-059 Identity Service hash details response.
final class HouraMatrixIdentityHashDetails {
  const HouraMatrixIdentityHashDetails({
    required this.algorithms,
    required this.lookupPepper,
  });

  final List<String> algorithms;
  final String lookupPepper;

  factory HouraMatrixIdentityHashDetails.fromJson(
    Map<String, Object?> json,
  ) {
    final algorithms = _requiredStringList(json, 'algorithms');
    if (!algorithms.contains('sha256')) {
      throw HouraResponseFormatException(
        'Expected Matrix Identity Service sha256 support.',
      );
    }
    return HouraMatrixIdentityHashDetails(
      algorithms: algorithms,
      lookupPepper: _requiredString(json, 'lookup_pepper'),
    );
  }
}

/// SPEC-059 Identity Service lookup response.
final class HouraMatrixIdentityLookupResponse {
  const HouraMatrixIdentityLookupResponse({required this.mappings});

  final Map<String, String> mappings;

  factory HouraMatrixIdentityLookupResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final mappings = _requiredStringMap(json, 'mappings');
    for (final mxid in mappings.values) {
      _validateMatrixIdentityMxid(mxid);
    }
    return HouraMatrixIdentityLookupResponse(mappings: mappings);
  }
}

/// SPEC-059 Identity Service validation session response.
final class HouraMatrixIdentityValidationSession {
  const HouraMatrixIdentityValidationSession({required this.sid});

  final String sid;

  factory HouraMatrixIdentityValidationSession.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixIdentityValidationSession(
      sid: _requiredString(json, 'sid'),
    );
  }
}

/// SPEC-059 Identity Service validated 3PID response.
final class HouraMatrixIdentityValidatedThreePid {
  const HouraMatrixIdentityValidatedThreePid({
    required this.address,
    required this.medium,
    required this.validatedAt,
  });

  final String address;
  final String medium;
  final int validatedAt;

  factory HouraMatrixIdentityValidatedThreePid.fromJson(
    Map<String, Object?> json,
  ) {
    final medium = _requiredString(json, 'medium');
    _validateMatrixIdentityMedium(medium);
    return HouraMatrixIdentityValidatedThreePid(
      address: _requiredString(json, 'address'),
      medium: medium,
      validatedAt: _requiredNonNegativeInt(json, 'validated_at'),
    );
  }
}

/// SPEC-059 signed 3PID association response.
final class HouraMatrixIdentityAssociation {
  const HouraMatrixIdentityAssociation({
    required this.address,
    required this.medium,
    required this.mxid,
    required this.notAfter,
    required this.notBefore,
    required this.signatures,
    required this.ts,
  });

  final String address;
  final String medium;
  final String mxid;
  final int notAfter;
  final int notBefore;
  final Map<String, Map<String, String>> signatures;
  final int ts;

  factory HouraMatrixIdentityAssociation.fromJson(
    Map<String, Object?> json,
  ) {
    final medium = _requiredString(json, 'medium');
    _validateMatrixIdentityMedium(medium);
    final mxid = _requiredString(json, 'mxid');
    _validateMatrixIdentityMxid(mxid);
    final notAfter = _requiredNonNegativeInt(json, 'not_after');
    final notBefore = _requiredNonNegativeInt(json, 'not_before');
    if (notAfter <= notBefore) {
      throw HouraResponseFormatException(
        'Expected Matrix Identity Service association validity window.',
      );
    }
    return HouraMatrixIdentityAssociation(
      address: _requiredString(json, 'address'),
      medium: medium,
      mxid: mxid,
      notAfter: notAfter,
      notBefore: notBefore,
      signatures: _requiredNestedStringMap(json, 'signatures'),
      ts: _requiredNonNegativeInt(json, 'ts'),
    );
  }
}

/// SPEC-059 Identity Service Matrix error envelope.
final class HouraMatrixIdentityErrorEnvelope {
  const HouraMatrixIdentityErrorEnvelope({
    required this.status,
    required this.errcode,
  });

  final int status;
  final String errcode;

  factory HouraMatrixIdentityErrorEnvelope.fromJson(
    Map<String, Object?> json,
  ) {
    final status = _requiredNonNegativeInt(json, 'status');
    if (status < 400) {
      throw HouraResponseFormatException(
        'Expected Matrix Identity Service error status.',
      );
    }
    final errcode = _requiredString(json, 'errcode');
    if (!errcode.startsWith('M_')) {
      throw HouraResponseFormatException(
        'Expected Matrix Identity Service errcode.',
      );
    }
    return HouraMatrixIdentityErrorEnvelope(
      status: status,
      errcode: errcode,
    );
  }
}

/// SPEC-076/092/094/096 Identity Service parser evidence case.
final class HouraMatrixIdentityEvidenceCase {
  const HouraMatrixIdentityEvidenceCase({
    required this.id,
    required this.kind,
    required this.request,
    required this.status,
    required this.redactedFields,
    required this.result,
    this.errcode,
    this.medium,
    this.authProof,
    this.keyState,
    this.signatureState,
    this.associationState,
    this.providerHandoff,
    this.sessionState,
  });

  final String id;
  final String kind;
  final HouraMatrixIdentityRequestDescriptor request;
  final int status;
  final List<String> redactedFields;
  final String result;
  final String? errcode;
  final String? medium;
  final String? authProof;
  final String? keyState;
  final String? signatureState;
  final String? associationState;
  final String? providerHandoff;
  final String? sessionState;

  factory HouraMatrixIdentityEvidenceCase.fromJson(
    Map<String, Object?> json,
  ) {
    final result = _requiredString(json, 'result');
    if (result != 'accepted' && result != 'rejected') {
      throw HouraResponseFormatException(
        'Unsupported Matrix Identity Service evidence result.',
      );
    }
    final medium = _optionalString(json, 'medium');
    if (medium != null) {
      _validateMatrixIdentityMedium(medium);
    }
    return HouraMatrixIdentityEvidenceCase(
      id: _requiredString(json, 'id'),
      kind: _requiredString(json, 'kind'),
      request: HouraMatrixIdentityRequestDescriptor.fromJson(
        _requiredJsonObject(json, 'request'),
      ),
      status: _requiredNonNegativeInt(json, 'status'),
      errcode: _optionalString(json, 'errcode'),
      medium: medium,
      authProof: _optionalString(json, 'auth_proof'),
      keyState: _optionalString(json, 'key_state'),
      signatureState: _optionalString(json, 'signature_state'),
      associationState: _optionalString(json, 'association_state'),
      providerHandoff: _optionalString(json, 'provider_handoff'),
      sessionState: _optionalString(json, 'session_state'),
      redactedFields: _requiredStringList(json, 'redacted_fields'),
      result: result,
    );
  }
}

/// SPEC-059/076 redaction helper for Identity Service evidence artifacts.
final class HouraMatrixIdentityEvidenceRedactor {
  static const redactionMarker = 'identity-redacted';

  const HouraMatrixIdentityEvidenceRedactor();

  Map<String, Object?> redact(Map<String, Object?> value) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries)
        entry.key: _redactIdentityEvidenceValue(entry.key, entry.value),
    });
  }
}

/// SPEC-098 redaction helper for push evidence artifacts.
final class HouraMatrixPushEvidenceRedactor {
  static const redactionMarker = 'push-redacted';

  const HouraMatrixPushEvidenceRedactor();

  Map<String, Object?> redact(Map<String, Object?> value) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries)
        entry.key: _redactPushEvidenceValue(entry.key, entry.value),
    });
  }
}

String _decodeMediaFilename(String value) {
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    throw HouraResponseFormatException('Expected decodable media filename.');
  }
}

Uri _parseMatrixPushNotifyUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.path != '/_matrix/push/v1/notify' ||
      uri.hasFragment ||
      uri.userInfo.isNotEmpty) {
    throw HouraResponseFormatException('Expected Matrix push notify URL.');
  }
  return uri;
}

void _validateMatrixPushRuleId(String value) {
  if (value.startsWith('.') || value.contains('/') || value.contains(r'\')) {
    throw HouraResponseFormatException('Expected Matrix push rule ID.');
  }
}

void _validateMatrixIdentityPath(String value) {
  if (!value.startsWith('/_matrix/identity/')) {
    throw HouraResponseFormatException(
      'Expected Matrix Identity Service path.',
    );
  }
  if (value.contains('..') || value.contains('//')) {
    throw HouraResponseFormatException(
      'Expected safe Matrix Identity Service path.',
    );
  }
}

void _validateMatrixIdentityMedium(String value) {
  if (value != 'email' && value != 'msisdn') {
    throw HouraResponseFormatException(
      'Expected Matrix Identity Service 3PID medium.',
    );
  }
}

void _validateMatrixIdentityMxid(String value) {
  if (!value.startsWith('@') || !value.contains(':') || value.contains(' ')) {
    throw HouraResponseFormatException(
      'Expected Matrix Identity Service MXID.',
    );
  }
}

Object? _redactIdentityEvidenceValue(String key, Object? value) {
  const sensitiveKeys = {
    'identity_token',
    'access_token',
    'token',
    'validation_token',
    'client_secret',
    'lookup_pepper',
    'pepper',
    'hashed_3pid',
    'full_3pid',
    'threepid',
    'address',
    'email',
    'msisdn',
    'signature',
    'signatures',
    'public_key',
    'private_key',
    'ephemeral_key',
    'provider_payload',
    'provider_log',
    'local_template_path',
  };
  if (sensitiveKeys.contains(key)) {
    return HouraMatrixIdentityEvidenceRedactor.redactionMarker;
  }
  if (value is Map) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries)
        entry.key.toString(): _redactIdentityEvidenceValue(
          entry.key.toString(),
          entry.value,
        ),
    });
  }
  if (value is List) {
    return List<Object?>.unmodifiable(
      value.map((item) => _redactIdentityEvidenceValue(key, item)),
    );
  }
  return value;
}

Object? _redactPushEvidenceValue(String key, Object? value) {
  const sensitiveKeys = {
    'pushkey',
    'gateway_url',
    'vendor_token',
    'gateway_credentials',
    'message_content',
    'local_path',
    'provider_response',
    'body',
    'formatted_body',
    'room_name',
    'room_alias',
    'sender_display_name',
  };
  if (sensitiveKeys.contains(key)) {
    return HouraMatrixPushEvidenceRedactor.redactionMarker;
  }
  if (value is Map) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries)
        entry.key.toString(): _redactPushEvidenceValue(
          entry.key.toString(),
          entry.value,
        ),
    });
  }
  if (value is List) {
    return List<Object?>.unmodifiable(
      value.map((item) => _redactPushEvidenceValue(key, item)),
    );
  }
  return value;
}

/// SPEC-097 parser-only Matrix federation request descriptor.
final class HouraMatrixFederationRequestDescriptor {
  const HouraMatrixFederationRequestDescriptor({
    required this.id,
    required this.method,
    required this.path,
    required this.pathParams,
    required this.queryParams,
    required this.requiresAuth,
    required this.responseParser,
    required this.adoptedRuntimeBehavior,
  });

  final String id;
  final String method;
  final String path;
  final Map<String, Object?> pathParams;
  final Map<String, Object?> queryParams;
  final bool requiresAuth;
  final String responseParser;
  final bool adoptedRuntimeBehavior;

  factory HouraMatrixFederationRequestDescriptor.fromJson(
    Map<String, Object?> json,
  ) {
    final descriptor = HouraMatrixFederationRequestDescriptor(
      id: _requiredString(json, 'id'),
      method: _requiredString(json, 'method'),
      path: _requiredString(json, 'path'),
      pathParams: _optionalJsonObject(json, 'path_params') ?? const {},
      queryParams: _optionalJsonObject(json, 'query_params') ?? const {},
      requiresAuth: _requiredBool(json, 'requires_auth'),
      responseParser: _requiredString(json, 'response_parser'),
      adoptedRuntimeBehavior: _requiredBool(json, 'adopted_runtime_behavior'),
    );
    _validateMatrixFederationDescriptor(descriptor);
    return descriptor;
  }
}

/// SPEC-097 federation version metadata.
final class HouraMatrixFederationVersion {
  const HouraMatrixFederationVersion({
    required this.serverName,
    required this.serverVersion,
  });

  final String serverName;
  final String serverVersion;

  factory HouraMatrixFederationVersion.fromJson(Map<String, Object?> json) {
    final server = _requiredJsonObject(json, 'server');
    return HouraMatrixFederationVersion(
      serverName: _requiredString(server, 'name'),
      serverVersion: _requiredString(server, 'version'),
    );
  }
}

/// SPEC-097 federation signing-key lifecycle metadata.
final class HouraMatrixFederationSigningKey {
  const HouraMatrixFederationSigningKey({
    required this.serverName,
    required this.verifyKeys,
    required this.oldVerifyKeys,
    required this.validUntilTs,
    required this.signatures,
  });

  final String serverName;
  final Map<String, String> verifyKeys;
  final Map<String, HouraMatrixFederationOldVerifyKey> oldVerifyKeys;
  final int validUntilTs;
  final Map<String, Map<String, String>> signatures;

  factory HouraMatrixFederationSigningKey.fromJson(Map<String, Object?> json) {
    final serverName = _requiredString(json, 'server_name');
    _validateMatrixFederationServerName(serverName);
    final verifyKeys = _requiredFederationVerifyKeys(json, 'verify_keys');
    if (verifyKeys.isEmpty) {
      throw HouraResponseFormatException('Expected federation verify keys.');
    }
    return HouraMatrixFederationSigningKey(
      serverName: serverName,
      verifyKeys: verifyKeys,
      oldVerifyKeys: _requiredFederationOldVerifyKeys(json, 'old_verify_keys'),
      validUntilTs: _requiredNonNegativeInt(json, 'valid_until_ts'),
      signatures: _requiredNestedStringMap(json, 'signatures'),
    );
  }
}

/// SPEC-097 federation old signing-key metadata.
final class HouraMatrixFederationOldVerifyKey {
  const HouraMatrixFederationOldVerifyKey({
    required this.expiredTs,
    required this.key,
  });

  final int expiredTs;
  final String key;
}

/// SPEC-097 federation key query response.
final class HouraMatrixFederationKeyQueryResponse {
  const HouraMatrixFederationKeyQueryResponse({required this.serverKeys});

  final List<HouraMatrixFederationSigningKey> serverKeys;

  factory HouraMatrixFederationKeyQueryResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final value = json['server_keys'];
    if (value is! List) {
      throw HouraResponseFormatException('Expected federation key array.');
    }
    return HouraMatrixFederationKeyQueryResponse(
      serverKeys: List.unmodifiable(
        value.map((item) {
          if (item is Map) {
            return HouraMatrixFederationSigningKey.fromJson(
              item.cast<String, Object?>(),
            );
          }
          throw HouraResponseFormatException(
            'Expected federation signing key object.',
          );
        }),
      ),
    );
  }
}

/// SPEC-097 parser-only federation request-auth header descriptor.
final class HouraMatrixFederationRequestAuthDescriptor {
  const HouraMatrixFederationRequestAuthDescriptor({
    required this.scheme,
    required this.origin,
    required this.destination,
    required this.key,
    required this.sig,
    required this.signedJsonFields,
  });

  final String scheme;
  final String origin;
  final String destination;
  final String key;
  final String sig;
  final List<String> signedJsonFields;

  factory HouraMatrixFederationRequestAuthDescriptor.fromJson(
    Map<String, Object?> json,
  ) {
    final scheme = _requiredString(json, 'scheme');
    if (scheme != 'X-Matrix') {
      throw HouraResponseFormatException('Expected X-Matrix auth scheme.');
    }
    final origin = _requiredString(json, 'origin');
    final destination = _requiredString(json, 'destination');
    _validateMatrixFederationServerName(origin);
    _validateMatrixFederationServerName(destination);
    final key = _requiredString(json, 'key');
    _validateMatrixFederationKeyId(key);
    final signedJsonFields = _requiredStringList(json, 'signed_json_fields');
    if (signedJsonFields.isEmpty) {
      throw HouraResponseFormatException(
        'Expected federation signed JSON fields.',
      );
    }
    return HouraMatrixFederationRequestAuthDescriptor(
      scheme: scheme,
      origin: origin,
      destination: destination,
      key: key,
      sig: _requiredString(json, 'sig'),
      signedJsonFields: signedJsonFields,
    );
  }
}

/// SPEC-057 parser-only federation request authorization metadata.
final class HouraMatrixFederationRequestAuthorization {
  const HouraMatrixFederationRequestAuthorization({
    required this.scheme,
    required this.origin,
    required this.destination,
    required this.key,
    required this.signedJson,
  });

  final String scheme;
  final String origin;
  final String destination;
  final String key;
  final bool signedJson;

  factory HouraMatrixFederationRequestAuthorization.fromJson(
    Map<String, Object?> json,
  ) {
    final scheme = _requiredString(json, 'scheme');
    if (scheme != 'X-Matrix') {
      throw HouraResponseFormatException('Expected X-Matrix auth scheme.');
    }
    final origin = _requiredString(json, 'origin');
    final destination = _requiredString(json, 'destination');
    _validateMatrixFederationServerName(origin);
    _validateMatrixFederationServerName(destination);
    final key = _requiredString(json, 'key');
    _validateMatrixFederationKeyId(key);
    final signedJson = _requiredBool(json, 'signed_json');
    if (!signedJson) {
      throw HouraResponseFormatException(
        'Expected signed federation authorization metadata.',
      );
    }
    return HouraMatrixFederationRequestAuthorization(
      scheme: scheme,
      origin: origin,
      destination: destination,
      key: key,
      signedJson: signedJson,
    );
  }
}

/// SPEC-057 parser-only Matrix federation backfill request shape.
final class HouraMatrixFederationBackfillRequest {
  const HouraMatrixFederationBackfillRequest({
    required this.method,
    required this.path,
    required this.fromEventIds,
    required this.limit,
    required this.authorization,
  });

  final String method;
  final String path;
  final List<String> fromEventIds;
  final int limit;
  final HouraMatrixFederationRequestAuthorization authorization;

  factory HouraMatrixFederationBackfillRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final method = _requiredString(json, 'method');
    if (method != 'GET') {
      throw HouraResponseFormatException(
        'Unsupported Matrix federation backfill method.',
      );
    }
    final path = _requiredString(json, 'path');
    if (!path.startsWith('/_matrix/federation/v1/backfill/')) {
      throw HouraResponseFormatException(
        'Unsupported Matrix federation backfill path.',
      );
    }
    final query = _requiredJsonObject(json, 'query');
    final fromEventIds = _requiredStringList(query, 'v');
    final limit = _requiredNonNegativeInt(query, 'limit');
    if (fromEventIds.isEmpty || limit <= 0) {
      throw HouraResponseFormatException(
        'Expected Matrix federation backfill query parameters.',
      );
    }
    return HouraMatrixFederationBackfillRequest(
      method: method,
      path: path,
      fromEventIds: fromEventIds,
      limit: limit,
      authorization: HouraMatrixFederationRequestAuthorization.fromJson(
        _requiredJsonObject(json, 'authorization'),
      ),
    );
  }
}

/// SPEC-057 / SPEC-099 parser-only Matrix federation PDU envelope.
final class HouraMatrixFederationPdu {
  const HouraMatrixFederationPdu({
    required this.eventId,
    required this.type,
    required this.roomId,
    required this.sender,
    required this.originServerTs,
    required this.depth,
    required this.prevEvents,
    required this.authEvents,
    required this.content,
    required this.hashes,
    required this.signatures,
    required this.raw,
    this.stateKey,
    this.unsigned,
  });

  final String eventId;
  final String type;
  final String roomId;
  final String sender;
  final int originServerTs;
  final int depth;
  final List<String> prevEvents;
  final List<String> authEvents;
  final Map<String, Object?> content;
  final Map<String, String> hashes;
  final Map<String, Map<String, String>> signatures;
  final String? stateKey;
  final Map<String, Object?>? unsigned;
  final Map<String, Object?> raw;

  factory HouraMatrixFederationPdu.fromJson(Map<String, Object?> json) {
    return HouraMatrixFederationPdu(
      eventId: _requiredString(json, 'event_id'),
      type: _requiredString(json, 'type'),
      roomId: _requiredString(json, 'room_id'),
      sender: _requiredString(json, 'sender'),
      originServerTs: _requiredNonNegativeInt(json, 'origin_server_ts'),
      depth: _requiredNonNegativeInt(json, 'depth'),
      prevEvents: _requiredStringList(json, 'prev_events'),
      authEvents: _requiredStringList(json, 'auth_events'),
      content: _requiredJsonObject(json, 'content'),
      hashes: _requiredStringMap(json, 'hashes'),
      signatures: _requiredFederationSignatures(json, 'signatures'),
      stateKey: _optionalString(json, 'state_key'),
      unsigned: _optionalJsonObject(json, 'unsigned'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }
}

/// SPEC-099 parser-only Matrix federation EDU envelope.
final class HouraMatrixFederationEdu {
  const HouraMatrixFederationEdu({
    required this.eduType,
    required this.content,
  });

  final String eduType;
  final Map<String, Object?> content;

  factory HouraMatrixFederationEdu.fromJson(Map<String, Object?> json) {
    return HouraMatrixFederationEdu(
      eduType: _requiredString(json, 'edu_type'),
      content: _requiredJsonObject(json, 'content'),
    );
  }
}

/// SPEC-099 parser-only Matrix federation transaction envelope.
final class HouraMatrixFederationTransaction {
  const HouraMatrixFederationTransaction({
    required this.origin,
    required this.originServerTs,
    required this.pdus,
    required this.edus,
  });

  final String origin;
  final int originServerTs;
  final List<HouraMatrixFederationPdu> pdus;
  final List<HouraMatrixFederationEdu> edus;

  factory HouraMatrixFederationTransaction.fromJson(Map<String, Object?> json) {
    final origin = _requiredString(json, 'origin');
    _validateMatrixFederationServerName(origin);
    final pdus = _requiredFederationPdus(json, 'pdus', maxItems: 50);
    final edus = _requiredFederationEdus(json, 'edus', maxItems: 100);
    return HouraMatrixFederationTransaction(
      origin: origin,
      originServerTs: _requiredNonNegativeInt(json, 'origin_server_ts'),
      pdus: pdus,
      edus: edus,
    );
  }
}

/// SPEC-099 canonical JSON input descriptor for event hash/signature surfaces.
final class HouraMatrixFederationCanonicalJsonInputDescriptor {
  const HouraMatrixFederationCanonicalJsonInputDescriptor({
    required this.eventId,
    required this.inputFields,
    required this.privateKeyPresent,
    required this.hashCalculated,
    required this.signatureVerified,
  });

  final String eventId;
  final List<String> inputFields;
  final bool privateKeyPresent;
  final bool hashCalculated;
  final bool signatureVerified;

  factory HouraMatrixFederationCanonicalJsonInputDescriptor.fromJson(
    Map<String, Object?> json,
  ) {
    final inputFields = _requiredBoundedStringList(
      json,
      'input_fields',
      maxItems: 32,
    );
    if (inputFields.isEmpty) {
      throw HouraResponseFormatException(
        'Expected bounded canonical JSON input fields.',
      );
    }
    final descriptor = HouraMatrixFederationCanonicalJsonInputDescriptor(
      eventId: _requiredString(json, 'event_id'),
      inputFields: List.unmodifiable(inputFields),
      privateKeyPresent: _requiredBool(json, 'private_key_present'),
      hashCalculated: _requiredBool(json, 'hash_calculated'),
      signatureVerified: _requiredBool(json, 'signature_verified'),
    );
    if (descriptor.privateKeyPresent ||
        descriptor.hashCalculated ||
        descriptor.signatureVerified) {
      throw HouraResponseFormatException(
        'Expected parser-only canonical JSON descriptor.',
      );
    }
    return descriptor;
  }
}

/// SPEC-099 parser-only Matrix federation transaction response result.
final class HouraMatrixFederationPduResult {
  const HouraMatrixFederationPduResult({this.error});

  final String? error;

  factory HouraMatrixFederationPduResult.fromJson(Map<String, Object?> json) {
    return HouraMatrixFederationPduResult(
      error: _optionalString(json, 'error'),
    );
  }
}

/// SPEC-099 parser-only Matrix federation transaction response.
final class HouraMatrixFederationTransactionResponse {
  const HouraMatrixFederationTransactionResponse({required this.pdus});

  final Map<String, HouraMatrixFederationPduResult> pdus;

  factory HouraMatrixFederationTransactionResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final value = json['pdus'];
    if (value is! Map) {
      throw HouraResponseFormatException(
        'Expected Matrix federation transaction response PDUs.',
      );
    }
    return HouraMatrixFederationTransactionResponse(
      pdus: Map<String, HouraMatrixFederationPduResult>.unmodifiable(
        value.cast<String, Object?>().map((eventId, result) {
          if (eventId.isEmpty || result is! Map) {
            throw HouraResponseFormatException(
              'Expected Matrix federation PDU result.',
            );
          }
          return MapEntry(
            eventId,
            HouraMatrixFederationPduResult.fromJson(
              result.cast<String, Object?>(),
            ),
          );
        }),
      ),
    );
  }
}

/// SPEC-057 parser-only Matrix federation backfill response.
final class HouraMatrixFederationBackfillResponse {
  const HouraMatrixFederationBackfillResponse({
    required this.origin,
    required this.originServerTs,
    required this.pdus,
  });

  final String origin;
  final int originServerTs;
  final List<HouraMatrixFederationPdu> pdus;

  factory HouraMatrixFederationBackfillResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final origin = _requiredString(json, 'origin');
    _validateMatrixFederationServerName(origin);
    final value = json['pdus'];
    if (value is! List) {
      throw HouraResponseFormatException(
        'Expected Matrix federation PDU array.',
      );
    }
    return HouraMatrixFederationBackfillResponse(
      origin: origin,
      originServerTs: _requiredNonNegativeInt(json, 'origin_server_ts'),
      pdus: List.unmodifiable(
        value.map((item) {
          if (item is Map) {
            return HouraMatrixFederationPdu.fromJson(
              item.cast<String, Object?>(),
            );
          }
          throw HouraResponseFormatException(
            'Expected Matrix federation PDU object.',
          );
        }),
      ),
    );
  }
}

/// SPEC-100 parser-only Matrix federation room summary.
final class HouraMatrixFederationRoomSummary {
  const HouraMatrixFederationRoomSummary({
    required this.roomId,
    required this.numJoinedMembers,
    required this.worldReadable,
    required this.guestCanJoin,
    this.name,
    this.topic,
    this.canonicalAlias,
    this.joinRule,
    this.roomType,
    this.childrenState = const [],
  });

  final String roomId;
  final int numJoinedMembers;
  final bool worldReadable;
  final bool guestCanJoin;
  final String? name;
  final String? topic;
  final String? canonicalAlias;
  final String? joinRule;
  final String? roomType;
  final List<HouraMatrixFederationChildStateEvent> childrenState;

  factory HouraMatrixFederationRoomSummary.fromJson(Map<String, Object?> json) {
    final childrenState = _optionalFederationChildState(
      json,
      'children_state',
      maxItems: 20,
    );
    return HouraMatrixFederationRoomSummary(
      roomId: _requiredString(json, 'room_id'),
      numJoinedMembers: _requiredNonNegativeInt(json, 'num_joined_members'),
      worldReadable: _requiredBool(json, 'world_readable'),
      guestCanJoin: _requiredBool(json, 'guest_can_join'),
      name: _optionalString(json, 'name'),
      topic: _optionalString(json, 'topic'),
      canonicalAlias: _optionalString(json, 'canonical_alias'),
      joinRule: _optionalString(json, 'join_rule'),
      roomType: _optionalString(json, 'room_type'),
      childrenState: childrenState,
    );
  }
}

/// SPEC-100 parser-only Matrix federation child state event summary.
final class HouraMatrixFederationChildStateEvent {
  const HouraMatrixFederationChildStateEvent({
    required this.type,
    required this.stateKey,
    required this.content,
  });

  final String type;
  final String stateKey;
  final Map<String, Object?> content;

  factory HouraMatrixFederationChildStateEvent.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixFederationChildStateEvent(
      type: _requiredString(json, 'type'),
      stateKey: _requiredString(json, 'state_key'),
      content: _requiredJsonObject(json, 'content'),
    );
  }
}

/// SPEC-100 parser-only Matrix federation public rooms response.
final class HouraMatrixFederationPublicRoomsResponse {
  const HouraMatrixFederationPublicRoomsResponse({
    required this.chunk,
    this.nextBatch,
    this.prevBatch,
    this.totalRoomCountEstimate,
  });

  final List<HouraMatrixFederationRoomSummary> chunk;
  final String? nextBatch;
  final String? prevBatch;
  final int? totalRoomCountEstimate;

  factory HouraMatrixFederationPublicRoomsResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final chunk = _requiredFederationRoomSummaries(
      json,
      'chunk',
      maxItems: 50,
    );
    return HouraMatrixFederationPublicRoomsResponse(
      chunk: chunk,
      nextBatch: _optionalString(json, 'next_batch'),
      prevBatch: _optionalString(json, 'prev_batch'),
      totalRoomCountEstimate: _optionalNonNegativeInt(
        json,
        'total_room_count_estimate',
      ),
    );
  }
}

/// SPEC-100 parser-only Matrix federation hierarchy response.
final class HouraMatrixFederationHierarchyResponse {
  const HouraMatrixFederationHierarchyResponse({
    required this.rooms,
    required this.inaccessibleChildren,
    this.nextBatch,
  });

  final List<HouraMatrixFederationRoomSummary> rooms;
  final List<String> inaccessibleChildren;
  final String? nextBatch;

  factory HouraMatrixFederationHierarchyResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final rooms = _requiredFederationRoomSummaries(
      json,
      'rooms',
      maxItems: 50,
    );
    final inaccessibleChildren = _requiredBoundedStringList(
      json,
      'inaccessible_children',
      maxItems: 50,
    );
    return HouraMatrixFederationHierarchyResponse(
      rooms: rooms,
      inaccessibleChildren: List.unmodifiable(inaccessibleChildren),
      nextBatch: _optionalString(json, 'next_batch'),
    );
  }
}

/// SPEC-100 parser-only Matrix federation directory query response.
final class HouraMatrixFederationDirectoryQueryResponse {
  const HouraMatrixFederationDirectoryQueryResponse({
    required this.roomId,
    required this.servers,
  });

  final String roomId;
  final List<String> servers;

  factory HouraMatrixFederationDirectoryQueryResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final servers = _requiredBoundedStringList(
      json,
      'servers',
      maxItems: 20,
    );
    if (servers.isEmpty) {
      throw HouraResponseFormatException(
        'Expected bounded Matrix federation server list.',
      );
    }
    for (final server in servers) {
      _validateMatrixFederationServerName(server);
    }
    return HouraMatrixFederationDirectoryQueryResponse(
      roomId: _requiredString(json, 'room_id'),
      servers: List.unmodifiable(servers),
    );
  }
}

/// SPEC-100 parser-only Matrix federation profile query response.
final class HouraMatrixFederationProfileQueryResponse {
  const HouraMatrixFederationProfileQueryResponse({
    this.displayName,
    this.avatarUrl,
  });

  final String? displayName;
  final String? avatarUrl;

  factory HouraMatrixFederationProfileQueryResponse.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixFederationProfileQueryResponse(
      displayName: _optionalString(json, 'displayname'),
      avatarUrl: _optionalString(json, 'avatar_url'),
    );
  }
}

/// SPEC-100 parser-only Matrix federation generic query response descriptor.
final class HouraMatrixFederationGenericQueryResponse {
  const HouraMatrixFederationGenericQueryResponse({
    required this.queryType,
    required this.responseObjectPresent,
  });

  final String queryType;
  final bool responseObjectPresent;

  factory HouraMatrixFederationGenericQueryResponse.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixFederationGenericQueryResponse(
      queryType: _requiredString(json, 'query_type'),
      responseObjectPresent: _requiredBool(json, 'response_object_present'),
    );
  }
}

/// SPEC-100 parser-only Matrix federation OpenID userinfo response.
final class HouraMatrixFederationOpenIdUserinfoResponse {
  const HouraMatrixFederationOpenIdUserinfoResponse({required this.subject});

  final String subject;

  factory HouraMatrixFederationOpenIdUserinfoResponse.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixFederationOpenIdUserinfoResponse(
      subject: _requiredString(json, 'sub'),
    );
  }
}

/// SPEC-057 parser-only Matrix federation event auth response.
final class HouraMatrixFederationEventAuthResponse {
  const HouraMatrixFederationEventAuthResponse({required this.authChain});

  final List<HouraMatrixFederationPdu> authChain;

  factory HouraMatrixFederationEventAuthResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final value = json['auth_chain'];
    if (value is! List) {
      throw HouraResponseFormatException(
        'Expected Matrix federation auth chain array.',
      );
    }
    return HouraMatrixFederationEventAuthResponse(
      authChain: List.unmodifiable(
        value.map((item) {
          if (item is Map) {
            return HouraMatrixFederationPdu.fromJson(
              item.cast<String, Object?>(),
            );
          }
          throw HouraResponseFormatException(
            'Expected Matrix federation auth chain PDU object.',
          );
        }),
      ),
    );
  }
}

/// SPEC-057 parser-only Matrix federation state_ids response.
final class HouraMatrixFederationStateIdsResponse {
  const HouraMatrixFederationStateIdsResponse({
    required this.pduIds,
    required this.authChainIds,
  });

  final List<String> pduIds;
  final List<String> authChainIds;

  factory HouraMatrixFederationStateIdsResponse.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixFederationStateIdsResponse(
      pduIds: _requiredStringList(json, 'pdu_ids'),
      authChainIds: _requiredStringList(json, 'auth_chain_ids'),
    );
  }
}

/// SPEC-057 parser-only Matrix federation state-resolution interop step.
final class HouraMatrixFederationStateResolutionInteropStep {
  const HouraMatrixFederationStateResolutionInteropStep({
    required this.id,
    required this.contract,
    required this.required,
    this.endpoint,
    this.allowedResults,
  });

  final String id;
  final String contract;
  final bool required;
  final String? endpoint;
  final List<String>? allowedResults;

  factory HouraMatrixFederationStateResolutionInteropStep.fromJson(
    Map<String, Object?> json,
  ) {
    final allowedResults = json['allowed_results'];
    List<String>? parsedAllowedResults;
    if (allowedResults != null) {
      parsedAllowedResults = _requiredStringList(json, 'allowed_results');
      if (parsedAllowedResults.isEmpty ||
          parsedAllowedResults.any(
            (value) =>
                value != 'accepted' &&
                value != 'soft_failed' &&
                value != 'rejected',
          )) {
        throw HouraResponseFormatException(
          'Expected supported interop decision result values.',
        );
      }
    }
    return HouraMatrixFederationStateResolutionInteropStep(
      id: _requiredString(json, 'id'),
      contract: _requiredString(json, 'contract'),
      required: _requiredBool(json, 'required'),
      endpoint: _optionalString(json, 'endpoint'),
      allowedResults: parsedAllowedResults == null
          ? null
          : List.unmodifiable(parsedAllowedResults),
    );
  }
}

/// SPEC-057 parser-only Matrix federation state-resolution interop record.
final class HouraMatrixFederationStateResolutionInteropRecord {
  const HouraMatrixFederationStateResolutionInteropRecord({
    required this.matrixSpecVersion,
    required this.matrixSpecSource,
    required this.checkedAt,
    required this.requiredContracts,
    required this.localServer,
    required this.remoteServer,
    required this.roomId,
    required this.roomVersion,
    required this.targetEventId,
    required this.steps,
    required this.requiredEvidence,
  });

  final String matrixSpecVersion;
  final String matrixSpecSource;
  final String checkedAt;
  final List<String> requiredContracts;
  final String localServer;
  final String remoteServer;
  final String roomId;
  final String roomVersion;
  final String targetEventId;
  final List<HouraMatrixFederationStateResolutionInteropStep> steps;
  final List<String> requiredEvidence;

  factory HouraMatrixFederationStateResolutionInteropRecord.fromJson(
    Map<String, Object?> json,
  ) {
    final requiredContracts = _requiredStringList(json, 'required_contracts');
    final requiredEvidence = _requiredStringList(json, 'required_evidence');
    if (requiredContracts.isEmpty || requiredEvidence.isEmpty) {
      throw HouraResponseFormatException(
        'Expected non-empty state-resolution interop metadata.',
      );
    }
    final stepsValue = json['steps'];
    if (stepsValue is! List || stepsValue.isEmpty) {
      throw HouraResponseFormatException(
        'Expected state-resolution interop step array.',
      );
    }
    final localServer = _requiredString(json, 'local_server');
    final remoteServer = _requiredString(json, 'remote_server');
    _validateMatrixFederationServerName(localServer);
    _validateMatrixFederationServerName(remoteServer);
    return HouraMatrixFederationStateResolutionInteropRecord(
      matrixSpecVersion: _requiredString(json, 'matrix_spec_version'),
      matrixSpecSource: _requiredString(json, 'matrix_spec_source'),
      checkedAt: _requiredString(json, 'checked_at'),
      requiredContracts: requiredContracts,
      localServer: localServer,
      remoteServer: remoteServer,
      roomId: _requiredString(json, 'room_id'),
      roomVersion: _requiredString(json, 'room_version'),
      targetEventId: _requiredString(json, 'target_event_id'),
      steps: List.unmodifiable(
        stepsValue.map((item) {
          if (item is Map) {
            return HouraMatrixFederationStateResolutionInteropStep.fromJson(
              item.cast<String, Object?>(),
            );
          }
          throw HouraResponseFormatException(
            'Expected state-resolution interop step object.',
          );
        }),
      ),
      requiredEvidence: requiredEvidence,
    );
  }
}

/// SPEC-069 Matrix device key query response.
final class HouraDeviceKeyQueryResponse {
  const HouraDeviceKeyQueryResponse({
    required this.failures,
    required this.deviceKeys,
    this.masterKeys = const {},
    this.selfSigningKeys = const {},
    this.userSigningKeys = const {},
  });

  /// Remote homeserver failures, keyed by homeserver name.
  final Map<String, Object?> failures;

  /// Public device keys keyed by Matrix user id, then device id.
  final Map<String, Map<String, HouraMatrixDeviceKey>> deviceKeys;

  /// Optional public cross-signing master keys keyed by Matrix user id.
  final Map<String, HouraMatrixCrossSigningKey> masterKeys;

  /// Optional public self-signing keys keyed by Matrix user id.
  final Map<String, HouraMatrixCrossSigningKey> selfSigningKeys;

  /// Optional public user-signing keys keyed by Matrix user id.
  final Map<String, HouraMatrixCrossSigningKey> userSigningKeys;

  factory HouraDeviceKeyQueryResponse.fromJson(Map<String, Object?> json) {
    return HouraDeviceKeyQueryResponse(
      failures: _requiredJsonObject(json, 'failures'),
      deviceKeys: _requiredDeviceKeyUsers(json, 'device_keys'),
      masterKeys: _optionalCrossSigningKeyUsers(json, 'master_keys'),
      selfSigningKeys: _optionalCrossSigningKeyUsers(json, 'self_signing_keys'),
      userSigningKeys: _optionalCrossSigningKeyUsers(json, 'user_signing_keys'),
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

/// SPEC-053 Matrix key-backup create response.
final class HouraKeyBackupVersionCreateResponse {
  const HouraKeyBackupVersionCreateResponse({required this.version});

  final String version;

  factory HouraKeyBackupVersionCreateResponse.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraKeyBackupVersionCreateResponse(
      version: _requiredString(json, 'version'),
    );
  }
}

/// SPEC-053 Matrix key-backup version metadata.
final class HouraKeyBackupVersion {
  const HouraKeyBackupVersion({
    required this.version,
    required this.algorithm,
    required this.raw,
    this.authData,
  });

  final String version;
  final String algorithm;
  final Map<String, Object?>? authData;
  final Map<String, Object?> raw;

  factory HouraKeyBackupVersion.fromJson(Map<String, Object?> json) {
    return HouraKeyBackupVersion(
      version: _requiredString(json, 'version'),
      algorithm: _requiredString(json, 'algorithm'),
      authData: _optionalJsonObject(json, 'auth_data'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson({bool includeVersion = true}) => {
        ...raw,
        if (includeVersion) 'version': version,
        'algorithm': algorithm,
        if (authData != null) 'auth_data': authData,
      };
}

/// SPEC-053 Matrix room-key backup upload response.
final class HouraKeyBackupUploadResponse {
  const HouraKeyBackupUploadResponse({required this.etag, required this.count});

  final String etag;
  final int count;

  factory HouraKeyBackupUploadResponse.fromJson(Map<String, Object?> json) {
    return HouraKeyBackupUploadResponse(
      etag: _requiredString(json, 'etag'),
      count: _requiredNonNegativeInt(json, 'count'),
    );
  }
}

/// SPEC-053 Matrix room-key backup session metadata.
final class HouraKeyBackupSessionData {
  const HouraKeyBackupSessionData({
    required this.firstMessageIndex,
    required this.forwardedCount,
    required this.isVerified,
    required this.sessionData,
    required this.raw,
  });

  final int firstMessageIndex;
  final int forwardedCount;
  final bool isVerified;
  final Map<String, Object?> sessionData;
  final Map<String, Object?> raw;

  factory HouraKeyBackupSessionData.fromJson(Map<String, Object?> json) {
    return HouraKeyBackupSessionData(
      firstMessageIndex: _requiredNonNegativeInt(json, 'first_message_index'),
      forwardedCount: _requiredNonNegativeInt(json, 'forwarded_count'),
      isVerified: _requiredBool(json, 'is_verified'),
      sessionData: _requiredJsonObject(json, 'session_data'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'first_message_index': firstMessageIndex,
        'forwarded_count': forwardedCount,
        'is_verified': isVerified,
        'session_data': sessionData,
      };
}

/// SPEC-054 Matrix public cross-signing key object.
final class HouraMatrixCrossSigningKey {
  const HouraMatrixCrossSigningKey({
    required this.usage,
    required this.raw,
    this.userId,
    this.keys = const {},
    this.signatures = const {},
  });

  final String? userId;
  final List<String> usage;
  final Map<String, String> keys;
  final Map<String, Map<String, String>> signatures;
  final Map<String, Object?> raw;

  factory HouraMatrixCrossSigningKey.fromJson(Map<String, Object?> json) {
    return HouraMatrixCrossSigningKey(
      userId: _optionalString(json, 'user_id'),
      usage: _requiredStringList(json, 'usage'),
      keys: _optionalStringMap(json, 'keys'),
      signatures: _optionalNestedStringMap(json, 'signatures'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() {
    if (usage.isEmpty) {
      throw const HouraResponseFormatException(
        'Expected string array "usage".',
      );
    }
    if (userId == null) {
      throw const HouraResponseFormatException(
        'Expected non-empty string "user_id".',
      );
    }
    if (keys.isEmpty) {
      throw const HouraResponseFormatException('Expected string map "keys".');
    }
    return {
      ...raw,
      'user_id': _requiredToJsonString(userId, 'user_id'),
      'usage': usage,
      'keys': keys,
      if (signatures.isNotEmpty) 'signatures': signatures,
    };
  }
}

/// SPEC-054 Matrix signed device or cross-signing key object.
final class HouraMatrixSignedJsonObject {
  const HouraMatrixSignedJsonObject({
    required this.userId,
    required this.keys,
    required this.signatures,
    required this.raw,
    this.deviceId,
    this.algorithms = const [],
    this.usage = const [],
  });

  final String userId;
  final String? deviceId;
  final List<String> algorithms;
  final List<String> usage;
  final Map<String, String> keys;
  final Map<String, Map<String, String>> signatures;
  final Map<String, Object?> raw;

  factory HouraMatrixSignedJsonObject.fromJson(Map<String, Object?> json) {
    return HouraMatrixSignedJsonObject(
      userId: _requiredString(json, 'user_id'),
      deviceId: _optionalString(json, 'device_id'),
      algorithms: _optionalStringList(json, 'algorithms'),
      usage: _optionalStringList(json, 'usage'),
      keys: _requiredStringMap(json, 'keys'),
      signatures: _requiredNestedStringMap(json, 'signatures'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'user_id': userId,
        if (deviceId != null) 'device_id': deviceId,
        if (algorithms.isNotEmpty) 'algorithms': algorithms,
        if (usage.isNotEmpty) 'usage': usage,
        'keys': keys,
        'signatures': signatures,
      };
}

/// SPEC-054 Matrix key-signature upload response.
final class HouraKeySignatureUploadResponse {
  const HouraKeySignatureUploadResponse({required this.failures});

  final Map<String, Object?> failures;

  factory HouraKeySignatureUploadResponse.fromJson(Map<String, Object?> json) {
    return HouraKeySignatureUploadResponse(
      failures: _requiredJsonObject(json, 'failures'),
    );
  }
}

/// SPEC-054 `m.key.verification.request` to-device content.
final class HouraMatrixVerificationRequestContent {
  const HouraMatrixVerificationRequestContent({
    required this.fromDevice,
    required this.methods,
    required this.timestamp,
    required this.transactionId,
    required this.raw,
  });

  final String fromDevice;
  final List<String> methods;
  final int timestamp;
  final String transactionId;
  final Map<String, Object?> raw;

  factory HouraMatrixVerificationRequestContent.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixVerificationRequestContent(
      fromDevice: _requiredString(json, 'from_device'),
      methods: _requiredStringList(json, 'methods'),
      timestamp: _requiredNonNegativeInt(json, 'timestamp'),
      transactionId: _requiredString(json, 'transaction_id'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'from_device': fromDevice,
        'methods': methods,
        'timestamp': timestamp,
        'transaction_id': transactionId,
      };
}

/// SPEC-054 `m.key.verification.ready` to-device content.
final class HouraMatrixVerificationReadyContent {
  const HouraMatrixVerificationReadyContent({
    required this.fromDevice,
    required this.methods,
    required this.transactionId,
    required this.raw,
  });

  final String fromDevice;
  final List<String> methods;
  final String transactionId;
  final Map<String, Object?> raw;

  factory HouraMatrixVerificationReadyContent.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixVerificationReadyContent(
      fromDevice: _requiredString(json, 'from_device'),
      methods: _requiredStringList(json, 'methods'),
      transactionId: _requiredString(json, 'transaction_id'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'from_device': fromDevice,
        'methods': methods,
        'transaction_id': transactionId,
      };
}

/// SPEC-054 `m.key.verification.start` to-device content.
final class HouraMatrixVerificationStartContent {
  const HouraMatrixVerificationStartContent({
    required this.fromDevice,
    required this.hashes,
    required this.keyAgreementProtocols,
    required this.messageAuthenticationCodes,
    required this.method,
    required this.shortAuthenticationString,
    required this.transactionId,
    required this.raw,
  });

  final String fromDevice;
  final List<String> hashes;
  final List<String> keyAgreementProtocols;
  final List<String> messageAuthenticationCodes;
  final String method;
  final List<String> shortAuthenticationString;
  final String transactionId;
  final Map<String, Object?> raw;

  factory HouraMatrixVerificationStartContent.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixVerificationStartContent(
      fromDevice: _requiredString(json, 'from_device'),
      hashes: _requiredStringList(json, 'hashes'),
      keyAgreementProtocols: _requiredStringList(
        json,
        'key_agreement_protocols',
      ),
      messageAuthenticationCodes: _requiredStringList(
        json,
        'message_authentication_codes',
      ),
      method: _requiredString(json, 'method'),
      shortAuthenticationString: _requiredStringList(
        json,
        'short_authentication_string',
      ),
      transactionId: _requiredString(json, 'transaction_id'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'from_device': fromDevice,
        'hashes': hashes,
        'key_agreement_protocols': keyAgreementProtocols,
        'message_authentication_codes': messageAuthenticationCodes,
        'method': method,
        'short_authentication_string': shortAuthenticationString,
        'transaction_id': transactionId,
      };
}

/// SPEC-054 `m.key.verification.accept` to-device content.
final class HouraMatrixVerificationAcceptContent {
  const HouraMatrixVerificationAcceptContent({
    required this.commitment,
    required this.hash,
    required this.keyAgreementProtocol,
    required this.messageAuthenticationCode,
    required this.method,
    required this.shortAuthenticationString,
    required this.transactionId,
    required this.raw,
  });

  final String commitment;
  final String hash;
  final String keyAgreementProtocol;
  final String messageAuthenticationCode;
  final String method;
  final List<String> shortAuthenticationString;
  final String transactionId;
  final Map<String, Object?> raw;

  factory HouraMatrixVerificationAcceptContent.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixVerificationAcceptContent(
      commitment: _requiredString(json, 'commitment'),
      hash: _requiredString(json, 'hash'),
      keyAgreementProtocol: _requiredString(json, 'key_agreement_protocol'),
      messageAuthenticationCode: _requiredString(
        json,
        'message_authentication_code',
      ),
      method: _requiredString(json, 'method'),
      shortAuthenticationString: _requiredStringList(
        json,
        'short_authentication_string',
      ),
      transactionId: _requiredString(json, 'transaction_id'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'commitment': commitment,
        'hash': hash,
        'key_agreement_protocol': keyAgreementProtocol,
        'message_authentication_code': messageAuthenticationCode,
        'method': method,
        'short_authentication_string': shortAuthenticationString,
        'transaction_id': transactionId,
      };
}

/// SPEC-054 `m.key.verification.key` to-device content.
final class HouraMatrixVerificationKeyContent {
  const HouraMatrixVerificationKeyContent({
    required this.key,
    required this.transactionId,
    required this.raw,
  });

  final String key;
  final String transactionId;
  final Map<String, Object?> raw;

  factory HouraMatrixVerificationKeyContent.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixVerificationKeyContent(
      key: _requiredString(json, 'key'),
      transactionId: _requiredString(json, 'transaction_id'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'key': key,
        'transaction_id': transactionId,
      };
}

/// SPEC-054 `m.key.verification.mac` to-device content.
final class HouraMatrixVerificationMacContent {
  const HouraMatrixVerificationMacContent({
    required this.keys,
    required this.mac,
    required this.transactionId,
    required this.raw,
  });

  final String keys;
  final Map<String, String> mac;
  final String transactionId;
  final Map<String, Object?> raw;

  factory HouraMatrixVerificationMacContent.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixVerificationMacContent(
      keys: _requiredString(json, 'keys'),
      mac: _requiredStringMap(json, 'mac'),
      transactionId: _requiredString(json, 'transaction_id'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'keys': keys,
        'mac': mac,
        'transaction_id': transactionId,
      };
}

/// SPEC-054 `m.key.verification.cancel` to-device content.
final class HouraMatrixVerificationCancelContent {
  const HouraMatrixVerificationCancelContent({
    required this.code,
    required this.reason,
    required this.transactionId,
    required this.raw,
  });

  final String code;
  final String reason;
  final String transactionId;
  final Map<String, Object?> raw;

  factory HouraMatrixVerificationCancelContent.fromJson(
    Map<String, Object?> json,
  ) {
    return HouraMatrixVerificationCancelContent(
      code: _requiredString(json, 'code'),
      reason: _requiredString(json, 'reason'),
      transactionId: _requiredString(json, 'transaction_id'),
      raw: Map<String, Object?>.unmodifiable(json),
    );
  }

  Map<String, Object?> toJson() => {
        ...raw,
        'code': code,
        'reason': reason,
        'transaction_id': transactionId,
      };
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw HouraResponseFormatException('Expected non-empty string "$key".');
}

String _requiredToJsonString(String? value, String key) {
  if (value != null && value.isNotEmpty) {
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

int _requiredNonNegativeInt(Map<String, Object?> json, String key) {
  final value = _requiredInt(json, key);
  if (value >= 0) {
    return value;
  }
  throw HouraResponseFormatException('Expected non-negative integer "$key".');
}

int? _optionalNonNegativeInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is int && value >= 0) {
    return value;
  }
  throw HouraResponseFormatException(
    'Expected optional non-negative integer "$key".',
  );
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

List<Object?> _requiredArray(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is List) {
    return List<Object?>.unmodifiable(value);
  }
  throw HouraResponseFormatException('Expected array "$key".');
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

bool _requiredBool(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is bool) {
    return value;
  }
  throw HouraResponseFormatException('Expected boolean "$key".');
}

bool _isMatrixMembershipValue(String value) {
  const allowed = {'invite', 'join', 'knock', 'leave', 'ban'};
  return allowed.contains(value);
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

List<String> _requiredBoundedStringList(
  Map<String, Object?> json,
  String key, {
  required int maxItems,
}) {
  final value = json[key];
  if (value is! List) {
    throw HouraResponseFormatException('Expected string array "$key".');
  }
  if (value.length > maxItems) {
    throw HouraResponseFormatException('Expected bounded string array "$key".');
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

List<String> _optionalStringList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return const [];
  }
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

List<String> _optionalMatrixUserIdList(Map<String, Object?> json, String key) {
  final values = _optionalStringList(json, key);
  for (final value in values) {
    if (!value.startsWith('@')) {
      throw HouraResponseFormatException(
        'Expected Matrix user ID array "$key".',
      );
    }
  }
  return values;
}

List<HouraMatrixBasicEvent> _optionalMatrixBasicEvents(
  Map<String, Object?> json,
  String key,
) {
  final section = _optionalJsonObject(json, key);
  if (section == null) {
    return const [];
  }
  final events = section['events'];
  if (events == null) {
    return const [];
  }
  if (events is! List) {
    throw HouraResponseFormatException('Expected object array "events".');
  }
  return List<HouraMatrixBasicEvent>.unmodifiable(
    events.map((event) {
      if (event is Map) {
        return HouraMatrixBasicEvent.fromJson(event.cast<String, Object?>());
      }
      throw HouraResponseFormatException('Expected object array "events".');
    }),
  );
}

Map<String, int> _optionalNonNegativeIntMap(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    return const {};
  }
  if (value is! Map) {
    throw HouraResponseFormatException('Expected integer map "$key".');
  }
  return Map<String, int>.unmodifiable(
    value.cast<String, Object?>().map((mapKey, mapValue) {
      if (mapKey.isEmpty || mapValue is! int || mapValue < 0) {
        throw HouraResponseFormatException('Expected integer map "$key".');
      }
      return MapEntry(mapKey, mapValue);
    }),
  );
}

Map<String, Map<String, Object?>> _optionalObjectMap(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    return const {};
  }
  if (value is! Map) {
    throw HouraResponseFormatException('Expected object map "$key".');
  }
  return Map<String, Map<String, Object?>>.unmodifiable(
    value.cast<String, Object?>().map((mapKey, mapValue) {
      if (mapKey.isEmpty || mapValue is! Map) {
        throw HouraResponseFormatException('Expected object map "$key".');
      }
      return MapEntry(
        mapKey,
        Map<String, Object?>.unmodifiable(mapValue.cast<String, Object?>()),
      );
    }),
  );
}

void _validateMatrixSyncQueryParams(Map<String, Object?> queryParams) {
  for (final entry in queryParams.entries) {
    final key = entry.key;
    final value = entry.value;
    switch (key) {
      case 'filter':
        _validateMatrixSyncFilter(value);
      case 'full_state':
      case 'use_state_after':
        if (value is! bool) {
          throw HouraResponseFormatException(
            'Expected boolean sync query parameter "$key".',
          );
        }
      case 'set_presence':
        if (value != 'online' && value != 'offline' && value != 'unavailable') {
          throw HouraResponseFormatException(
            'Expected supported set_presence value.',
          );
        }
      case 'since':
        if (value is! String || value.isEmpty) {
          throw HouraResponseFormatException(
            'Expected non-empty since sync query parameter.',
          );
        }
      case 'timeout':
        if (value is! int || value < 0) {
          throw HouraResponseFormatException(
            'Expected non-negative timeout sync query parameter.',
          );
        }
      default:
        throw HouraResponseFormatException(
          'Unsupported Matrix sync query parameter "$key".',
        );
    }
  }
}

void _validateMatrixSyncFilter(Object? value) {
  if (value is String && value.isNotEmpty) {
    return;
  }
  if (value is! Map) {
    throw HouraResponseFormatException('Expected Matrix sync filter.');
  }
  final room = value.cast<String, Object?>()['room'];
  if (room is! Map) {
    return;
  }
  final roomMap = room.cast<String, Object?>();
  for (final sectionName in const ['state', 'timeline']) {
    final section = roomMap[sectionName];
    if (section is! Map) {
      continue;
    }
    final lazyLoadMembers =
        section.cast<String, Object?>()['lazy_load_members'];
    if (lazyLoadMembers != null && lazyLoadMembers is! bool) {
      throw HouraResponseFormatException(
        'Expected boolean lazy_load_members sync filter.',
      );
    }
  }
}

void _validateMatrixMediaDescriptor(
  HouraMatrixMediaRequestDescriptor descriptor,
) {
  const parsersByPath = {
    '/_matrix/client/v1/media/config': 'media_config',
    '/_matrix/client/v1/media/preview_url': 'media_preview_url',
    '/_matrix/client/v1/media/thumbnail/{serverName}/{mediaId}':
        'media_thumbnail_metadata',
    '/_matrix/media/v1/create': 'media_upload_create',
    '/_matrix/media/v3/upload/{serverName}/{mediaId}': 'media_upload_resume',
  };
  final expectedParser = parsersByPath[descriptor.path];
  if (expectedParser == null ||
      descriptor.responseParser != expectedParser ||
      descriptor.requiresAuth != true ||
      descriptor.adoptedRuntimeBehavior != false) {
    throw HouraResponseFormatException(
      'Unsupported Matrix media request descriptor.',
    );
  }
  if ((descriptor.path == '/_matrix/client/v1/media/config' ||
          descriptor.path == '/_matrix/client/v1/media/preview_url' ||
          descriptor.path ==
              '/_matrix/client/v1/media/thumbnail/{serverName}/{mediaId}') &&
      descriptor.method != 'GET') {
    throw HouraResponseFormatException(
      'Unsupported Matrix media descriptor method.',
    );
  }
  if (descriptor.path == '/_matrix/media/v1/create' &&
      descriptor.method != 'POST') {
    throw HouraResponseFormatException(
      'Unsupported Matrix media descriptor method.',
    );
  }
  if (descriptor.path == '/_matrix/media/v3/upload/{serverName}/{mediaId}' &&
      descriptor.method != 'PUT') {
    throw HouraResponseFormatException(
      'Unsupported Matrix media descriptor method.',
    );
  }
  final serverName = descriptor.pathParams['serverName'];
  final mediaId = descriptor.pathParams['mediaId'];
  if (descriptor.path.contains('{serverName}') &&
      (serverName is! String ||
          serverName.isEmpty ||
          mediaId is! String ||
          mediaId.isEmpty ||
          !_isOpaqueMatrixMediaId(mediaId))) {
    throw HouraResponseFormatException(
      'Expected Matrix media path parameters.',
    );
  }
  switch (descriptor.responseParser) {
    case 'media_config':
    case 'media_upload_create':
      if (descriptor.queryParams.isNotEmpty) {
        throw HouraResponseFormatException(
          'Unsupported Matrix media query parameters.',
        );
      }
    case 'media_preview_url':
      _validateMatrixMediaQueryKeys(descriptor.queryParams, const {
        'url',
        'ts',
      });
      final url = descriptor.queryParams['url'];
      if (url is! String || url.isEmpty) {
        throw HouraResponseFormatException(
          'Expected non-empty Matrix media preview URL.',
        );
      }
      final ts = descriptor.queryParams['ts'];
      if (ts != null && (ts is! int || ts < 0)) {
        throw HouraResponseFormatException(
          'Expected non-negative Matrix media timestamp.',
        );
      }
    case 'media_thumbnail_metadata':
      _validateMatrixMediaThumbnailQuery(descriptor.queryParams);
    case 'media_upload_resume':
      _validateMatrixMediaQueryKeys(descriptor.queryParams, const {'filename'});
      final filename = descriptor.queryParams['filename'];
      if (filename != null) {
        if (filename is! String) {
          throw HouraResponseFormatException(
            'Expected non-empty Matrix media query string.',
          );
        }
        _validateSafeMediaFilename(filename);
      }
  }
}

void _validateMatrixMediaThumbnailQuery(Map<String, Object?> queryParams) {
  _validateMatrixMediaQueryKeys(queryParams, const {
    'width',
    'height',
    'method',
    'timeout_ms',
    'allow_remote',
    'animated',
  });
  for (final entry in queryParams.entries) {
    final value = entry.value;
    switch (entry.key) {
      case 'width':
      case 'height':
        if (value is! int || value <= 0) {
          throw HouraResponseFormatException(
            'Expected positive Matrix media thumbnail dimension.',
          );
        }
      case 'timeout_ms':
        if (value is! int || value < 0) {
          throw HouraResponseFormatException(
            'Expected non-negative Matrix media timeout.',
          );
        }
      case 'method':
        if (value != 'scale' && value != 'crop') {
          throw HouraResponseFormatException(
            'Expected supported Matrix media thumbnail method.',
          );
        }
      case 'allow_remote':
      case 'animated':
        if (value is! bool) {
          throw HouraResponseFormatException(
            'Expected boolean Matrix media thumbnail option.',
          );
        }
    }
  }
  if (queryParams['width'] == null ||
      queryParams['height'] == null ||
      queryParams['method'] == null) {
    throw HouraResponseFormatException(
      'Expected required Matrix media thumbnail query parameters.',
    );
  }
}

void _validateMatrixMediaQueryKeys(
  Map<String, Object?> queryParams,
  Set<String> allowedKeys,
) {
  for (final key in queryParams.keys) {
    if (!allowedKeys.contains(key)) {
      throw HouraResponseFormatException(
        'Unsupported Matrix media query parameter "$key".',
      );
    }
  }
}

({String serverName, String mediaId}) _parseMatrixMediaContentUri(
  Object? value,
) {
  if (value is! String || !value.startsWith('mxc://')) {
    throw HouraResponseFormatException('Expected Matrix Content URI.');
  }
  final rest = value.substring('mxc://'.length);
  final slashIndex = rest.indexOf('/');
  if (slashIndex <= 0 || slashIndex == rest.length - 1) {
    throw HouraResponseFormatException('Expected Matrix Content URI.');
  }
  final serverName = rest.substring(0, slashIndex);
  final mediaId = rest.substring(slashIndex + 1);
  if (serverName.trim().isEmpty || !_isOpaqueMatrixMediaId(mediaId)) {
    throw HouraResponseFormatException('Expected Matrix Content URI.');
  }
  return (serverName: serverName, mediaId: mediaId);
}

bool _isOpaqueMatrixMediaId(String value) {
  return value.isNotEmpty &&
      !value.contains('/') &&
      !value.contains(r'\') &&
      value != '.' &&
      value != '..' &&
      !value.contains(RegExp(r'\s'));
}

void _validateSafeMediaFilename(String value) {
  if (value.isEmpty ||
      value == '.' ||
      value == '..' ||
      value.contains('/') ||
      value.contains(r'\') ||
      value.contains('"') ||
      value.contains('%') ||
      value.contains('..') ||
      value.codeUnits.any((unit) => unit < 0x20 || unit == 0x7f)) {
    throw HouraResponseFormatException('Expected safe media filename.');
  }
}

void _validateMatrixFederationDescriptor(
  HouraMatrixFederationRequestDescriptor descriptor,
) {
  const expectedParsers = {
    '/_matrix/federation/v1/version': 'federation_version',
    '/_matrix/key/v2/query': 'federation_key_query_response',
    '/_matrix/key/v2/query/{serverName}/{keyId}':
        'federation_key_query_response',
    '/_matrix/federation/v1/send/{txnId}': {
      'federation_request_auth_descriptor',
      'federation_transaction_response_descriptor',
    },
    '/_matrix/federation/v1/publicRooms': 'federation_public_rooms_response',
    '/_matrix/federation/v1/hierarchy/{roomId}':
        'federation_hierarchy_response',
    '/_matrix/federation/v1/query/directory':
        'federation_directory_query_response',
    '/_matrix/federation/v1/query/profile': 'federation_profile_query_response',
    '/_matrix/federation/v1/openid/userinfo':
        'federation_openid_userinfo_response',
  };
  final expectedParser = expectedParsers[descriptor.path];
  final parserMatches = expectedParser is Set<String>
      ? expectedParser.contains(descriptor.responseParser)
      : descriptor.responseParser == expectedParser;
  if (expectedParser == null ||
      !parserMatches ||
      descriptor.adoptedRuntimeBehavior != false) {
    throw HouraResponseFormatException(
      'Unsupported Matrix federation request descriptor.',
    );
  }
  if ((descriptor.path == '/_matrix/federation/v1/version' &&
          (descriptor.method != 'GET' || descriptor.requiresAuth)) ||
      (descriptor.path == '/_matrix/key/v2/query' &&
          (descriptor.method != 'POST' || descriptor.requiresAuth)) ||
      (descriptor.path == '/_matrix/key/v2/query/{serverName}/{keyId}' &&
          (descriptor.method != 'GET' || descriptor.requiresAuth)) ||
      (descriptor.path == '/_matrix/federation/v1/send/{txnId}' &&
          (descriptor.method != 'PUT' || !descriptor.requiresAuth)) ||
      (descriptor.path == '/_matrix/federation/v1/publicRooms' &&
          (descriptor.method != 'GET' && descriptor.method != 'POST' ||
              !descriptor.requiresAuth)) ||
      (descriptor.path == '/_matrix/federation/v1/hierarchy/{roomId}' &&
          (descriptor.method != 'GET' || !descriptor.requiresAuth)) ||
      (descriptor.path == '/_matrix/federation/v1/query/directory' &&
          (descriptor.method != 'GET' || !descriptor.requiresAuth)) ||
      (descriptor.path == '/_matrix/federation/v1/query/profile' &&
          (descriptor.method != 'GET' || !descriptor.requiresAuth)) ||
      (descriptor.path == '/_matrix/federation/v1/openid/userinfo' &&
          (descriptor.method != 'GET' || descriptor.requiresAuth))) {
    throw HouraResponseFormatException(
      'Unsupported Matrix federation descriptor method.',
    );
  }
  final allowedQueryParams = switch (descriptor.path) {
    '/_matrix/federation/v1/publicRooms' => {'limit', 'since'},
    '/_matrix/federation/v1/hierarchy/{roomId}' => {'suggested_only'},
    '/_matrix/federation/v1/query/directory' => {'room_alias'},
    '/_matrix/federation/v1/query/profile' => {'user_id'},
    '/_matrix/federation/v1/openid/userinfo' => {'access_token'},
    _ => const <String>{},
  };
  if (descriptor.queryParams.keys.any(
    (key) => !allowedQueryParams.contains(key),
  )) {
    throw HouraResponseFormatException(
      'Unsupported Matrix federation query parameters.',
    );
  }
  final serverName = descriptor.pathParams['serverName'];
  if (descriptor.path.contains('{serverName}')) {
    if (serverName is! String) {
      throw HouraResponseFormatException(
        'Expected Matrix federation server name.',
      );
    }
    _validateMatrixFederationServerName(serverName);
  }
  final keyId = descriptor.pathParams['keyId'];
  if (descriptor.path.contains('{keyId}')) {
    if (keyId is! String) {
      throw HouraResponseFormatException('Expected Matrix federation key ID.');
    }
    _validateMatrixFederationKeyId(keyId);
  }
  final txnId = descriptor.pathParams['txnId'];
  if (descriptor.path.contains('{txnId}') &&
      (txnId is! String || txnId.isEmpty || txnId.contains('/'))) {
    throw HouraResponseFormatException(
      'Expected Matrix federation transaction ID.',
    );
  }
  final roomId = descriptor.pathParams['roomId'];
  if (descriptor.path.contains('{roomId}') &&
      (roomId is! String || !roomId.startsWith('!'))) {
    throw HouraResponseFormatException('Expected Matrix federation room ID.');
  }
}

void _validateMatrixFederationServerName(String value) {
  if (value.isEmpty ||
      value.length > 255 ||
      value.contains('/') ||
      value.contains('@') ||
      value.contains('#')) {
    throw HouraResponseFormatException('Expected Matrix federation server.');
  }
  final parts = value.split(':');
  final host = parts.length == 2 ? parts.first : value;
  if (parts.length > 2 ||
      host.isEmpty ||
      host.startsWith('.') ||
      host.endsWith('.')) {
    throw HouraResponseFormatException('Expected Matrix federation server.');
  }
  if (parts.length == 2) {
    final port = int.tryParse(parts.last);
    if (port == null || port < 0 || port > 65535) {
      throw HouraResponseFormatException('Expected Matrix federation port.');
    }
  }
}

void _validateMatrixFederationKeyId(String value) {
  if (!RegExp(r'^ed25519:[A-Za-z0-9_]+$').hasMatch(value)) {
    throw HouraResponseFormatException('Expected Matrix federation key ID.');
  }
}

Map<String, String> _requiredFederationVerifyKeys(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is! Map) {
    throw HouraResponseFormatException('Expected federation verify keys.');
  }
  return Map<String, String>.unmodifiable(
    value.cast<String, Object?>().map((keyId, keyValue) {
      _validateMatrixFederationKeyId(keyId);
      if (keyValue is! Map) {
        throw HouraResponseFormatException('Expected federation verify key.');
      }
      final keyObject = keyValue.cast<String, Object?>();
      return MapEntry(keyId, _requiredString(keyObject, 'key'));
    }),
  );
}

Map<String, HouraMatrixFederationOldVerifyKey> _requiredFederationOldVerifyKeys(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is! Map) {
    throw HouraResponseFormatException('Expected old federation verify keys.');
  }
  return Map<String, HouraMatrixFederationOldVerifyKey>.unmodifiable(
    value.cast<String, Object?>().map((keyId, keyValue) {
      _validateMatrixFederationKeyId(keyId);
      if (keyValue is! Map) {
        throw HouraResponseFormatException(
          'Expected old federation verify key.',
        );
      }
      final keyObject = keyValue.cast<String, Object?>();
      return MapEntry(
        keyId,
        HouraMatrixFederationOldVerifyKey(
          expiredTs: _requiredNonNegativeInt(keyObject, 'expired_ts'),
          key: _requiredString(keyObject, 'key'),
        ),
      );
    }),
  );
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

Map<String, String> _optionalStringMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return const {};
  }
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

Map<String, Map<String, String>> _requiredFederationSignatures(
  Map<String, Object?> json,
  String key,
) {
  final signatures = _requiredNestedStringMap(json, key);
  if (signatures.isEmpty || signatures.length > 8) {
    throw HouraResponseFormatException('Expected federation signatures.');
  }
  for (final entry in signatures.entries) {
    _validateMatrixFederationServerName(entry.key);
    if (entry.value.isEmpty || entry.value.length > 8) {
      throw HouraResponseFormatException('Expected federation signatures.');
    }
    for (final keyId in entry.value.keys) {
      _validateMatrixFederationKeyId(keyId);
    }
  }
  return signatures;
}

List<HouraMatrixFederationPdu> _requiredFederationPdus(
  Map<String, Object?> json,
  String key, {
  required int maxItems,
}) {
  final value = json[key];
  if (value is! List) {
    throw HouraResponseFormatException('Expected Matrix federation PDU array.');
  }
  if (value.length > maxItems) {
    throw HouraResponseFormatException(
      'Expected bounded Matrix federation PDU array.',
    );
  }
  return List<HouraMatrixFederationPdu>.unmodifiable(
    value.map((item) {
      if (item is Map) {
        return HouraMatrixFederationPdu.fromJson(item.cast<String, Object?>());
      }
      throw HouraResponseFormatException(
        'Expected Matrix federation PDU object.',
      );
    }),
  );
}

List<HouraMatrixFederationEdu> _requiredFederationEdus(
  Map<String, Object?> json,
  String key, {
  required int maxItems,
}) {
  final value = json[key];
  if (value is! List) {
    throw HouraResponseFormatException('Expected Matrix federation EDU array.');
  }
  if (value.length > maxItems) {
    throw HouraResponseFormatException(
      'Expected bounded Matrix federation EDU array.',
    );
  }
  return List<HouraMatrixFederationEdu>.unmodifiable(
    value.map((item) {
      if (item is Map) {
        return HouraMatrixFederationEdu.fromJson(item.cast<String, Object?>());
      }
      throw HouraResponseFormatException(
        'Expected Matrix federation EDU object.',
      );
    }),
  );
}

List<HouraMatrixFederationRoomSummary> _requiredFederationRoomSummaries(
  Map<String, Object?> json,
  String key, {
  required int maxItems,
}) {
  final value = json[key];
  if (value is! List) {
    throw HouraResponseFormatException(
      'Expected Matrix federation room summaries.',
    );
  }
  if (value.length > maxItems) {
    throw HouraResponseFormatException(
      'Expected bounded Matrix federation room summaries.',
    );
  }
  return List<HouraMatrixFederationRoomSummary>.unmodifiable(
    value.map((item) {
      if (item is Map) {
        return HouraMatrixFederationRoomSummary.fromJson(
          item.cast<String, Object?>(),
        );
      }
      throw HouraResponseFormatException(
        'Expected Matrix federation room summary.',
      );
    }),
  );
}

List<HouraMatrixFederationChildStateEvent> _optionalFederationChildState(
  Map<String, Object?> json,
  String key, {
  required int maxItems,
}) {
  final value = json[key];
  if (value == null) {
    return const [];
  }
  if (value is! List) {
    throw HouraResponseFormatException(
      'Expected Matrix federation child state.',
    );
  }
  if (value.length > maxItems) {
    throw HouraResponseFormatException(
      'Expected bounded Matrix federation child state.',
    );
  }
  return List<HouraMatrixFederationChildStateEvent>.unmodifiable(
    value.map((item) {
      if (item is Map) {
        return HouraMatrixFederationChildStateEvent.fromJson(
          item.cast<String, Object?>(),
        );
      }
      throw HouraResponseFormatException(
        'Expected Matrix federation child state event.',
      );
    }),
  );
}

Map<String, Map<String, String>> _optionalNestedStringMap(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    return const {};
  }
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

Map<String, HouraMatrixCrossSigningKey> _optionalCrossSigningKeyUsers(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    return const {};
  }
  if (value is! Map) {
    throw HouraResponseFormatException(
      'Expected cross-signing key map "$key".',
    );
  }
  return Map<String, HouraMatrixCrossSigningKey>.unmodifiable(
    value.cast<String, Object?>().map((userId, keyValue) {
      if (keyValue is! Map) {
        throw HouraResponseFormatException(
          'Expected cross-signing key map "$key".',
        );
      }
      return MapEntry(
        userId,
        HouraMatrixCrossSigningKey.fromJson(keyValue.cast<String, Object?>()),
      );
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

List<HouraMatrixToDeviceEvent> _optionalToDeviceEvents(
  Map<String, Object?> json,
) {
  final toDevice = json['to_device'];
  if (toDevice == null) {
    return const [];
  }
  if (toDevice is! Map) {
    throw HouraResponseFormatException('Expected object "to_device".');
  }
  final events = toDevice.cast<String, Object?>()['events'];
  if (events == null) {
    return const [];
  }
  if (events is! List) {
    throw HouraResponseFormatException('Expected object array "events".');
  }
  return List<HouraMatrixToDeviceEvent>.unmodifiable(
    events.map((event) {
      if (event is Map) {
        return HouraMatrixToDeviceEvent.fromJson(event.cast<String, Object?>());
      }
      throw HouraResponseFormatException('Expected object array "events".');
    }),
  );
}

Map<String, HouraOlmCiphertext> _requiredOlmCiphertextMap(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is! Map) {
    throw HouraResponseFormatException('Expected Olm ciphertext map "$key".');
  }
  return Map<String, HouraOlmCiphertext>.unmodifiable(
    value.cast<String, Object?>().map((recipientKey, ciphertextValue) {
      if (ciphertextValue is! Map) {
        throw HouraResponseFormatException(
          'Expected Olm ciphertext object "$key".',
        );
      }
      return MapEntry(
        recipientKey,
        HouraOlmCiphertext.fromJson(ciphertextValue.cast<String, Object?>()),
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
