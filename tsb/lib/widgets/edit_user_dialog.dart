import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class EditUserDialog extends StatefulWidget {
  final UserModel user;
  final VoidCallback onUserUpdated;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'USER';
  String _selectedStatus = 'ACTIVE';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _changePassword = false;

  final List<String> _roles = ['ADMIN', 'AGENT', 'SHAREHOLDER', 'USER'];
  final List<String> _statuses = ['ACTIVE', 'INACTIVE', 'PENDING', 'SUSPENDED'];

  // Role and Status translations
  final Map<String, String> _roleTranslations = {
    'ADMIN': 'অ্যাডমিন',
    'AGENT': 'এজেন্ট',
    'SHAREHOLDER': 'শেয়ারহোল্ডার',
    'USER': 'ব্যবহারকারী',
  };

  final Map<String, String> _statusTranslations = {
    'ACTIVE': 'সক্রিয়',
    'INACTIVE': 'নিষ্ক্রিয়',
    'PENDING': 'বিচারাধীন',
    'SUSPENDED': 'স্থগিত',
  };

  @override
  void initState() {
    super.initState();
    _firstnameController.text = widget.user.firstname;
    _lastnameController.text = widget.user.lastname;
    _usernameController.text = widget.user.username;
    _selectedRole = widget.user.role;
    _selectedStatus = widget.user.status;
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _showConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'আপডেট নিশ্চিত করুন',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'আপনি কি এই ব্যবহারকারী আপডেট করতে চান?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('নাম:', '${_firstnameController.text} ${_lastnameController.text}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('ইউজারনেম:', _usernameController.text),
                    const SizedBox(height: 8),
                    _buildInfoRow('ভূমিকা:', _roleTranslations[_selectedRole] ?? _selectedRole),
                    const SizedBox(height: 8),
                    _buildInfoRow('স্ট্যাটাস:', _statusTranslations[_selectedStatus] ?? _selectedStatus),
                    if (_changePassword) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow('পাসওয়ার্ড:', '●●●●●●●● (পরিবর্তিত)', isHighlighted: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_changePassword)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'পাসওয়ার্ড পরিবর্তন করা হবে',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'বাতিল করুন',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'আপডেট নিশ্চিত করুন',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isHighlighted ? Colors.red.shade700 : Colors.black87,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final userService = UserService();
      
      await userService.updateUser(
        widget.user.id,
        _firstnameController.text.trim(),
        _lastnameController.text.trim(),
        _usernameController.text.trim(),
        _selectedRole,
        _selectedStatus,
        password: _changePassword ? _passwordController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _changePassword 
                        ? 'ব্যবহারকারী নতুন পাসওয়ার্ড সহ সফলভাবে আপডেট হয়েছে!' 
                        : 'ব্যবহারকারী সফলভাবে আপডেট হয়েছে!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        widget.onUserUpdated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('ত্রুটি: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.deepPurple.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ব্যবহারকারী সম্পাদনা করুন',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ব্যবহারকারীর তথ্য আপডেট করুন',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // First Name
                  _buildTextField(
                    controller: _firstnameController,
                    label: 'প্রথম নাম',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'দয়া করে প্রথম নাম লিখুন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  _buildTextField(
                    controller: _lastnameController,
                    label: 'শেষ নাম',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'দয়া করে শেষ নাম লিখুন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Username
                  _buildTextField(
                    controller: _usernameController,
                    label: 'ইউজারনেম (ইমেইল)',
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'দয়া করে ইউজারনেম লিখুন';
                      }
                      if (!value.contains('@')) {
                        return 'দয়া করে একটি বৈধ ইমেইল লিখুন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'ভূমিকা',
                      prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(_roleTranslations[role] ?? role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedRole = value!);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'স্ট্যাটাস',
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_statusTranslations[status] ?? status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                    },
                  ),
                  const SizedBox(height: 20),

                  const Divider(),
                  const SizedBox(height: 12),

                  // Change Password Checkbox
                  CheckboxListTile(
                    title: const Text(
                      'পাসওয়ার্ড পরিবর্তন করুন',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'ব্যবহারকারীর পাসওয়ার্ড আপডেট করতে এটি চেক করুন',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _changePassword,
                    onChanged: (value) {
                      setState(() {
                        _changePassword = value!;
                        if (!_changePassword) {
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        }
                      });
                    },
                    activeColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Password Fields (shown only if checkbox is checked)
                  if (_changePassword) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'নতুন পাসওয়ার্ড',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (_changePassword) {
                          if (value == null || value.isEmpty) {
                            return 'দয়া করে নতুন পাসওয়ার্ড লিখুন';
                          }
                          if (value.length < 6) {
                            return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'পাসওয়ার্ড নিশ্চিত করুন',
                      icon: Icons.lock_outline,
                      obscure: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (value) {
                        if (_changePassword) {
                          if (value == null || value.isEmpty) {
                            return 'দয়া করে পাসওয়ার্ড নিশ্চিত করুন';
                          }
                          if (value != _passwordController.text) {
                            return 'পাসওয়ার্ড মেলে না';
                          }
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'বাতিল করুন',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'ব্যবহারকারী আপডেট করুন',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
    );
  }
}