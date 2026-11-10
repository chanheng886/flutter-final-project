import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/features/auth/models/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  final TokenStorage _storage;

  AuthProvider(this._api, this._storage);

  AuthStatus status = AuthStatus.unknown;
  User? user;
  bool loading = false;
  String? error;

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(payload);
      return map is Map<String, dynamic> ? map : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> tryAutoLogin() async {
    try {
      final token = await _storage.read().timeout(const Duration(seconds: 3));
      if (token == null || token.isEmpty) {
        status = AuthStatus.unauthenticated;
      } else {
        final claims = _decodeJwtPayload(token);
        final exp = (claims?['exp'] as num?)?.toInt();
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        if (claims == null || (exp != null && exp <= nowSec)) {
          await _storage.clear();
          user = null;
          status = AuthStatus.unauthenticated;
        } else {
          user ??= User(
            id: (claims['sub'] ?? '').toString(),
            email: (claims['email'] ?? '').toString(),
            username: claims['username']?.toString(),
            role: 'USER',
          );
          status = AuthStatus.authenticated;
        }
      }
    } catch (e) {
      debugPrint("Token read failed: $e");
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final res = await _api.post('/auth/login', {
        'identifier': identifier.trim(),
        'password': password,
      }, auth: false);
      await _storage.save(res['token'] as String);
      final userData = res['user'] ?? res['dto'] ?? res;
      if (userData is Map) {
        user = User.fromJson(Map<String, dynamic>.from(userData));
      }
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = 'Could not sign in: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    String? username,
    String? phone,
    required String password,
    required String confirm,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{
        'email': email.trim(),
        'passwordHash': password,
        'confirmedPassword': confirm,
      };

      if (username != null && username.trim().isNotEmpty) {
        body['username'] = username.trim();
      }

      if (phone != null && phone.trim().isNotEmpty) {
        body['phone'] = phone.trim();
      }

      final res = await _api.post('/auth/register', body, auth: false);
      await _storage.save(res['token'] as String);
      final userData = res['user'] ?? res['dto'] ?? res;
      if (userData is Map) {
        user = User.fromJson(Map<String, dynamic>.from(userData));
      }
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = "Could not complete sign up $e";
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logOut() async {
    await _storage.clear();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
