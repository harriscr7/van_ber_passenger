import 'package:flutter/material.dart';
import 'package:van_ber_passenger/core/theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), backgroundColor: AppColors.red),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text("Start Ride"),
        ),
      ),
    );
  }
}
