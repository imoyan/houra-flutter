import 'package:flutter_test/flutter_test.dart';
import 'package:houra/houra.dart' as houra;

void main() {
  test('public entrypoint exports the initial SDK surface', () {
    expect(houra.HouraClient, isA<Type>());
    expect(houra.HouraAuthClient, isA<Type>());
    expect(houra.HouraDiscoveryClient, isA<Type>());
    expect(houra.HouraRoomsClient, isA<Type>());
    expect(houra.HouraMessagingClient, isA<Type>());
    expect(houra.HouraSyncClient, isA<Type>());
    expect(houra.HouraMediaClient, isA<Type>());
    expect(houra.HouraServerVersions, isA<Type>());
    expect(houra.HouraLoginFlows, isA<Type>());
    expect(houra.HouraLoginFlow, isA<Type>());
    expect(houra.HouraAuthSession, isA<Type>());
    expect(houra.HouraWhoami, isA<Type>());
    expect(houra.HouraRoom, isA<Type>());
    expect(houra.HouraRoomMembership, isA<Type>());
    expect(houra.HouraRoomState, isA<Type>());
    expect(houra.HouraEvent, isA<Type>());
    expect(houra.HouraTextMessageEvent, isA<Type>());
    expect(houra.HouraSendMessageResponse, isA<Type>());
    expect(houra.HouraRoomList, isA<Type>());
    expect(houra.HouraTimelinePage, isA<Type>());
    expect(houra.HouraSyncBatch, isA<Type>());
    expect(houra.HouraSyncRoom, isA<Type>());
    expect(houra.HouraSyncTimeline, isA<Type>());
    expect(houra.HouraSyncTokenStore, isA<Type>());
    expect(houra.HouraMemorySyncTokenStore, isA<Type>());
    expect(houra.HouraMediaUpload, isA<Type>());
    expect(houra.HouraMediaMetadata, isA<Type>());
    expect(houra.HouraException, isA<Type>());
    expect(houra.HouraHttpException, isA<Type>());
    expect(houra.HouraTransportException, isA<Type>());
    expect(houra.HouraResponseFormatException, isA<Type>());
    expect(houra.HouraThemeFormatException, isA<Type>());
    expect(houra.HouraThemeTokens, isA<Type>());
    expect(houra.HouraThemeColorToken, isA<Type>());
    expect(houra.HouraThemeVariant, isA<Type>());
    expect(houra.HouraResolvedTheme, isA<Type>());
    expect(houra.HouraFlutterTheme, isA<Type>());
    expect(houra.houraPasswordLoginType, 'ichigo.login.password');
    expect(houra.houraUserIdentifierType, 'ichigo.id.user');
    expect(houra.houraTextMessageType, 'ichigo.text');
  });
}
