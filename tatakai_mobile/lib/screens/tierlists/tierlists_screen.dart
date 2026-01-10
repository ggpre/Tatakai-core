import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tatakai_mobile/config/theme.dart';

class TierListsScreen extends ConsumerStatefulWidget {
  const TierListsScreen({super.key});
  
  @override
  ConsumerState<TierListsScreen> createState() => _TierListsScreenState();
}

class _TierListsScreenState extends ConsumerState<TierListsScreen> {
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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppThemes.spaceLg),
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildTierListCard(index);
        },
      ),
    );
  }
  
  Widget _buildTierListCard(int index) {
    final tierListNames = [
      'Best Action Anime',
      'My 2024 Rankings',
      'All Time Favorites',
    ];
    
    final tierColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
    ];
    
    final tierLabels = ['S', 'A', 'B', 'C', 'D'];
    
    return GestureDetector(
      onTap: () {
        // Open tier list
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
                      gradient: LinearGradient(
                        colors: [
                          AppThemes.accentPink,
                          AppThemes.accentPinkLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                    ),
                    child: const Icon(
                      Icons.leaderboard,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppThemes.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tierListNames[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${15 + index * 5} anime ranked',
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
                      Icons.more_vert,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    onPressed: () => _showTierListOptions(index),
                  ),
                ],
              ),
            ),
            
            // Tier preview
            ...List.generate(3, (tierIndex) {
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
                        color: tierColors[tierIndex],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          tierLabels[tierIndex],
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
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3 + tierIndex,
                          itemBuilder: (context, itemIndex) {
                            return Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: AppThemes.darkBackground,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.movie,
                                size: 16,
                                color: Colors.white24,
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
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${index + 1} day${index > 0 ? 's' : ''} ago',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: AppThemes.accentPink.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${12 + index * 8}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
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
    );
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
          title: const Text(
            'Create Tier List',
            style: TextStyle(color: Colors.white),
          ),
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
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.accentPink,
              ),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
  
  void _showTierListOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppThemes.radiusXLarge),
        ),
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
                title: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text(
                  'Share',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.content_copy, color: Colors.white),
                title: const Text(
                  'Duplicate',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
    );
  }
}
