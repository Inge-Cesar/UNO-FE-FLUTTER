import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../di/injection_container.dart';
import '../session/session_manager.dart';

/// Provee un http.Client real que puede añadir automáticamente el token de autenticación.
http.Client provideHttpClient() => AuthHttpClient(http.Client(), sl<SessionManager>());

/// Un cliente HTTP que envuelve a otro cliente para añadir el header de autorización
/// a todas las peticiones salientes, si hay una sesión activa.
class AuthHttpClient extends http.BaseClient {
  final http.Client _inner;
  final SessionManager _sessionManager;

  AuthHttpClient(this._inner, this._sessionManager);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final token = _sessionManager.currentSession.value?.token;

    final isLoginRequest = _isLoginMutation(request);

    if (token != null && token.isNotEmpty && !isLoginRequest) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _inner.send(request);
  }

  /// Revisa si el cuerpo de la petición contiene la mutación de login.
  bool _isLoginMutation(http.BaseRequest request) {
    if (request is http.Request && request.body.isNotEmpty) {
      try {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final query = body['query'] as String?;
        if (query != null && query.contains('mutation') && query.contains('login')) {
          return true;
        }
      } catch (e) {
        // No es una petición GraphQL de login si el cuerpo no es un JSON válido.
        return false;
      }
    }
    return false;
  }

  @override
  void close() {
    _inner.close();
  }
}
