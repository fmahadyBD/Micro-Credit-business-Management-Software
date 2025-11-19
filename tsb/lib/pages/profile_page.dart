// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../widgets/edit_profile_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  ProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.getMyProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('প্রোফাইল লোড করতে ত্রুটি: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog() {
    if (_profile == null) return;
    
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        profile: _profile!,
        onProfileUpdated: _loadProfile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('প্রোফাইল লোড করতে ব্যর্থ'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('পুনরায় চেষ্টা করুন'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade600,
                  Colors.deepPurple.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.deepPurple.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                Text(
                  _profile!.fullName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Email
                Text(
                  _profile!.username,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),

                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoleIcon(_profile!.role),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getRoleBangla(_profile!.role),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Edit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showEditDialog,
              icon: const Icon(Icons.edit),
              label: const Text(
                'প্রোফাইল সম্পাদনা করুন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Profile Details Card
          _buildInfoCard(
            title: 'ব্যক্তিগত তথ্য',
            children: [
              _buildInfoRow('প্রথম নাম', _profile!.firstname),
              const Divider(),
              _buildInfoRow('শেষ নাম', _profile!.lastname),
              const Divider(),
              _buildInfoRow('ইমেইল', _profile!.username),
            ],
          ),

          const SizedBox(height: 16),

          // Account Details Card
          _buildInfoCard(
            title: 'অ্যাকাউন্ট বিবরণ',
            children: [
              _buildInfoRow('ভূমিকা', _getRoleBangla(_profile!.role)),
              const Divider(),
              _buildInfoRow('স্ট্যাটাস', _getStatusBangla(_profile!.status)),
              const Divider(),
              _buildInfoRow(
                'সদস্য since',
                _formatDate(_profile!.createdDate),
              ),
              const Divider(),
              _buildInfoRow(
                'সর্বশেষ আপডেট',
                _formatDate(_profile!.lastModifiedDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return Icons.admin_panel_settings;
      case 'AGENT':
        return Icons.support_agent;
      case 'SHAREHOLDER':
        return Icons.business_center;
      default:
        return Icons.person;
    }
  }

  String _getRoleBangla(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'অ্যাডমিন';
      case 'AGENT':
        return 'এজেন্ট';
      case 'SHAREHOLDER':
        return 'শেয়ারহোল্ডার';
      default:
        return 'ব্যবহারকারী';
    }
  }

  String _getStatusBangla(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'সক্রিয়';
      case 'INACTIVE':
        return 'নিষ্ক্রিয়';
      case 'PENDING':
        return 'বিচারাধীন';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}