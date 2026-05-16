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
      currentUserParticipated: _requiredBool(
        json,
        'current_user_participated',
      ),
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

  factory HouraMatrixSyncRequestDescriptor.fromJson(
    Map<String, Object?> json,
  ) {
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
    required this.method,
    required this.path,
    required this.pathParams,
    required this.queryParams,
    required this.requiresAuth,
    required this.responseParser,
    required this.adoptedRuntimeBehavior,
  });

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
          'Expected supported thumbnail method.');
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
    final filename = _decodeMediaFilename(rawFilename);
    _validateSafeMediaFilename(filename);
    return HouraMatrixMediaContentDisposition(
      disposition: parts.first,
      filename: filename,
    );
  }
}

String _decodeMediaFilename(String value) {
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    throw HouraResponseFormatException('Expected decodable media filename.');
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
          'Expected Matrix user ID array "$key".');
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
  if (descriptor.path ==
      '/_matrix/client/v1/media/thumbnail/{serverName}/{mediaId}') {
    _validateMatrixMediaThumbnailQuery(descriptor.queryParams);
  } else {
    for (final entry in descriptor.queryParams.entries) {
      switch (entry.key) {
        case 'url':
        case 'filename':
          if (entry.value is! String || (entry.value as String).isEmpty) {
            throw HouraResponseFormatException(
              'Expected non-empty Matrix media query string.',
            );
          }
        case 'ts':
          if (entry.value is! int || (entry.value as int) < 0) {
            throw HouraResponseFormatException(
              'Expected non-negative Matrix media timestamp.',
            );
          }
        default:
          throw HouraResponseFormatException(
            'Unsupported Matrix media query parameter "${entry.key}".',
          );
      }
    }
  }
}

void _validateMatrixMediaThumbnailQuery(Map<String, Object?> queryParams) {
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
      default:
        throw HouraResponseFormatException(
          'Unsupported Matrix media thumbnail query parameter "${entry.key}".',
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
      value.codeUnits.any((unit) => unit < 0x20 || unit == 0x7f)) {
    throw HouraResponseFormatException('Expected safe media filename.');
  }
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

List<HouraMatrixToDeviceEvent> _optionalToDeviceEvents(
    Map<String, Object?> json) {
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
