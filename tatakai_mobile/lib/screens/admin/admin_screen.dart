import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});
  
  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Users', 'Comments', 'Notifications', 'Logs'];
  
  // Users
  List<Map<String, dynamic>> _users = [];
  bool _loadingUsers = false;
  String _searchQuery = '';
  
  // Notifications
  final TextEditingController _notifTitleController = TextEditingController();
  final TextEditingController _notifBodyController = TextEditingController();
  bool _sendingNotification = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _loadUsers();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _notifTitleController.dispose();
    _notifBodyController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final response = await supabase.client
          .from('profiles')
          .select()
          .order('created_at', ascending: false)
          .limit(100);
      
      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _loadingUsers = false;
      });
    } catch (e) {
      setState(() => _loadingUsers = false);
      print('Error loading users: $e');
    }
  }
  
  Future<void> _banUser(String userId, String reason) async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.client.from('profiles').update({
        'role': 'banned',
        'ban_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      await _loadUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User banned'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _unbanUser(String userId) async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.client.from('profiles').update({
        'role': 'user',
        'ban_reason': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      await _loadUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User unbanned'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _sendNotification() async {
    if (_notifTitleController.text.isEmpty || _notifBodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title and body')),
      );
      return;
    }
    
    setState(() => _sendingNotification = true);
    
    try {
      final supabase = ref.read(supabaseServiceProvider);
      // Insert notification record (Supabase trigger or Edge Function handles FCM)
      await supabase.client.from('notifications').insert({
        'title': _notifTitleController.text,
        'body': _notifBodyController.text,
        'target': 'all',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      _notifTitleController.clear();
      _notifBodyController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _sendingNotification = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    // Check if user is admin
    if (currentUser == null || !currentUser.isAdmin) {
      return Scaffold(
        backgroundColor: AppThemes.darkBackground,
        appBar: AppBar(
          backgroundColor: AppThemes.darkBackground,
          title: const Text('Admin', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Access Denied\nYou must be an admin to view this page.',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
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
          'Admin Panel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          labelColor: AppThemes.accentPink,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppThemes.accentPink,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildCommentsTab(),
          _buildNotificationsTab(),
          _buildLogsTab(),
        ],
      ),
    );
  }
  
  Widget _buildUsersTab() {
    final filteredUsers = _searchQuery.isEmpty
        ? _users
        : _users.where((u) {
            final email = (u['email'] ?? '').toString().toLowerCase();
            final username = (u['username'] ?? '').toString().toLowerCase();
            return email.contains(_searchQuery.toLowerCase()) ||
                   username.contains(_searchQuery.toLowerCase());
          }).toList();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppThemes.spaceMd),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: AppThemes.darkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(
          child: _loadingUsers
              ? const Center(child: CircularProgressIndicator(color: AppThemes.accentPink))
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isBanned = user['role'] == 'banned';
                      final isAdmin = user['role'] == 'admin';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAdmin
                              ? Colors.amber
                              : isBanned
                                  ? Colors.red
                                  : AppThemes.accentPink,
                          child: Icon(
                            isAdmin ? Icons.shield : isBanned ? Icons.block : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          user['username'] ?? user['email'] ?? 'Unknown',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          user['email'] ?? '',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white54),
                          color: AppThemes.darkSurface,
                          onSelected: (action) {
                            if (action == 'ban') {
                              _showBanDialog(user['id']);
                            } else if (action == 'unban') {
                              _unbanUser(user['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            if (!isBanned)
                              const PopupMenuItem(
                                value: 'ban',
                                child: Text('Ban User', style: TextStyle(color: Colors.red)),
                              ),
                            if (isBanned)
                              const PopupMenuItem(
                                value: 'unban',
                                child: Text('Unban User', style: TextStyle(color: Colors.green)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
  
  void _showBanDialog(String userId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemes.darkSurface,
        title: const Text('Ban User', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Reason for ban',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _banUser(userId, reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentsTab() {
    return const Center(
      child: Text(
        'Comments moderation coming soon',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
  
  Widget _buildNotificationsTab() {
    return Padding(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Push Notification',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppThemes.spaceMd),
          TextField(
            controller: _notifTitleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: AppThemes.darkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppThemes.spaceMd),
          TextField(
            controller: _notifBodyController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Body',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: AppThemes.darkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppThemes.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendingNotification ? null : _sendNotification,
              icon: _sendingNotification
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_sendingNotification ? 'Sending...' : 'Send to All Users'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.accentPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppThemes.spaceMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogsTab() {
    return const Center(
      child: Text(
        'Admin logs coming soon',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
