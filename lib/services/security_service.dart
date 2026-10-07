import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../config/constants.dart';

class SecurityService {
  /// Generate HMAC-SHA256 Signature for Handshake verification
  static String generateSignature(int timestamp) {
    final message = '$timestamp:${AppConstants.saltKey}';
    final key = utf8.encode(AppConstants.masterSecret);
    final bytes = utf8.encode(message);
    
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  /// Generate Headers with security tokens
  static Map<String, String> getSecurityHeaders() {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final token = generateSignature(timestamp);
    
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-CBT-Time': timestamp.toString(),
      'X-CBT-Token': token,
      'X-CBT-Client': 'LufyaProctor-Desktop-Win-v1.0',
    };
  }
}
