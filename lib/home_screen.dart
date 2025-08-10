import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:van_ber_passenger/core/theme/colors.dart';
import 'package:van_ber_passenger/core/utils/navigation_helper.dart';
import 'package:van_ber_passenger/features/auth/account_login_select_screen.dart';
import 'package:van_ber_passenger/features/auth/firebase_auth.dart';
import 'package:van_ber_passenger/providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // Set a timeout for the entire logout process
      await Future.wait([
        // Clear user provider state first
        Provider.of<UserProvider>(context, listen: false).clearUser(),
        // Sign out using FirebaseAuthService
        FirebaseAuthService().signOut(),
      ]).timeout(const Duration(seconds: 5));

      // Close loading dialog and navigate
      if (context.mounted) {
        Navigator.of(context).pop(); // Close the dialog first

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );

        // Navigate back to login screen
        AppNavigator.pushReplacement(context, const AccountLoginSelectScreen());
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop(); // Close the dialog

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            backgroundColor: AppColors.red,
            actions: [
              IconButton(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                if (user != null) ...[
                  Text(
                    'Welcome back, ${user.firstName.isNotEmpty ? user.firstName : 'User'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Information',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Name',
                            user.fullName.isNotEmpty
                                ? user.fullName
                                : 'Not set',
                          ),
                          _buildInfoRow(
                            'Phone',
                            user.phoneNumber.isNotEmpty
                                ? user.phoneNumber
                                : 'Not set',
                          ),
                          _buildInfoRow(
                            'Email',
                            user.email.isNotEmpty ? user.email : 'Not set',
                          ),
                          _buildInfoRow(
                            'Signup Method',
                            user.signupMethod?.toUpperCase() ?? 'Unknown',
                          ),
                          _buildInfoRow(
                            'Member Since',
                            user.createdAt != null
                                ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                                : 'Not available',
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_done,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Data synced with Firebase',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Start ride button
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      "Start Ride",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
