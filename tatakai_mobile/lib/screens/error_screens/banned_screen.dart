import 'package:flutter/material.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Account Banned', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Your account has been suspended.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
