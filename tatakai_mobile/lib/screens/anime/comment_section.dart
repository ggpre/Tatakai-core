import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tatakai_mobile/providers/comments_provider.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';
import 'package:tatakai_mobile/providers/anime_provider.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';

class CommentSection extends ConsumerStatefulWidget {
  final String animeId;
  const CommentSection({super.key, required this.animeId});

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsProvider(widget.animeId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppThemes.spaceSm),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(color: AppThemes.textSecondaryLight),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppThemes.accentPink),
                onPressed: () async {
                  final content = _controller.text.trim();
                  if (content.isEmpty) return;
                  final username = ref.read(supabaseServiceProvider).currentUser?.email ?? 'Anonymous';
                  await ref.read(commentsProvider(widget.animeId).notifier).postComment(content, username);
                  _controller.clear();
                  // Refresh parent anime details (likes/comments counts may change)
                  await ref.read(animeDetailProvider.notifier).fetchAnimeDetail(widget.animeId);
                },
              ),
            ],
          ),
        ),
        if (state.isLoading) const Center(child: CircularProgressIndicator()),
        const SizedBox(height: AppThemes.spaceSm),
        ...state.comments.map((c) => _buildCommentCard(c)).toList(),
      ],
    );
  }

  Widget _buildCommentCard(comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppThemes.spaceMd),
      padding: const EdgeInsets.all(AppThemes.spaceMd),
      decoration: BoxDecoration(
        color: AppThemes.lightSurface,
        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppThemes.darkSurface,
                child: const Icon(Icons.person, color: Colors.white, size: 16),
              ),
              const SizedBox(width: AppThemes.spaceSm),
              Text(
                comment.username ?? 'Anonymous',
                style: TextStyle(
                  color: AppThemes.darkBackground,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                comment.createdAt.toString(),
                style: TextStyle(
                  color: AppThemes.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemes.spaceSm),
          Text(
            comment.content,
            style: TextStyle(
              color: AppThemes.textSecondaryLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}