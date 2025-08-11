import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:van_ber_passenger/features/auth/account_login_select_screen.dart';
import 'package:van_ber_passenger/features/on_boarding/on_boarding_screen_one.dart';
import 'package:van_ber_passenger/features/profile/account_setup_page.dart';
import 'package:van_ber_passenger/home_screen.dart';
import 'package:van_ber_passenger/providers/user_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }

        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          final firebaseUser = snapshot.data!;
          debugPrint('🔐 Firebase user authenticated: ${firebaseUser.uid}');

          return Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              debugPrint(
                '👤 UserProvider state: ${userProvider.state}, user: ${userProvider.user?.id}',
              );

              // Initialize user from Firebase Auth if not already done
              // Check if user is null OR if the user ID doesn't match the current Firebase user
              if (userProvider.user == null ||
                  userProvider.user?.id != firebaseUser.uid) {
                debugPrint(
                  '🔄 Need to initialize user. Current user: ${userProvider.user?.id}, Firebase user: ${firebaseUser.uid}',
                );
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await userProvider.initializeFromFirebaseUser(firebaseUser);
                });
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.yellow),
                  ),
                );
              }

              // Show loading while initializing
              if (userProvider.isLoading) {
                debugPrint('⏳ UserProvider is loading...');
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                );
              }

              // Show error state if initialization failed
              if (userProvider.state == UserState.error) {
                debugPrint(
                  '❌ UserProvider error state: ${userProvider.errorMessage}',
                );
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${userProvider.errorMessage}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => userProvider.clearError(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Check if profile is complete (only show account setup for new users)
              if (userProvider.state == UserState.profileIncomplete) {
                debugPrint('📝 Navigating to AccountSetupPage');
                return const AccountSetupPage();
              }

              // Show home screen if profile is complete
              debugPrint('🏠 Navigating to HomeScreen');
              return const HomeScreen();
            },
          );
        }

        // If user is not logged in, show login screen
        return const OnBoardingScreenOne();
      },
    );
  }
}
