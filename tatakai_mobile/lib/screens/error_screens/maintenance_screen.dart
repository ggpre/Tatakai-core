import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.build, size: 64),
              const SizedBox(height: 16),
              Text('Under Maintenance', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('We\'ll be back soon!', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
