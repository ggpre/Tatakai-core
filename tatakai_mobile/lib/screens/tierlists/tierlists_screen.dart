import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TierlistsScreen extends ConsumerWidget {
  const TierlistsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tierlists')),
      body: const Center(child: Text('Tierlists Screen')),
    );
  }
}
