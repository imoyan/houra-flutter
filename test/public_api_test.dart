import 'package:flutter_test/flutter_test.dart';
import 'package:okaka/okaka.dart' as okaka;

void main() {
  test('public entrypoint exports the initial SDK surface', () {
    expect(okaka.OkakaClient, isA<Type>());
    expect(okaka.OkakaAuthClient, isA<Type>());
    expect(okaka.OkakaDiscoveryClient, isA<Type>());
    expect(okaka.OkakaRoomsClient, isA<Type>());
    expect(okaka.OkakaMessagingClient, isA<Type>());
    expect(okaka.OkakaSyncClient, isA<Type>());
    expect(okaka.OkakaMediaClient, isA<Type>());
    expect(okaka.OkakaServerVersions, isA<Type>());
    expect(okaka.OkakaLoginFlows, isA<Type>());
    expect(okaka.OkakaLoginFlow, isA<Type>());
    expect(okaka.OkakaAuthSession, isA<Type>());
    expect(okaka.OkakaWhoami, isA<Type>());
    expect(okaka.OkakaRoom, isA<Type>());
    expect(okaka.OkakaRoomMembership, isA<Type>());
    expect(okaka.OkakaRoomState, isA<Type>());
    expect(okaka.OkakaEvent, isA<Type>());
    expect(okaka.OkakaTextMessageEvent, isA<Type>());
    expect(okaka.OkakaSendMessageResponse, isA<Type>());
    expect(okaka.OkakaRoomList, isA<Type>());
    expect(okaka.OkakaTimelinePage, isA<Type>());
    expect(okaka.OkakaSyncBatch, isA<Type>());
    expect(okaka.OkakaSyncRoom, isA<Type>());
    expect(okaka.OkakaSyncTimeline, isA<Type>());
    expect(okaka.OkakaSyncTokenStore, isA<Type>());
    expect(okaka.OkakaMemorySyncTokenStore, isA<Type>());
    expect(okaka.OkakaMediaUpload, isA<Type>());
    expect(okaka.OkakaMediaMetadata, isA<Type>());
    expect(okaka.OkakaException, isA<Type>());
    expect(okaka.OkakaHttpException, isA<Type>());
    expect(okaka.OkakaTransportException, isA<Type>());
    expect(okaka.OkakaResponseFormatException, isA<Type>());
    expect(okaka.OkakaThemeFormatException, isA<Type>());
    expect(okaka.OkakaThemeTokens, isA<Type>());
    expect(okaka.OkakaThemeColorToken, isA<Type>());
    expect(okaka.OkakaThemeVariant, isA<Type>());
    expect(okaka.OkakaResolvedTheme, isA<Type>());
    expect(okaka.OkakaFlutterTheme, isA<Type>());
    expect(okaka.okakaPasswordLoginType, 'chawan.login.password');
    expect(okaka.okakaUserIdentifierType, 'chawan.id.user');
    expect(okaka.okakaTextMessageType, 'chawan.text');
  });
}
