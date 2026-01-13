import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});
  
  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Community',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppThemes.accentPink,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Forum'),
            Tab(text: 'Tier Lists'),
            Tab(text: 'Reviews'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(),
          _buildForumTab(),
          _buildTierListsTab(),
          _buildReviewsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppThemes.accentPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildFeedTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildFeedPost(index);
      },
    );
  }
  
  Widget _buildFeedPost(int index) {
    return Container(
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppThemes.accentPink.withOpacity(0.2),
                  child: const Icon(Icons.person, color: AppThemes.accentPink),
                ),
                const SizedBox(width: AppThemes.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${index + 1}h ago',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceMd),
            child: Text(
              'Just finished watching this amazing anime! The animation quality was incredible and the story kept me hooked till the end. Highly recommend! 🔥',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          
          // Anime reference card
          Container(
            margin: const EdgeInsets.all(AppThemes.spaceMd),
            padding: const EdgeInsets.all(AppThemes.spaceMd),
            decoration: BoxDecoration(
              color: AppThemes.darkBackground,
              borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppThemes.darkSurface,
                    borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                  ),
                  child: const Icon(Icons.movie, color: Colors.white24),
                ),
                const SizedBox(width: AppThemes.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anime Title ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppThemes.ratingGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '8.5',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppThemes.spaceSm,
              0,
              AppThemes.spaceSm,
              AppThemes.spaceSm,
            ),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  label: Text(
                    '${24 + index}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  label: Text(
                    '${8 + index}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.share,
                    size: 20,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  label: Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildForumTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppThemes.spaceMd),
          decoration: BoxDecoration(
            color: AppThemes.darkSurface,
            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(AppThemes.spaceMd),
                title: Row(
                  children: [
                    if (index == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppThemes.spaceSm,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(right: AppThemes.spaceSm),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Pinned',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        'Forum Post Title ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: AppThemes.spaceSm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This is a preview of the forum post content. It shows the first few lines...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppThemes.spaceSm),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                size: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${42 + index * 5}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: AppThemes.spaceMd),
                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${15 + index} comments',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '${index + 1}h ago',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTierListsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppThemes.spaceMd),
          decoration: BoxDecoration(
            color: AppThemes.darkSurface,
            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppThemes.spaceMd),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemes.accentPink.withOpacity(0.3),
                    Colors.purple.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
              ),
              child: const Icon(Icons.view_list, color: Colors.white),
            ),
            title: Text(
              'Tier List ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: AppThemes.spaceSm),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 14,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${120 + index * 10} likes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: AppThemes.spaceMd),
                  Text(
                    'by User ${index + 1}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
  
  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppThemes.spaceLg),
          decoration: BoxDecoration(
            color: AppThemes.darkSurface,
            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Anime info
              Padding(
                padding: const EdgeInsets.all(AppThemes.spaceMd),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 85,
                      decoration: BoxDecoration(
                        color: AppThemes.darkBackground,
                        borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                      ),
                      child: const Icon(Icons.movie, color: Colors.white24),
                    ),
                    const SizedBox(width: AppThemes.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Anime Title ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppThemes.spaceXs),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < 4 ? Icons.star : Icons.star_border,
                                size: 18,
                                color: AppThemes.ratingGreen,
                              );
                            }),
                          ),
                          const SizedBox(height: AppThemes.spaceXs),
                          Text(
                            'by User ${index + 1}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Review text
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppThemes.spaceMd,
                  0,
                  AppThemes.spaceMd,
                  AppThemes.spaceMd,
                ),
                child: Text(
                  'This anime was absolutely incredible! The story was engaging from start to finish, and the character development was top-notch...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
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
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${45 + index} helpful',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Read more',
                        style: TextStyle(
                          color: AppThemes.accentPink,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
