import 'package:flutter/foundation.dart';

class Session {
  final String token;
  final String userName;
  final String email;

  const Session({required this.token, required this.userName, required this.email});
}

class SessionManager {
  final ValueNotifier<Session?> currentSession = ValueNotifier<Session?>(null);

  void setSession(Session session) {
    if (kDebugMode) print('DEBUG SESSION: Guardando sesión para usuario: ${session.userName}');
    currentSession.value = session;
    if (kDebugMode) print('DEBUG SESSION: Sesión guardada exitosamente');
  }

  void clear() {
    currentSession.value = null;
  }
}
