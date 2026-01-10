import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/gradients.dart';

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
        context.go('/favorites');
        break;
      case 3:
        context.go('/downloads');
        break;
      case 4:
        context.go('/profile');
        break;
    }
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
      _selectedIndex = 2;
    } else if (location == '/downloads') {
      _selectedIndex = 3;
    } else if (location == '/profile') {
      _selectedIndex = 4;
    }
    
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(1, Icons.search, 'Search'),
                _buildNavItem(2, Icons.favorite, 'Favorites'),
                _buildNavItem(3, Icons.download, 'Downloads'),
                _buildNavItem(4, Icons.person, 'Profile'),
              ],
            ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? ShaderMask(
                      shaderCallback: (bounds) =>
                          AppGradients.primaryGradient.createShader(bounds),
                      child: Icon(
                        icon,
                        size: 26,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 26,
                      color: Colors.white.withOpacity(0.5),
                    ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? null : Colors.white.withOpacity(0.5),
              ),
              child: isSelected
                  ? ShaderMask(
                      shaderCallback: (bounds) =>
                          AppGradients.primaryGradient.createShader(bounds),
                      child: Text(
                        label,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
