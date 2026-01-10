import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GenreScreen extends ConsumerWidget {
  final String genre;
  
  const GenreScreen({super.key, required this.genre});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(genre)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 20,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
