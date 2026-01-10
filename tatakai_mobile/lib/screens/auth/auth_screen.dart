import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: const Center(child: Text('Auth Screen')),
    );
  }
}
