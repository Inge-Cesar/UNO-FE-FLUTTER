import 'package:flutter/foundation.dart';

class Session {
  final String userId;
  final String token;
  final String userName;
  final String email;
  final String userRole;

  const Session({
    required this.userId, 
    required this.token, 
    required this.userName, 
    required this.email,
    required this.userRole,
  });
}

class SessionManager {
  final ValueNotifier<Session?> currentSession = ValueNotifier<Session?>(null);

  void setSession(Session session) {
    if (kDebugMode) print('DEBUG SESSION: Guardando sesión para usuario: ${session.userName} (ID: ${session.userId})');
    currentSession.value = session;
    if (kDebugMode) print('DEBUG SESSION: Sesión guardada exitosamente');
  }

  void clear() {
    currentSession.value = null;
  }
}
