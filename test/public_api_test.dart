import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:houra/houra.dart' as houra;

void main() {
  test('public entrypoint exports the initial SDK surface', () {
    expect(houra.HouraClient, isA<Type>());
    expect(houra.HouraAuthClient, isA<Type>());
    expect(houra.HouraDeviceKeysClient, isA<Type>());
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
    expect(houra.HouraMatrixSyncBatch, isA<Type>());
    expect(houra.HouraMatrixToDeviceEvent, isA<Type>());
    expect(houra.HouraMatrixClientEvent, isA<Type>());
    expect(houra.HouraMatrixJoinedMembers, isA<Type>());
    expect(houra.HouraMatrixMembers, isA<Type>());
    expect(houra.HouraMatrixTimestampToEvent, isA<Type>());
    expect(houra.HouraEncryptedPayload, isA<Type>());
    expect(houra.HouraOlmCiphertext, isA<Type>());
    expect(houra.HouraSyncTokenStore, isA<Type>());
    expect(houra.HouraMemorySyncTokenStore, isA<Type>());
    expect(houra.HouraMediaUpload, isA<Type>());
    expect(houra.HouraMediaMetadata, isA<Type>());
    expect(houra.HouraDeviceKeyQueryResponse, isA<Type>());
    expect(houra.HouraMatrixDeviceKey, isA<Type>());
    expect(houra.HouraKeyUploadResponse, isA<Type>());
    expect(houra.HouraKeyClaimResponse, isA<Type>());
    expect(houra.HouraMatrixSignedKey, isA<Type>());
    expect(houra.HouraKeyBackupVersionCreateResponse, isA<Type>());
    expect(houra.HouraKeyBackupVersion, isA<Type>());
    expect(houra.HouraKeyBackupUploadResponse, isA<Type>());
    expect(houra.HouraKeyBackupSessionData, isA<Type>());
    expect(houra.HouraMatrixCrossSigningKey, isA<Type>());
    expect(houra.HouraMatrixSignedJsonObject, isA<Type>());
    expect(houra.HouraKeySignatureUploadResponse, isA<Type>());
    expect(houra.HouraMatrixApplicationServiceRegistration, isA<Type>());
    expect(houra.HouraMatrixApplicationServiceNamespaces, isA<Type>());
    expect(houra.HouraMatrixApplicationServiceNamespace, isA<Type>());
    expect(houra.HouraMatrixApplicationServiceRequestDescriptor, isA<Type>());
    expect(houra.HouraMatrixApplicationServiceTransaction, isA<Type>());
    expect(houra.HouraMatrixApplicationServiceQueryDescriptor, isA<Type>());
    expect(houra.HouraMatrixApplicationServiceGapLane, isA<Type>());
    expect(houra.HouraMatrixApplicationServiceEvidenceRedactor, isA<Type>());
    expect(houra.HouraMatrixFederationTransaction, isA<Type>());
    expect(houra.HouraMatrixFederationEdu, isA<Type>());
    expect(
      houra.HouraMatrixFederationCanonicalJsonInputDescriptor,
      isA<Type>(),
    );
    expect(houra.HouraMatrixFederationPublicRoomsResponse, isA<Type>());
    expect(houra.HouraMatrixFederationHierarchyResponse, isA<Type>());
    expect(houra.HouraMatrixFederationDirectoryQueryResponse, isA<Type>());
    expect(houra.HouraMatrixFederationOpenIdUserinfoResponse, isA<Type>());
    expect(houra.HouraMatrixVerificationRequestContent, isA<Type>());
    expect(houra.HouraMatrixVerificationReadyContent, isA<Type>());
    expect(houra.HouraMatrixVerificationStartContent, isA<Type>());
    expect(houra.HouraMatrixVerificationAcceptContent, isA<Type>());
    expect(houra.HouraMatrixVerificationKeyContent, isA<Type>());
    expect(houra.HouraMatrixVerificationMacContent, isA<Type>());
    expect(houra.HouraMatrixVerificationCancelContent, isA<Type>());
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
    expect(houra.houraPasswordLoginType, 'houra.login.password');
    expect(houra.houraUserIdentifierType, 'houra.id.user');
    expect(houra.houraTextMessageType, 'houra.text');
  });

  test('public entrypoint keeps transport internals out of the export surface',
      () {
    final entrypoint = File('lib/houra.dart').readAsStringSync();

    expect(entrypoint, contains("export 'src/auth.dart';"));
    expect(entrypoint, contains("export 'src/errors.dart';"));
    expect(entrypoint, isNot(contains("export 'src/transport.dart';")));
  });

  test('authenticated public calls reject empty bearer tokens before transport',
      () async {
    final client = houra.HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
    );
    addTearDown(client.close);

    await expectLater(
      client.auth.whoami(accessToken: ''),
      throwsA(
        isA<houra.HouraTransportException>().having(
          (error) => error.message,
          'message',
          'accessToken must be non-empty.',
        ),
      ),
    );
  });

  test('typed HTTP exceptions expose metadata without logging full body', () {
    final longBody = '${' secret'.padRight(220, 'x')}\nnext line';
    final error = houra.HouraHttpException(
      statusCode: 403,
      uri: Uri.parse('https://example.test/_houra/client/rooms'),
      responseBody: longBody,
      code: 'M_FORBIDDEN',
      serverMessage: 'Forbidden',
    );

    expect(error, isA<houra.HouraException>());
    expect(error.message, contains('HTTP 403'));
    expect(error.message, contains('M_FORBIDDEN'));
    expect(error.toString(), isNot(contains(longBody)));
    expect(error.responseBodySummary, hasLength(200));
    expect(error.responseBodySummary, endsWith('...'));
  });
}
