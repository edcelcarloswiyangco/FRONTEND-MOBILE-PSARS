import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'widgets/auth_widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = kAuthGreen;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'STRAYCONNECT',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: kAuthBackground,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: seedColor),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF08181A),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isBootstrapping = true;
  bool _showRegister = false;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final storedBaseUrl = await ApiConfig.loadBaseUrl();

    if (!mounted) {
      return;
    }

    setState(() {
      _authService = AuthService(
        apiService: ApiService(baseUrl: storedBaseUrl),
      );
    });

    await _authService.restoreSession();
    if (!mounted) {
      return;
    }

    setState(() {
      _isBootstrapping = false;
    });
  }

  Future<void> _handleAuthenticated() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _showRegister = false;
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }
    setState(() {
      _showRegister = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isBootstrapping) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentUser = _authService.currentUser;

    if (currentUser != null) {
      return HomeScreen(
        user: currentUser,
        authService: _authService,
        onLogout: _handleLogout,
      );
    }

    if (_showRegister) {
      return RegisterScreen(
        authService: _authService,
        onSwitchToLogin: () => setState(() {
          _showRegister = false;
        }),
      );
    }

    return LoginScreen(
      authService: _authService,
      onSwitchToRegister: () => setState(() {
        _showRegister = true;
      }),
      onAuthenticated: _handleAuthenticated,
    );
  }
}
