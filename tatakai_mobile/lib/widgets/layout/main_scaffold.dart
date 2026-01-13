import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  
  const MainScaffold({
    super.key,
    required this.child,
  });
  
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  
  // Duplicate _onItemTapped removed

  
  void _showAddModal() {
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
              const Padding(
                padding: EdgeInsets.all(AppThemes.spaceLg),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppThemes.accentPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                  ),
                  child: const Icon(Icons.playlist_add, color: AppThemes.accentPink),
                ),
                title: const Text(
                  'Create Playlist',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Organize your favorite anime',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/playlists');
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppThemes.accentPinkLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                  ),
                  child: const Icon(Icons.leaderboard, color: AppThemes.accentPinkLight),
                ),
                title: const Text(
                  'Create Tier List',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Rank your favorite anime',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/tierlists');
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppThemes.ratingGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                  ),
                  child: const Icon(Icons.rate_review, color: AppThemes.ratingGreen),
                ),
                title: const Text(
                  'Write a Review',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Share your thoughts',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppThemes.spaceXl),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    
    // Update selected index based on current route
    if (location == '/') {
      _selectedIndex = 0;
    } else if (location == '/search') {
      _selectedIndex = 1;
    } else if (location == '/favorites' || location == '/trending') {
      _selectedIndex = 2;
    } else if (location == '/community' || location == '/tierlists') {
      _selectedIndex = 3;
    } else if (location == '/profile' || location == '/settings' || location.startsWith('/@')) {
      _selectedIndex = 4;
    }
    
    return Scaffold(
      body: widget.child,
      extendBody: true,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
  
  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddModal();
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      // Case 2 handled by modal
      case 3:
        context.go('/favorites');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: AppThemes.darkSurface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemes.spaceSm,
            vertical: AppThemes.spaceMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, 'Home'), // LayoutGrid
              _buildNavItem(1, Icons.search_rounded, 'Search'), // Search
              _buildAddButton(), // Main Action
              _buildNavItem(3, Icons.favorite_rounded, 'Favorites'), // Heart
              _buildProfileNavItem(4), // Users/Profile
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: AppThemes.accentPink,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppThemes.accentPink.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 24,
          color: isSelected 
              ? AppThemes.accentPink 
              : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildProfileNavItem(int index) {
     final isSelected = _selectedIndex == index;
     // Ideally fetch profile image here context.read... but simplifying for now
     return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected ? Border.all(color: AppThemes.accentPink, width: 2) : null,
          ),
          child: const CircleAvatar(
             backgroundColor: Colors.grey,
             child: Icon(Icons.person, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
