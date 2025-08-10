import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:van_ber_passenger/core/theme/colors.dart';
import 'package:van_ber_passenger/core/utils/navigation_helper.dart';
import 'package:van_ber_passenger/features/auth/firebase_auth.dart';
import 'package:van_ber_passenger/features/auth/phone_auth_page.dart';

class AccountLoginSelectScreen extends StatefulWidget {
  const AccountLoginSelectScreen({super.key});

  @override
  State<AccountLoginSelectScreen> createState() =>
      _AccountLoginSelectScreenState();
}

class _AccountLoginSelectScreenState extends State<AccountLoginSelectScreen> {
  final FirebaseAuthService _authService =
      FirebaseAuthService(); // create instance
  void _openCustomerSupport() {
    // TODO: Replace with real support page navigation
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Customer Support"),
        content: const Text("This is a placeholder for the support page."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Logo and Texts
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/van_ber_icon_red.png",
                      width: 80.w,
                      height: 80.h,
                    ),

                    SizedBox(height: 40.h),
                    Text(
                      "Welcome to Van-ber",
                      style: TextStyle(
                        fontSize: 20.h,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 6.h),

                    Text(
                      "Log in with your phone number or Google account to start your Van-ber journey.",
                      style: TextStyle(
                        fontSize: 12.h,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // Continue with Number button
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: () {
                    AppNavigator.push(context, const PhoneAuthPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/phone_icon.svg", // Replace with your phone icon svg
                        width: 20.w,
                        height: 20.h,
                        color: AppColors.white,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Continue with Number",
                            style: TextStyle(
                              fontSize: 14.h,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Continue with Google button inside bordered container
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.darkGray, width: 0.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                width: double.infinity,
                height: 44.h,
                child: OutlinedButton(
                  onPressed: () async {
                    final user = await _authService.signInWithGoogle();
                    if (user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Signed in as ${user.displayName}"),
                        ),
                      );
                      // AuthWrapper will handle navigation based on profile completion
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Google Sign-In failed")),
                      );
                    }
                  },

                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    side: BorderSide.none, // border handled by container
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/google_icon.svg", // Replace with your Google icon svg
                        width: 20.w,
                        height: 20.h,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Continue with Google",
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

              SizedBox(height: 56.h),

              // Bottom help text with clickable "Customer Support"
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12.h,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                  children: [
                    const TextSpan(text: "Need help? Contact our "),
                    TextSpan(
                      text: "Customer Support",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.red,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _openCustomerSupport,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),
            ],
          ),
        ),
      ),
    );
  }
}
