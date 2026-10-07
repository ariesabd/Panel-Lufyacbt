import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import 'server_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusText = 'Memeriksa konfigurasi server...';

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final savedUrl = await StorageService.getServerUrl();
    if (savedUrl == null || savedUrl.isEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ServerSetupScreen()),
        );
      }
      return;
    }

    setState(() {
      _statusText = 'Menghubungkan ke $savedUrl...';
    });

    final res = await ApiService.syncServer(savedUrl);
    if (!mounted) return;

    if (res.success && res.data != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(serverInfo: res.data!),
        ),
      );
    } else {
      // Server not reachable or invalid signature, let proktor configure/retry
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ServerSetupScreen(
            initialUrl: savedUrl,
            autoErrorMessage: res.message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1:1 Perfectly Centered Transparent Logo
            SizedBox(
              width: 110,
              height: 110,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'LUFYA CBT PROKTOR',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aplikasi Desktop Pengawas & Proktor Ujian',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 36),
            const SpinKitThreeBounce(
              color: AppTheme.primary,
              size: 24,
            ),
            const SizedBox(height: 16),
            Text(
              _statusText,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
