import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/forum_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final forumState = ref.watch(forumProvider);

    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Community Forum',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreatePostDialog(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceMd, vertical: 8),
              children: [
                _buildSortChip('Hot', 'hot', forumState.sort),
                _buildSortChip('New', 'new', forumState.sort),
                _buildSortChip('Top', 'top', forumState.sort),
              ],
            ),
          ),
        ),
      ),
      body: forumState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemes.accentPink))
          : forumState.error != null
              ? Center(child: Text('Error: ${forumState.error}', style: const TextStyle(color: Colors.white)))
              : RefreshIndicator(
                  color: AppThemes.accentPink,
                  onRefresh: () => ref.read(forumProvider.notifier).fetchPosts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppThemes.spaceMd),
                    itemCount: forumState.posts.length,
                    itemBuilder: (context, index) {
                      return _buildForumPostCard(forumState.posts[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildSortChip(String label, String value, String currentSort) {
    final isSelected = value == currentSort;
    return GestureDetector(
      onTap: () {
        ref.read(forumProvider.notifier).fetchPosts(sortBy: value);
      },
      child: Container(
        margin: const EdgeInsets.only(right: AppThemes.spaceMd),
        padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppThemes.accentPink : AppThemes.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildForumPostCard(ForumPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppThemes.spaceMd),
      padding: const EdgeInsets.all(AppThemes.spaceMd),
      decoration: BoxDecoration(
        color: AppThemes.darkSurface,
        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vote buttons
              Column(
                children: [
                  const Icon(Icons.arrow_upward, color: Colors.white54, size: 20),
                  Text('${post.upvotes - post.downvotes}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Icon(Icons.arrow_downward, color: Colors.white54, size: 20),
                ],
              ),
              const SizedBox(width: AppThemes.spaceMd),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metadata
                    Row(
                      children: [
                        if (post.flair != null)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppThemes.accentPink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              post.flair!,
                              style: const TextStyle(color: AppThemes.accentPink, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (post.isPinned)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PINNED',
                              style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                         if (post.animeName != null)
                          Container(
                             margin: const EdgeInsets.only(right: 8),
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(
                               color: AppThemes.darkBackground,
                               borderRadius: BorderRadius.circular(4),
                             ),
                             child: Text(
                               post.animeName!,
                               style: const TextStyle(color: Colors.white60, fontSize: 10),
                               maxLines: 1,
                               overflow: TextOverflow.ellipsis,
                             ),
                           ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    Text(
                      post.title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.content,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Footer
                    Row(
                      children: [
                        if (post.authorAvatar != null)
                          CircleAvatar(
                            backgroundImage: NetworkImage(post.authorAvatar!),
                            radius: 8,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          post.authorName ?? 'Anonymous',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.circle, size: 4, color: Colors.white24),
                        const SizedBox(width: 8),
                        Text(
                          timeago.format(post.createdAt),
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const Spacer(),
                        const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          '${post.commentsCount}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemes.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppThemes.radiusMedium)),
          title: const Text('New Discussion', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  await ref.read(forumProvider.notifier).createPost(titleController.text, contentController.text);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppThemes.accentPink),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}
