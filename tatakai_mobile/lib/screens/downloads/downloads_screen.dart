import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: const Center(child: Text('Downloads Screen')),
    );
  }
}
