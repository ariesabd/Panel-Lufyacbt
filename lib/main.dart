import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'config/constants.dart';
import 'services/storage_service.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const PanelLufyaCbtApp());
}

class PanelLufyaCbtApp extends StatelessWidget {
  const PanelLufyaCbtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
