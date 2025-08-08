import 'dart:async';
import 'package:flutter/material.dart';
import 'package:van_ber_passenger/core/utils/navigation_helper.dart';
import 'package:van_ber_passenger/home_screen.dart';

class SplashController {
  final BuildContext context;

  SplashController(this.context);

  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 3));

    // Example checks:
    bool isLoggedIn = await _checkLoginStatus();
    bool showOnboarding = await _checkOnboardingStatus();

    if (showOnboarding) {
      AppNavigator.push(context, const OnboardingScreen());
    } else if (isLoggedIn) {
      AppNavigator.push(context, const HomeScreen());
    } else {
      AppNavigator.push(context, const LoginScreen());
    }
  }

  Future<bool> _checkLoginStatus() async {
    // Example: check shared preferences or secure storage
    return true;
  }

  Future<bool> _checkOnboardingStatus() async {
    // Example: check if first time user
    return false;
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
