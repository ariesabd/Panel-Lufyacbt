import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../config/app_theme.dart';
import '../models/server_info.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class ServerSetupScreen extends StatefulWidget {
  final String? initialUrl;
  final String? autoErrorMessage;

  const ServerSetupScreen({
    super.key,
    this.initialUrl,
    this.autoErrorMessage,
  });

  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends State<ServerSetupScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  ServerInfo? _syncedInfo;

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.initialUrl ?? 'http://localhost/lufyacbt';
    _errorMessage = widget.autoErrorMessage;
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    if (widget.initialUrl == null) {
      final saved = await StorageService.getServerUrl();
      if (saved != null && saved.isNotEmpty && mounted) {
        setState(() {
          _urlController.text = saved;
        });
      }
    }
  }

  Future<void> _doSync() async {
    final input = _urlController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Silakan masukkan URL Server CBT terlebih dahulu.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _syncedInfo = null;
    });

    final res = await ApiService.syncServer(input);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res.success && res.data != null) {
        _syncedInfo = res.data;
        _errorMessage = null;
      } else {
        _errorMessage = res.message;
      }
    });
  }

  void _proceedToLogin() {
    if (_syncedInfo != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(serverInfo: _syncedInfo!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with 1:1 Transparent Logo
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konfigurasi Server CBT',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMain,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Hubungkan panel proktor ke server Lufya CBT',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // URL Input Label
                const Text(
                  'URL / Alamat IP Server CBT :',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                ),
                const SizedBox(height: 8),

                // Clean TextField (Without example chips below)
                TextField(
                  controller: _urlController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Contoh: http://192.168.1.100/lufyacbt',
                    prefixIcon: const Icon(Icons.link_rounded, size: 20, color: AppTheme.textLight),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: AppTheme.textLight),
                      onPressed: () => _urlController.clear(),
                    ),
                  ),
                  onSubmitted: (_) => _doSync(),
                ),
                const SizedBox(height: 20),

                // Error Notification Box
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Synced Server Card Box
                if (_syncedInfo != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Server Lufya CBT Terhubung!',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: Color(0xFFDCFCE7)),
                        _buildInfoRow('Nama Aplikasi', _syncedInfo!.appName),
                        _buildInfoRow('Nama Lembaga', _syncedInfo!.schoolName),
                        _buildInfoRow('Kode Tenant', _syncedInfo!.tenantCode),
                        _buildInfoRow('Versi Server', _syncedInfo!.serverVersion),
                        _buildInfoRow('Alamat Valid', _syncedInfo!.baseUrl),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Buttons
                if (_syncedInfo == null)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _doSync,
                    icon: _isLoading
                        ? const SpinKitRing(color: Colors.white, size: 18, lineWidth: 2)
                        : const Icon(Icons.sync_rounded, size: 20),
                    label: Text(_isLoading ? 'Menghubungkan Server...' : 'Tes Koneksi & Sinkronkan Data'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _doSync,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Sinkron Ulang'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: AppTheme.textMuted,
                            side: const BorderSide(color: AppTheme.border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _proceedToLogin,
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text('Lanjut Ke Halaman Login'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label :',
              style: const TextStyle(fontSize: 11, color: Color(0xFF15803D)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF14532D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
