class AppConstants {
  static const String appName = 'Panel LufyaCBT';
  static const String appVersion = '1.0.0';
  static const String defaultTenant = 'SERVER-01';
  
  // Security Handshake Keys (Identical to Lufya CBT PHP Backend)
  static const String masterSecret = 'lufya_cbt_panel_master_secret_2026_x89a';
  static const String saltKey = 'lufya_panel_proctor_salt_2026';
  
  // Storage Keys
  static const String keyServerUrl = 'lufya_server_url';
  static const String keyServerData = 'lufya_server_data';
  static const String keyLastUsername = 'lufya_last_username';
  static const String keyRememberMe = 'lufya_remember_me';
  static const String keyUserSession = 'lufya_user_session';
}
