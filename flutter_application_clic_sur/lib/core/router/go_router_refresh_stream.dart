import 'dart:async';

import 'package:flutter/foundation.dart';

/// Fait réévaluer les redirections de go_router à chaque événement du flux
/// (ici : connexion / déconnexion Supabase).
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
