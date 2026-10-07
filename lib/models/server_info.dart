class ServerInfo {
  final bool handshake;
  final String serverSignature;
  final String serverVersion;
  final String serverTime;
  final String appName;
  final String schoolName;
  final String subTitle;
  final String logoUrl;
  final String theme;
  final String tenantCode;
  final String baseUrl;
  final String adminUrl;
  final String loginUrl;
  final String apiLoginUrl;
  final String ssoUrl;

  ServerInfo({
    required this.handshake,
    required this.serverSignature,
    required this.serverVersion,
    required this.serverTime,
    required this.appName,
    required this.schoolName,
    required this.subTitle,
    required this.logoUrl,
    required this.theme,
    required this.tenantCode,
    required this.baseUrl,
    required this.adminUrl,
    required this.loginUrl,
    required this.apiLoginUrl,
    required this.ssoUrl,
  });

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>) ? json['data'] : json;
    
    return ServerInfo(
      handshake: data['handshake'] ?? false,
      serverSignature: data['server_signature'] ?? '',
      serverVersion: data['server_version'] ?? '1.0.0',
      serverTime: data['server_time'] ?? '',
      appName: data['app_name'] ?? 'LUFYA CBT',
      schoolName: data['school_name'] ?? 'Pusat Asesmen CBT',
      subTitle: data['sub_title'] ?? 'Selamat Datang Di CBT Proktor',
      logoUrl: data['logo_url'] ?? '',
      theme: data['theme'] ?? 'ocean-blue',
      tenantCode: data['tenant_code'] ?? 'SERVER-01',
      baseUrl: data['base_url'] ?? '',
      adminUrl: data['admin_url'] ?? '',
      loginUrl: data['login_url'] ?? '',
      apiLoginUrl: data['api_login_url'] ?? '',
      ssoUrl: data['sso_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'handshake': handshake,
      'server_signature': serverSignature,
      'server_version': serverVersion,
      'server_time': serverTime,
      'app_name': appName,
      'school_name': schoolName,
      'sub_title': subTitle,
      'logo_url': logoUrl,
      'theme': theme,
      'tenant_code': tenantCode,
      'base_url': baseUrl,
      'admin_url': adminUrl,
      'login_url': loginUrl,
      'api_login_url': apiLoginUrl,
      'sso_url': ssoUrl,
    };
  }
}
