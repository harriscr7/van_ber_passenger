import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:van_ber_passenger/core/theme/colors.dart';
import 'package:van_ber_passenger/features/on_boarding/on_boarding_screen_one.dart';
import 'package:van_ber_passenger/features/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Passenger App',
          theme: ThemeData(
            scaffoldBackgroundColor:
                AppColors.white, // default background white
            primaryColor: AppColors.red,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red, // red buttons
                foregroundColor: AppColors.white, // white text
                textStyle: GoogleFonts.poppins(
                  fontSize: 16.h,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: AppColors.red,
            ),
          ),
          home: const OnBoardingScreenOne(),
        );
      },
    );
  }
}
