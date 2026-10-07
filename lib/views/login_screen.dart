import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../config/app_theme.dart';
import '../models/server_info.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'dashboard_screen.dart';
import 'server_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  final ServerInfo serverInfo;

  const LoginScreen({
    super.key,
    required this.serverInfo,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tenantController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tenantController.text = widget.serverInfo.tenantCode;
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    final lastUser = await StorageService.getLastUsername();
    if (lastUser.isNotEmpty && mounted) {
      setState(() {
        _usernameController.text = lastUser;
      });
    }
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'ID Proktor dan Password wajib diisi.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await ApiService.login(
      username: username,
      password: password,
      tenant: _tenantController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res.success) {
      final redirectUrl = res.data?['redirect'] as String? ?? widget.serverInfo.adminUrl;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            serverInfo: widget.serverInfo,
            targetUrl: redirectUrl,
            username: username,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = res.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopWidth = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Decorative Shapes (Left Bottom - as in ANBK reference)
          Positioned(
            left: -80,
            bottom: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF60A5FA).withOpacity(0.35),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            left: -120,
            bottom: -20,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.85),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          
          // Background Network Grid / Nodes Effect
          Positioned.fill(
            child: CustomPaint(
              painter: _NetworkGridPainter(),
            ),
          ),

          // Main Responsive Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar: Server Status & Change Server URL button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Connected
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Server: ${widget.serverInfo.appName} (${widget.serverInfo.schoolName})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Settings / Change URL Button
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServerSetupScreen(
                                initialUrl: widget.serverInfo.baseUrl,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined, size: 16, color: AppTheme.textMuted),
                        label: const Text(
                          'Ganti URL Server',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),

                // Center Body (2 Column Layout on Desktop)
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      child: isDesktopWidth ? _buildDesktopLayout() : _buildMobileLayout(),
                    ),
                  ),
                ),

                // Bottom Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Panel LufyaCBT v${widget.serverInfo.serverVersion} • Desktop Proktor Edition',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Branding (ANBK / CBT Title)
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 48, left: 24),
            child: _buildBrandingSection(),
          ),
        ),

        // Right Column: Sign In Floating Card
        Expanded(
          flex: 4,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _buildSignInCard(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildBrandingSection(),
        const SizedBox(height: 28),
        Container(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _buildSignInCard(),
        ),
      ],
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo & Tag
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic Logo if available, else standard icon
            if (widget.serverInfo.logoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.serverInfo.logoUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildDefaultLogoBadge(),
                ),
              )
            else
              _buildDefaultLogoBadge(),
            const SizedBox(width: 14),
            Text(
              widget.serverInfo.appName.isNotEmpty ? widget.serverInfo.appName : 'ANBK',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.textMain,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Title
        Text(
          widget.serverInfo.subTitle.isNotEmpty
              ? widget.serverInfo.subTitle
              : 'Selamat Datang Di\nCBT Proktor',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),

        // School/Institution Name
        Text(
          widget.serverInfo.schoolName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLogoBadge() {
    return Image.asset(
      'assets/images/logo.png',
      width: 48,
      height: 48,
      fit: BoxFit.contain,
    );
  }

  Widget _buildSignInCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          const Text(
            'Sign In',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Masukan ID Proktor & password anda!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Error box
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppTheme.danger),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ID Proktor Field
          const Text(
            'ID Proktor',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _usernameController,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              hintText: 'Masukkan ID Proktor',
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),

          // Password Field
          const Text(
            'Password',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            decoration: InputDecoration(
              hintText: 'Masukkan password',
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppTheme.textLight,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            onSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 16),

          // Tenant Field
          Row(
            children: [
              const Text(
                'Tenant : ',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.serverInfo.tenantCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sign-In Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A2FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SpinKitRing(color: Colors.white, size: 18, lineWidth: 2)
                : const Text(
                    'Sign-In',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Custom Background Network Lines Painter (Subtle dotted/mesh lines)
class _NetworkGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0).withOpacity(0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF93C5FD).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw some subtle decorative connected dots at bottom right
    final points = [
      Offset(size.width * 0.45, size.height * 0.75),
      Offset(size.width * 0.55, size.height * 0.82),
      Offset(size.width * 0.65, size.height * 0.70),
      Offset(size.width * 0.75, size.height * 0.85),
      Offset(size.width * 0.85, size.height * 0.76),
      Offset(size.width * 0.95, size.height * 0.88),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    for (final p in points) {
      canvas.drawCircle(p, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
