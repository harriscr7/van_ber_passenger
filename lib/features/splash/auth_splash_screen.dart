import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:van_ber_passenger/core/theme/colors.dart';
import 'package:van_ber_passenger/core/utils/navigation_helper.dart';
import 'package:van_ber_passenger/features/auth/account_login_select_screen.dart';
import 'package:van_ber_passenger/home_screen.dart';

class AuthSplashScreen extends StatefulWidget {
  const AuthSplashScreen({super.key});

  @override
  State<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends State<AuthSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for minimum splash duration for better UX
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check current authentication state
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is signed in, navigate to home
      AppNavigator.pushReplacement(context, const HomeScreen());
    } else {
      // User is not signed in, navigate to login
      AppNavigator.pushReplacement(context, const AccountLoginSelectScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            SvgPicture.asset(
              "assets/icons/splash_screen_logo.svg",
              width: 120.w,
              height: 120.h,
            ),
            SizedBox(height: 24.h),

            // App name
            Text(
              "Van-ber",
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 8.h),

            // Tagline
            Text(
              "Your ride, your way",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }
}
