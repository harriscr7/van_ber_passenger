import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:van_ber_passenger/core/theme/colors.dart';
import 'package:van_ber_passenger/core/utils/navigation_helper.dart';
import 'package:van_ber_passenger/features/on_boarding/account_login_select_screen.dart';
import 'package:van_ber_passenger/features/on_boarding/on_boarding_screen_one.dart';
import 'package:van_ber_passenger/features/splash/splash_controller.dart';

class OnBoardingScreenThree extends StatefulWidget {
  const OnBoardingScreenThree({super.key});

  @override
  State<OnBoardingScreenThree> createState() => _OnBoardingScreenThreeState();
}

class _OnBoardingScreenThreeState extends State<OnBoardingScreenThree> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 13.h, 16.w, 13.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Your existing logo and texts container
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/on_boarding_screen_three_logo.png",
                          width: 280.w,
                          height: 280.h,
                        ),
                        SizedBox(height: 40.h),
                        Text(
                          "Pay Seamlessly, Ride Easily",
                          style: TextStyle(
                            fontSize: 16.h,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Skip the cash — pay easily through Apple Pay, Samsung Pay, or your preferred method.",
                          style: TextStyle(
                            fontSize: 12.h,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        SvgPicture.asset(
                          "assets/icons/on_boarding_screen_three_dots.svg",
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
                        AppNavigator.pushReplacement(
                          context,
                          const AccountLoginSelectScreen(),
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
                          const OnBoardingScreenOne(),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Start Again",
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
              top: 13.h,
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
