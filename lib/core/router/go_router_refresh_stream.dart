import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a [Stream] to a [ChangeNotifier] so that go_router's
/// `refreshListenable` can react to bloc state changes.
///
/// Dispose this object when the router is no longer needed.
class GoRouterRefreshStream extends ChangeNotifier {
  /// Creates a [GoRouterRefreshStream] from [stream].
  ///
  /// Immediately calls [notifyListeners] whenever [stream] emits.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
