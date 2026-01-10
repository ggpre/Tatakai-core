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
  
  void _onItemTapped(int index) {
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
      case 2:
        // Add button - show modal
        _showAddModal();
        break;
      case 3:
        context.go('/favorites');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
  
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
    } else if (location == '/favorites') {
      _selectedIndex = 3;
    } else if (location == '/profile') {
      _selectedIndex = 4;
    }
    
    return Scaffold(
      body: widget.child,
      extendBody: true,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
  
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppThemes.darkSurface.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemes.spaceLg,
            vertical: AppThemes.spaceSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.pause_circle_outline, 'Watch'),
              _buildNavItem(1, Icons.search, 'Search'),
              _buildAddButton(),
              _buildNavItem(3, Icons.grid_view, 'Library'),
              _buildNavItem(4, Icons.person_outline, 'Profile'),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemes.spaceMd,
          vertical: AppThemes.spaceSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected 
                  ? AppThemes.accentPink 
                  : Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? AppThemes.accentPink 
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppThemes.accentPink, AppThemes.accentPinkLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppThemes.accentPink.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
