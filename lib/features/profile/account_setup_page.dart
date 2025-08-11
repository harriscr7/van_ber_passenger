import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:van_ber_passenger/core/constant/hongkong_regions.dart';
import 'package:van_ber_passenger/core/theme/colors.dart';
import 'package:van_ber_passenger/core/utils/navigation_helper.dart';
import 'package:van_ber_passenger/features/auth/account_login_select_screen.dart';
import 'package:van_ber_passenger/features/auth/firebase_auth.dart';
import 'package:van_ber_passenger/features/payments/payment_setup_screen.dart';
import 'package:van_ber_passenger/home_screen.dart';
import 'package:van_ber_passenger/providers/user_provider.dart';

class AccountSetupPage extends StatefulWidget {
  const AccountSetupPage({super.key});

  @override
  State<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final bool _isLoading = false;
  String? _selectedRegion;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isGoogleAuth() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return userProvider.getAuthMethod() == 'Google';
  }

  // Check if all required fields are filled
  bool get _isFormComplete {
    final isBasicInfoComplete =
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _selectedRegion != null &&
        _acceptTerms;

    if (_isGoogleAuth()) {
      return isBasicInfoComplete;
    } else {
      return isBasicInfoComplete && _emailController.text.isNotEmpty;
    }
  }

  Future<void> _showMessage(String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notice'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // In AccountSetupPage, modify the saveProfile method to just navigate:
  Future<void> saveProfile() async {
    if (!_isFormComplete) {
      await _showMessage('Please fill all the required information');
      return;
    }

    if (mounted) {
      AppNavigator.push(context, const AddPaymentScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGoogleAuth = _isGoogleAuth();
    final buttonColor = _isFormComplete
        ? AppColors.red
        // ignore: deprecated_member_use
        : AppColors.darkGray.withOpacity(0.05);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 44.h,
                      width: 44.w,
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            // Clear user provider state
                            await Provider.of<UserProvider>(
                              context,
                              listen: false,
                            ).clearUser();

                            // Sign out from Firebase
                            final authService = FirebaseAuthService();
                            await authService.signOut();

                            if (context.mounted) {
                              // Close loading dialog
                              Navigator.of(context).pop();

                              // Navigate back to login
                              AppNavigator.pushReplacement(
                                context,
                                const AccountLoginSelectScreen(),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              // Close loading dialog
                              Navigator.of(context).pop();

                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            }
                          }
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
                    Text(
                      'New Passenger Registration',
                      style: TextStyle(
                        fontSize: 20.h,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      'Tell us about yourself',
                      style: TextStyle(
                        fontSize: 12.h,
                        color: AppColors.darkGray,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // First Name
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      hint: 'Enter first name',
                      enabled:
                          !isGoogleAuth || _firstNameController.text.isEmpty,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 20.h),

                    // Last Name
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hint: 'Enter last name',
                      enabled:
                          !isGoogleAuth || _lastNameController.text.isEmpty,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 20.h),

                    // Email (shown for all users, pre-filled for Google auth)
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter email',
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isGoogleAuth, // Disabled for Google auth users
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 20.h),

                    // Phone Number
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Mobile Number',
                      hint: 'Country code + phone number',
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 20.h),

                    // Hong Kong Region Dropdown
                    Text(
                      'Region',
                      style: TextStyle(
                        fontSize: 14.h,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkGray.withOpacity(0.025),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: DropdownButton<String>(
                        value: _selectedRegion,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: Text(
                          'Select your region',
                          style: TextStyle(
                            color: AppColors.darkGray.withOpacity(0.6),
                            fontSize: 14.h,
                          ),
                        ),
                        items: hongKongRegions.map((region) {
                          return DropdownMenuItem<String>(
                            value: region,
                            child: Text(region),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRegion = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Terms and Conditions Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: AppColors.red,
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 0.5.w,
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Add navigation to terms and conditions page
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14.h,
                                  color: AppColors.darkGray,
                                ),
                                children: const [
                                  TextSpan(
                                    text:
                                        'I accept Van-ber\'s privacy policy and terms & conditions',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),

                    // Save Button with dynamic color
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: _isFormComplete && !_isLoading
                            ? saveProfile
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 14.h,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool enabled = true,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.h,
            fontWeight: FontWeight.w400,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkGray.withOpacity(0.025),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.darkGray.withOpacity(0.6),
                fontSize: 14.h,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            style: TextStyle(
              fontSize: 14.h,
              color: enabled ? AppColors.black : AppColors.darkGray,
            ),
          ),
        ),
      ],
    );
  }
}
