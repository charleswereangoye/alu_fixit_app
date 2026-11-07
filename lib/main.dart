import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (safely caught if google-services.json not yet linked)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  runApp(const ALUFixItApp());
}

// Root application widget
class ALUFixItApp extends StatelessWidget {
  const ALUFixItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthState()),
      ],
      child: MaterialApp(
        title: 'ALU FixIt',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

// Handles switching between Login and Main screens based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // If authenticated, show placeholder until Step 2 is added
    if (authProvider.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: AppBar(
          title: const Text('ALU FixIt'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authProvider.signOut(),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.primary,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, ${authProvider.currentUser?.name}!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: ${authProvider.currentUser?.role.toUpperCase()} • ${authProvider.currentUser?.department}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => authProvider.signOut(),
                  child: const Text('Log Out'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default to login screen
    return const LoginScreen();
  }
}
