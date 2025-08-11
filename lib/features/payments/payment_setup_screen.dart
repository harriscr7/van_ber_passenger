import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:van_ber_passenger/core/utils/navigation_helper.dart';
import 'package:van_ber_passenger/home_screen.dart';
import 'package:van_ber_passenger/models/card_model.dart';
import 'package:van_ber_passenger/providers/card_provider.dart';
import 'package:van_ber_passenger/providers/user_provider.dart';
import 'package:van_ber_passenger/models/user_model.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  bool _isLoading = false;
  bool _skipPayment = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // 1. Save the user profile to Firebase (profile data was saved temporarily in account setup)
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider
          .saveProfile(); // This will save to Firebase and mark profile as complete

      // 2. Then handle payment if not skipped
      if (!_skipPayment) {
        if (!_formKey.currentState!.validate()) {
          setState(() => _isLoading = false);
          return;
        }

        final cardProvider = Provider.of<CardProvider>(context, listen: false);
        final expiryParts = _expiryController.text.split('/');
        final expiryMonth = expiryParts[0];
        final expiryYear =
            expiryParts[1].length == 2
                ? (int.parse(expiryParts[1]) > 80
                    ? '19${expiryParts[1]}'
                    : '20${expiryParts[1]}')
                : expiryParts[1];

        final paymentMethod = PaymentMethod(
          id: 'card_${DateTime.now().millisecondsSinceEpoch}',
          userId: userProvider.user?.id ?? '',
          last4Digits: _cardNumberController.text
              .replaceAll(RegExp(r'[^0-9]'), '')
              .substring(
                _cardNumberController.text
                        .replaceAll(RegExp(r'[^0-9]'), '')
                        .length -
                    4,
              ),
          cardBrand: _determineCardBrand(_cardNumberController.text),
          cardHolderName: _cardHolderController.text,
          expiryMonth: expiryMonth,
          expiryYear: expiryYear,
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await cardProvider.addPaymentMethod(paymentMethod);
      }

      if (!mounted) return;

      // Navigate to home screen
      AppNavigator.pushReplacement(context, const HomeScreen());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _skipPayment
                ? 'Registration completed successfully'
                : 'Payment method added successfully',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _skipPayment = true);
              _completeRegistration();
            },
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // User Info Card
                    _buildUserInfoCard(context, userModel),

                    const SizedBox(height: 32),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Card Number Field
                          _buildCardNumberField(),

                          const SizedBox(height: 16),

                          // Cardholder Name
                          _buildCardholderNameField(),

                          const SizedBox(height: 16),

                          // Expiry and CVC Row
                          _buildExpiryAndCvcRow(),

                          const SizedBox(height: 32),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _completeRegistration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Save Payment Method',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, UserModel? userModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildUserInfoRow('Name', userModel?.fullName ?? ''),
            const SizedBox(height: 8),
            _buildUserInfoRow('Email', userModel?.email ?? ''),
            const SizedBox(height: 8),
            _buildUserInfoRow('Phone', userModel?.phoneNumber ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      decoration: InputDecoration(
        labelText: 'Card Number',
        hintText: '4242 4242 4242 4242',
        prefixIcon: const Icon(Icons.credit_card),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter card number';
        final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleaned.length != 16) return 'Enter a valid 16-digit card number';
        return null;
      },
    );
  }

  Widget _buildCardholderNameField() {
    return TextFormField(
      controller: _cardHolderController,
      decoration: InputDecoration(
        labelText: 'Cardholder Name',
        hintText: 'John Doe',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter cardholder name';
        }
        if (value.length < 2) return 'Name too short';
        return null;
      },
    );
  }

  Widget _buildExpiryAndCvcRow() {
    return Row(
      children: [
        // Expiry Date
        Expanded(
          child: TextFormField(
            controller: _expiryController,
            decoration: InputDecoration(
              labelText: 'Expiry Date',
              hintText: 'MM/YY',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.datetime,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter expiry date';
              }
              if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                return 'Use MM/YY format';
              }
              final parts = value.split('/');
              final month = int.tryParse(parts[0]);
              final year = int.tryParse(parts[1]);

              if (month == null || year == null || month < 1 || month > 12) {
                return 'Invalid date';
              }

              final now = DateTime.now();
              final currentYear = now.year % 100;
              if (year < currentYear ||
                  (year == currentYear && month < now.month)) {
                return 'Card expired';
              }

              return null;
            },
          ),
        ),

        const SizedBox(width: 16),

        // CVC
        Expanded(
          child: TextFormField(
            controller: _cvcController,
            decoration: InputDecoration(
              labelText: 'CVC',
              hintText: '123',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter CVC';
              if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
                return '3-4 digits required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  String _determineCardBrand(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('4')) return 'Visa';
    if (cleaned.startsWith('5')) return 'MasterCard';
    if (cleaned.startsWith('34') || cleaned.startsWith('37')) return 'Amex';
    if (cleaned.startsWith('6')) return 'Discover';
    return 'Unknown';
  }
}
