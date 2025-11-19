import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../pages/login_page.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';
import 'package:provider/provider.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onProfileTap;

  const TopBar({
    super.key,
    required this.title,
    this.onProfileTap,
  });

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<TopBar> with SingleTickerProviderStateMixin {
  int notificationCount = 5;
  late AnimationController _pulseController;
  ProfileModel? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    print('🔵 TopBar: initState called');
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    print('🔵 TopBar: _loadProfile started');
    setState(() => _isLoadingProfile = true);
    
    try {
      final profileService = ProfileService();
      final profile = await profileService.getMyProfile();
      
      print('✅ TopBar: Profile loaded successfully');
      print('   - Name: ${profile.fullName}');
      print('   - Email: ${profile.username}');
      print('   - Role: ${profile.role}');
      
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('❌ TopBar: Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  @override
  void dispose() {
    print('🔴 TopBar: dispose called');
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    print('🔵 TopBar: _handleLogout called');
    
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('লগআউট নিশ্চিত করুন'),
            ],
          ),
          content: const Text(
            'আপনি কি আপনার অ্যাকাউন্ট থেকে লগআউট করতে চান?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('🔵 TopBar: Logout cancelled');
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                'বাতিল করুন',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print('🔵 TopBar: Logout confirmed');
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('লগআউট', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      print('🔵 TopBar: Processing logout...');
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final authService = AuthService();
      final success = await authService.logout();

      print('🔵 TopBar: Logout result: $success');

      if (mounted) {
        Navigator.of(context).pop();

        if (success) {
          print('✅ TopBar: Logout successful, navigating to login');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
          
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('সফলভাবে লগআউট হয়েছে'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          });
        }
      }
    }
  }

  void _showNotifications() {
    print('🔵 TopBar: _showNotifications called');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'নোটিফিকেশন',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => notificationCount = 0);
                        Navigator.pop(context);
                      },
                      child: const Text('সব মুছুন'),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              Expanded(
                child: notificationCount == 0
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'কোন নতুন নোটিফিকেশন নেই',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: notificationCount,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          return _buildNotificationItem(
                            title: 'নোটিফিকেশন ${index + 1}',
                            message: 'এটি নোটিফিকেশন মেসেজ ${index + 1}',
                            time: '${index + 2} মিনিট আগে',
                            icon: Icons.notifications_active,
                            color: Colors.blue,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🔵 TopBar: build called, profile loaded: ${_profile != null}');
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      actions: [
        // Notification Bell with Badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 26),
              onPressed: _showNotifications,
              tooltip: 'নোটিফিকেশন',
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      notificationCount > 9 ? '৯+' : '$notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(width: 8),
        
        // Profile Dropdown Menu
        PopupMenuButton<String>(
          offset: const Offset(0, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: Hero(
            tag: 'profile_avatar',
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.deepPurple.shade100,
              child: Icon(
                Icons.person,
                color: Colors.deepPurple.shade700,
                size: 22,
              ),
            ),
          ),
          onSelected: (value) {
            print('🔵 TopBar: Menu item selected: $value');
            if (value == 'logout') {
              _handleLogout();
            } else if (value == 'profile') {
              print('🔵 TopBar: Navigating to profile');
              if (widget.onProfileTap != null) {
                widget.onProfileTap!();
              } else {
                print('⚠️ TopBar: onProfileTap is null!');
              }
            } else if (value == 'settings') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('সেটিংস পেজ শীঘ্রই আসছে...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          itemBuilder: (BuildContext context) => [
            // Profile Info Header
            PopupMenuItem<String>(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.deepPurple,
                        child: _isLoadingProfile
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profile?.fullName ?? 'লোড হচ্ছে...',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _profile?.username ?? 'লোড হচ্ছে...',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const PopupMenuDivider(),
            
            // Profile Option
            const PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 22),
                  SizedBox(width: 12),
                  Text('প্রোফাইল', style: TextStyle(fontSize: 15)),
                ],
              ),
            ),
            
            // Settings Option
            const PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 22),
                  SizedBox(width: 12),
                  Text('সেটিংস', style: TextStyle(fontSize: 15)),
                ],
              ),
            ),
            
            // Theme Toggle
            PopupMenuItem<String>(
              onTap: () {
                Future.delayed(Duration.zero, () => themeProvider.toggleTheme());
              },
              child: Row(
                children: [
                  Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    themeProvider.isDarkMode ? 'লাইট মোড' : 'ডার্ক মোড',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            
            const PopupMenuDivider(),
            
            // Logout Option
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 22, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'লগআউট',
                    style: TextStyle(color: Colors.red, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 12),
      ],
    );
  }
}