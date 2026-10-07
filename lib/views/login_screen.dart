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
  
  String _selectedRole = 'all';
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
      role: _selectedRole,
      tenant: _tenantController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res.success && res.data != null) {
      // Seamless Single Sign-On URL into WebView2 without 2x login
      final ssoBridgeUrl = res.data!['sso_bridge_url'] as String? 
          ?? res.data!['redirect'] as String? 
          ?? widget.serverInfo.adminUrl;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            serverInfo: widget.serverInfo,
            targetUrl: ssoBridgeUrl,
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
    final size = MediaQuery.of(context).size;
    final isDesktopWidth = size.width >= 880;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. High-Res 3D Fluid Wave Wallpaper Background (Inspired by Reference Image 2)
          Image.asset(
            'assets/images/bg_login.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE0F2FE), Color(0xFFF8FAFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 2. Soft Luminous Glass Overlay Tint
          Container(
            color: Colors.white.withOpacity(0.35),
          ),

          // 3. Main Responsive Content
          SafeArea(
            child: Column(
              children: [
                // Top Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Connected Server Pill (Glassmorphic)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
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

                      // Change URL Button (Glassmorphic)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                        ),
                        child: TextButton.icon(
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
                          icon: const Icon(Icons.settings_outlined, size: 15, color: Color(0xFF475569)),
                          label: const Text(
                            'Ganti URL Server',
                            style: TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Center Main Content Area
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                      child: isDesktopWidth ? _buildDesktopLayout() : _buildMobileLayout(),
                    ),
                  ),
                ),

                // Bottom Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Panel LufyaCBT v${widget.serverInfo.serverVersion} • Desktop Proktor & Pengawas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155).withOpacity(0.8),
                    ),
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
        // Left Column: Branding Section
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 48, left: 32),
            child: _buildBrandingSection(),
          ),
        ),

        // Right Column: Floating Sign-In Card
        Expanded(
          flex: 4,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
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
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildSignInCard(),
        ),
      ],
    );
  }

  Widget _buildBrandingSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1:1 Transparent Logo & App Name Header
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 52,
                height: 52,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),
              Text(
                widget.serverInfo.appName.isNotEmpty ? widget.serverInfo.appName : 'LUFYA CBT',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.serverInfo.subTitle.isNotEmpty
                ? widget.serverInfo.subTitle
                : 'Selamat Datang Di CBT Proktor',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),

          // School/Institution Name
          Text(
            widget.serverInfo.schoolName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0284C7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card Header
          const Text(
            'Sign In',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Masukan ID Proktor & password anda!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          // Error Notification Box
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
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

          // Hak Akses Dropdown (Admin / Pengawas / Guru)
          const Text(
            'Hak Akses Masuk',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Otomatis (Sesuai Akun)', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: 'admin', child: Text('Administrator', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: 'pengawas', child: Text('Pengawas / Proktor', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: 'guru', child: Text('Guru / Pendidik', style: TextStyle(fontSize: 13))),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedRole = val;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Tenant Field
          Row(
            children: [
              const Text(
                'Tenant : ',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.serverInfo.tenantCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
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
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
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
