import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:van_ber_passenger/core/theme/colors.dart';
import 'package:van_ber_passenger/core/utils/navigation_helper.dart';
import 'package:van_ber_passenger/features/auth/account_login_select_screen.dart';
import 'package:van_ber_passenger/features/on_boarding/on_boarding_screen_three.dart';

class OnBoardingScreenTwo extends StatefulWidget {
  const OnBoardingScreenTwo({super.key});

  @override
  State<OnBoardingScreenTwo> createState() => _OnBoardingScreenTwoState();
}

class _OnBoardingScreenTwoState extends State<OnBoardingScreenTwo> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Your existing logo and texts container
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/on_boarding_screen_two_logo.png",
                          width: 280.w,
                          height: 280.h,
                        ),
                        SizedBox(height: 40.h),
                        Text(
                          "Smart Routes, Real-Time Updates",
                          style: TextStyle(
                            fontSize: 16.h,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Get real-time arrival updates, smart drop-off suggestions, and driver info for a safer trip.",
                          style: TextStyle(
                            fontSize: 12.h,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        SvgPicture.asset(
                          "assets/icons/on_boarding_screen_two_dots.svg",
                          width: 40.w,
                          height: 6.h,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60.h),
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () {
                        AppNavigator.push(
                          context,
                          const OnBoardingScreenThree(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 16.h,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: OutlinedButton(
                      onPressed: () {
                        AppNavigator.pushReplacement(
                          context,
                          const AccountLoginSelectScreen(),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 14.h,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Back button at top-left
            Positioned(
              top: 16.h,
              left: 16.w,
              child: SizedBox(
                height: 44.h,
                width: 44.w,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.black.withOpacity(
                          0.1,
                        ), // Keep semi-transparent background if you want
                        width: 1, // Border thickness
                      ),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/back_arrow.svg",
                      width: 28.w,
                      height: 28.h,
                      color: AppColors.black, // icon color
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
