import 'dart:async';
import 'dart:convert';

import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final TokenStorage tokenStorage;
  ApiClient(this.tokenStorage);

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, String>> _headers(bool auth, {bool json = true}) async {
    final headers = <String, String>{};
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    if (auth) {
      final token = await tokenStorage.read();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {bool auth = true}) async {
    try {
      final res = await http
          .get(_uri(path), headers: await _headers(auth))
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException("Cannot reach the server");
    }
  }

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final res = await http
          .post(
            _uri(path),
            headers: await _headers(auth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));
      return _handle(res);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Request timed out while waiting for server');
    } catch (_) {
      throw ApiException('Cannot reach the server (check if backend is running on port 8080)');
    }
  }

  Future<dynamic> patch(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final res = await http
          .patch(
            _uri(path),
            headers: await _headers(auth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Cannot reach the server');
    }
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    try {
      final res = await http
          .delete(_uri(path), headers: await _headers(auth))
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Cannot reach the server');
    }
  }

  Future<dynamic> postMultipart(
    String path, {
    required String filePath,
    required Map<String, String> fields,
    bool auth = true,
  }) async {
    try {
      final req = http.MultipartRequest('POST', _uri(path));
      req.headers.addAll(await _headers(auth, json: false));
      req.fields.addAll(fields);
      req.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamed = await req.send().timeout(const Duration(seconds: 90));
      final res = await http.Response.fromStream(streamed);
      return _handle(res);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Upload timed out');
    } catch (_) {
      throw ApiException('Cannot reach the server (check if backend is running on port 8080)');
    }
  }

  Future<List<int>> getBytes(String path, {bool auth = true}) async {
    try {
      final res = await http
          .get(_uri(path), headers: await _headers(auth, json: false))
          .timeout(const Duration(seconds: 60));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return res.bodyBytes;
      }
      _handle(res);
      return const [];
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Cannot reach the server');
    }
  }

  dynamic _handle(http.Response res) {
    final text = utf8.decode(res.bodyBytes);
    dynamic data;
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text);
      } catch (_) {
        data = null;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return data;

    String message = 'Something went wrong (${res.statusCode})';
    if (data is Map) {
      final errs = data['errors'];
      if (errs is List && errs.isNotEmpty) {
        message = errs
            .map((e) => e is Map ? e['defaultMessage'] : null)
            .whereType<String>()
            .join('\n');
      } else if (data['message'] is String &&
          (data['message'] as String).isNotEmpty) {
        message = data['message'] as String;
      } else if (data['error'] is String &&
          (data['error'] as String).isNotEmpty) {
        message = data['error'] as String;
      }
    }
    throw ApiException(message);
  }
}
