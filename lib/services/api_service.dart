import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/server_info.dart';
import '../models/user_model.dart';
import 'security_service.dart';
import 'storage_service.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? code;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.code,
  });
}

class ApiService {
  /// Normalize user input URL
  static String normalizeUrl(String input) {
    var url = input.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Sync and Validate Lufya CBT Server
  static Future<ApiResponse<ServerInfo>> syncServer(String inputUrl) async {
    final cleanUrl = normalizeUrl(inputUrl);
    final headers = SecurityService.getSecurityHeaders();

    // List of candidate endpoint paths to probe
    final probePaths = [
      '/api/panel/sync.php',
      '/lufyacbt/api/panel/sync.php',
      '/cbt/api/panel/sync.php',
    ];

    String? successfulEndpoint;
    http.Response? response;
    Exception? lastException;

    for (final path in probePaths) {
      try {
        final targetUri = Uri.parse('$cleanUrl$path');
        final res = await http.get(targetUri, headers: headers).timeout(
          const Duration(seconds: 8),
        );

        if (res.statusCode == 200 || res.statusCode == 403 || res.statusCode == 400) {
          response = res;
          successfulEndpoint = cleanUrl + path.substring(0, path.lastIndexOf('/api/panel/sync.php'));
          break;
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
      }
    }

    if (response == null) {
      return ApiResponse(
        success: false,
        message: 'Gagal menghubungi server. Pastikan IP/URL benar dan server CBT sedang aktif.\n(${lastException?.toString() ?? "Koneksi Timeout"})',
      );
    }

    try {
      final jsonBody = jsonDecode(response.body);
      
      if (response.statusCode == 200 && (jsonBody['status'] == 'success' || jsonBody['handshake'] == true)) {
        final serverInfo = ServerInfo.fromJson(jsonBody);
        
        // Save to storage
        final resolvedBaseUrl = successfulEndpoint ?? serverInfo.baseUrl;
        await StorageService.saveServerUrl(resolvedBaseUrl);
        await StorageService.saveServerInfo(serverInfo);
        
        return ApiResponse(
          success: true,
          message: jsonBody['message'] ?? 'Sinkronisasi berhasil',
          data: serverInfo,
        );
      } else {
        final errorMsg = jsonBody['message'] ?? 'Server menolak koneksi panel.';
        return ApiResponse(
          success: false,
          message: 'Verifikasi Gagal: $errorMsg\n(Pastikan URL adalah server resmi Lufya CBT).',
          code: jsonBody['code']?.toString(),
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Respon server tidak valid atau bukan sistem Lufya CBT.',
      );
    }
  }

  /// Proctor Login Request
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
    String? tenant,
  }) async {
    final serverInfo = await StorageService.getServerInfo();
    final serverUrl = await StorageService.getServerUrl();

    if (serverUrl == null || serverUrl.isEmpty) {
      return ApiResponse(
        success: false,
        message: 'URL Server belum dikonfigurasi. Silakan sinkronkan server terlebih dahulu.',
      );
    }

    final loginEndpoint = (serverInfo != null && serverInfo.apiLoginUrl.isNotEmpty)
        ? serverInfo.apiLoginUrl
        : '$serverUrl/api/auth/login.php';

    try {
      final headers = SecurityService.getSecurityHeaders();
      final body = jsonEncode({
        'username': username.trim(),
        'password': password.trim(),
        'role': 'proktor', // allow proktor, admin, operator
        'tenant': tenant?.trim(),
      });

      final res = await http.post(
        Uri.parse(loginEndpoint),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      final jsonBody = jsonDecode(res.body);

      if (res.statusCode == 200 && jsonBody['status'] == 'success') {
        final userData = jsonBody['data']?['user'] ?? jsonBody['user'];
        final redirectUrl = jsonBody['data']?['redirect'] ?? jsonBody['redirect'] ?? '$serverUrl/admin';
        
        await StorageService.saveLastUsername(username);

        return ApiResponse(
          success: true,
          message: jsonBody['message'] ?? 'Login berhasil',
          data: {
            'user': userData != null ? UserModel.fromJson(userData) : null,
            'redirect': redirectUrl,
          },
        );
      } else {
        return ApiResponse(
          success: false,
          message: jsonBody['message'] ?? 'ID Proktor atau Password salah.',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal melakukan login. Periksa koneksi ke server CBT.',
      );
    }
  }
}
