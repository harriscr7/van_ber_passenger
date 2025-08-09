import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:van_ber_passenger/core/theme/colors.dart';
import 'package:van_ber_passenger/core/utils/navigation_helper.dart';
import 'package:van_ber_passenger/features/on_boarding/account_login_select_screen.dart';
import 'package:van_ber_passenger/features/on_boarding/on_boarding_screen_two.dart'; // your colors

class OnBoardingScreenOne extends StatefulWidget {
  const OnBoardingScreenOne({super.key});

  @override
  State<OnBoardingScreenOne> createState() => _OnBoardingScreenOneState();
}

class _OnBoardingScreenOneState extends State<OnBoardingScreenOne> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 13.h, 16.w, 13.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Logo and Texts
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/on_boarding_screen_one_logo.png", // <-- PNG extension here
                      width: 280.w,
                      height: 186.h,
                    ),

                    SizedBox(height: 40.h),

                    Text(
                      "Book Your Minibus, Your Way",
                      style: TextStyle(
                        fontSize: 16.h,
                        fontWeight: FontWeight.w600, // SemiBold
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      "Pre-book your red minibus ride in advance and enjoy a smooth, stress-free commute.",
                      style: TextStyle(
                        fontSize: 12.h,
                        fontWeight: FontWeight.w400, // Regular
                        color: AppColors.darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    SvgPicture.asset(
                      "assets/icons/on_boarding_screen_one_dots.svg",
                      width: 40.w,
                      height: 6.h,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 60.h),

              // Buttons: Next & Skip
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: () {
                    AppNavigator.push(context, const OnBoardingScreenTwo());
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
      ),
    );
  }
}
