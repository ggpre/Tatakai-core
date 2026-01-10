import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      body: const Center(child: Text('Playlists Screen')),
    );
  }
}
