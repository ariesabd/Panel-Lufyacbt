import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/server_info.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> saveServerUrl(String url) async {
    await init();
    await _prefs?.setString(AppConstants.keyServerUrl, url.trim());
  }

  static Future<String?> getServerUrl() async {
    await init();
    return _prefs?.getString(AppConstants.keyServerUrl);
  }

  static Future<void> saveServerInfo(ServerInfo info) async {
    await init();
    final jsonStr = jsonEncode(info.toJson());
    await _prefs?.setString(AppConstants.keyServerData, jsonStr);
  }

  static Future<ServerInfo?> getServerInfo() async {
    await init();
    final jsonStr = _prefs?.getString(AppConstants.keyServerData);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr);
      return ServerInfo.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveLastUsername(String username) async {
    await init();
    await _prefs?.setString(AppConstants.keyLastUsername, username);
  }

  static Future<String> getLastUsername() async {
    await init();
    return _prefs?.getString(AppConstants.keyLastUsername) ?? '';
  }

  static Future<void> clearAll() async {
    await init();
    await _prefs?.clear();
  }
}
