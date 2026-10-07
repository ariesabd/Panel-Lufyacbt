import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';
import '../config/app_theme.dart';
import '../models/server_info.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ServerInfo serverInfo;
  final String targetUrl;
  final String username;

  const DashboardScreen({
    super.key,
    required this.serverInfo,
    required this.targetUrl,
    required this.username,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _controller = WebviewController();
  bool _isInitialized = false;
  bool _isLoading = true;
  String _pageTitle = 'Memuat Panel Proktor...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebview();
  }

  Future<void> _initWebview() async {
    if (!Platform.isWindows) {
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
      return;
    }

    try {
      await _controller.initialize();
      
      _controller.url.listen((url) {
        // Track current page
      });

      _controller.title.listen((title) {
        if (mounted) {
          setState(() {
            _pageTitle = title.isNotEmpty ? title : widget.serverInfo.appName;
          });
        }
      });

      _controller.loadingState.listen((state) {
        if (mounted) {
          setState(() {
            _isLoading = (state == LoadingState.loading);
          });
        }
      });

      await _controller.loadUrl(widget.targetUrl);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal menginisialisasi WebView2: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openInExternalBrowser() async {
    final uri = Uri.parse(widget.targetUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Panel?'),
        content: const Text('Apakah Anda yakin ingin keluar dan kembali ke layar login?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(serverInfo: widget.serverInfo),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                border: Border(bottom: BorderSide(color: Color(0xFF334155))),
              ),
              child: Row(
                children: [
                  // App Title & School Name
                  const Icon(Icons.school_rounded, color: Color(0xFF38BDF8), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.serverInfo.appName} • ${widget.serverInfo.schoolName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Browser Controls
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 18),
                    tooltip: 'Kembali',
                    onPressed: () => _controller.goBack(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 18),
                    tooltip: 'Maju',
                    onPressed: () => _controller.goForward(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 18),
                    tooltip: 'Muat Ulang',
                    onPressed: () => _controller.reload(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.home_rounded, color: Colors.white70, size: 18),
                    tooltip: 'Dashboard Utama',
                    onPressed: () => _controller.loadUrl(widget.targetUrl),
                  ),

                  const Spacer(),

                  // Proctor Username Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_rounded, size: 14, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 6),
                        Text(
                          widget.username,
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Open External Browser button
                  IconButton(
                    icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white70, size: 20),
                    tooltip: 'Buka di Browser Luar (Chrome/Edge)',
                    onPressed: _openInExternalBrowser,
                  ),

                  // Logout button
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFF87171), size: 20),
                    tooltip: 'Keluar ke Login',
                    onPressed: _logout,
                  ),
                ],
              ),
            ),

            // Webview Viewport
            Expanded(
              child: Stack(
                children: [
                  if (_isInitialized && _errorMessage == null)
                    Webview(
                      _controller,
                      permissionRequested: _onPermissionRequested,
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        constraints: const BoxConstraints(maxWidth: 500),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 48, color: AppTheme.danger),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textMain),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _openInExternalBrowser,
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('Buka di Browser Eksternal'),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Loading Overlay Bar
                  if (_isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    return WebviewPermissionDecision.allow;
  }
}
