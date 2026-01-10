import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status')),
      body: const Center(child: Text('Status Screen')),
    );
  }
}
