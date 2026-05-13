/// Flutter SDK prototype for the Houra client API subset.
///
/// Behavior is defined by the sibling `houra-spec` contracts and test vectors,
/// not by existing client or server implementations. The SDK owns request and
/// response mapping for the covered public API surface; host applications own
/// token persistence, sync-token persistence, retries, cancellation policy,
/// media storage, and UI behavior.
///
/// SDK calls throw typed [HouraException] subclasses for transport failures,
/// non-success HTTP responses, malformed contract responses, and malformed
/// theme token files.
library houra;

export 'src/auth.dart';
export 'src/client.dart';
export 'src/discovery.dart';
export 'src/errors.dart';
export 'src/flutter_theme.dart';
export 'src/media.dart';
export 'src/messaging.dart';
export 'src/models.dart';
export 'src/rooms.dart';
export 'src/sync.dart';
export 'src/theme_tokens.dart';
