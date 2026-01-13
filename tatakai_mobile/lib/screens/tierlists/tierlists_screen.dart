import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/tierlists_provider.dart';
import 'package:tatakai_mobile/services/api_service.dart';

class TierListsScreen extends ConsumerStatefulWidget {
  const TierListsScreen({super.key});
  
  @override
  ConsumerState<TierListsScreen> createState() => _TierListsScreenState();
}

class _TierListsScreenState extends ConsumerState<TierListsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final tierListsState = ref.watch(tierListsProvider);

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
          'Tier Lists',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreateTierListDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppThemes.accentPink,
          labelColor: AppThemes.accentPink,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Community'),
            Tab(text: 'My Lists'),
          ],
        ),
      ),
      body: tierListsState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemes.accentPink))
          : tierListsState.error != null
              ? _buildErrorState(tierListsState.error!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTierListGrid(tierListsState.publicTierLists),
                    _buildTierListGrid(tierListsState.myTierLists, isMine: true),
                  ],
                ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(error, style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(tierListsProvider.notifier).fetchTierLists(),
            style: ElevatedButton.styleFrom(backgroundColor: AppThemes.accentPink),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTierListGrid(List<TierList> tierLists, {bool isMine = false}) {
    if (tierLists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              color: Colors.white24,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              isMine ? 'No tier lists yet' : 'No public tier lists',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            if (isMine) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showCreateTierListDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Create Tier List'),
                style: ElevatedButton.styleFrom(backgroundColor: AppThemes.accentPink),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppThemes.accentPink,
      onRefresh: () => ref.read(tierListsProvider.notifier).fetchTierLists(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppThemes.spaceLg),
        itemCount: tierLists.length,
        itemBuilder: (context, index) => _buildTierListCard(tierLists[index], isMine: isMine),
      ),
    );
  }
  
  Widget _buildTierListCard(TierList tierList, {bool isMine = false}) {
    final tierColors = {
      'S': Colors.red,
      'A': Colors.orange,
      'B': Colors.yellow,
      'C': Colors.green,
      'D': Colors.blue,
    };
    
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to tier list detail
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppThemes.spaceLg),
        decoration: BoxDecoration(
          color: AppThemes.darkSurface,
          borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppThemes.spaceMd),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppThemes.accentPink, AppThemes.accentPinkLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                    ),
                    child: const Icon(Icons.leaderboard, color: Colors.white),
                  ),
                  const SizedBox(width: AppThemes.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tierList.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (tierList.authorName != null)
                          Text(
                            'by ${tierList.authorName}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isMine)
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5)),
                      onPressed: () => _showTierListOptions(tierList),
                    ),
                ],
              ),
            ),
            
            // Tier preview
            ...tierColors.entries.take(3).map((entry) {
              final items = tierList.tiers[entry.key] ?? [];
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppThemes.spaceMd,
                  vertical: AppThemes.spaceXs,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: entry.value,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppThemes.spaceSm),
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: items.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: AppThemes.darkBackground.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: items.length,
                                itemBuilder: (context, itemIndex) {
                                  final item = items[itemIndex];
                                  return Container(
                                    width: 32,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: CachedNetworkImage(
                                      imageUrl: item.animePoster,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: AppThemes.darkBackground,
                                        child: const Icon(Icons.movie, size: 16, color: Colors.white24),
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: AppThemes.darkBackground,
                                        child: const Icon(Icons.movie, size: 16, color: Colors.white24),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: AppThemes.spaceMd),
            
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppThemes.spaceMd,
                0,
                AppThemes.spaceMd,
                AppThemes.spaceMd,
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.white.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeAgo(tierList.updatedAt),
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 14, color: AppThemes.accentPink.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        '${tierList.likes}',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
  
  void _showCreateTierListDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemes.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          ),
          title: const Text('Create Tier List', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tier list name',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: AppThemes.darkBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(tierListsProvider.notifier).createTierList(controller.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppThemes.accentPink),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
  
  void _showTierListOptions(TierList tierList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppThemes.radiusXLarge)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppThemes.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Edit', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(
                  tierList.isPublic ? Icons.lock : Icons.public,
                  color: Colors.white,
                ),
                title: Text(
                  tierList.isPublic ? 'Make Private' : 'Make Public',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(tierListsProvider.notifier).deleteTierList(tierList.id);
                },
              ),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
    );
  }
}
