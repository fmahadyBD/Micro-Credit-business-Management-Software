// lib/pages/all_users_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/services/user_service.dart';
import 'package:mobile_app/models/user_model.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterRole = 'ALL';
  String _filterStatus = 'ALL';
  late AnimationController _animationController;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadUsers();
    _loadCurrentUserRole();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserRole() async {
    // TODO: Implement getting current user's role from auth service
    setState(() {
      _currentUserRole = 'ADMIN'; // Replace with actual role
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackbar('Failed to load users: $e');
      }
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = user.firstname
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            user.lastname.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.username.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesRole = _filterRole == 'ALL' || user.role == _filterRole;
        final matchesStatus =
            _filterStatus == 'ALL' || user.status == _filterStatus;
        return matchesSearch && matchesRole && matchesStatus;
      }).toList();
    });
  }

  void _showEditDialog(UserModel user) {
    final firstNameController = TextEditingController(text: user.firstname);
    final lastNameController = TextEditingController(text: user.lastname);
    final usernameController = TextEditingController(text: user.username);
    String selectedRole = user.role;
    String selectedStatus = user.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Edit User',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username/Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            prefixIcon:
                                const Icon(Icons.admin_panel_settings_outlined),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: ['ADMIN', 'AGENT', 'SHAREHOLDER', 'USER']
                              .map((role) {
                            return DropdownMenuItem(
                                value: role, child: Text(role));
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedRole = value!);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            prefixIcon: const Icon(Icons.info_outline),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [
                            'ACTIVE',
                            'INACTIVE',
                            'SUSPENDED',
                            'PENDING_VERIFICATION',
                            'BLOCKED'
                          ].map((status) {
                            return DropdownMenuItem(
                                value: status, child: Text(status));
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedStatus = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border:
                        Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _updateUser(
                              user.id,
                              firstNameController.text,
                              lastNameController.text,
                              usernameController.text,
                              selectedRole,
                              selectedStatus,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Update'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateUser(
    int id,
    String firstName,
    String lastName,
    String username,
    String role,
    String status,
  ) async {
    try {
      await _userService.updateUser(
          id, firstName, lastName, username, role, status);
      _showSuccessSnackbar('User updated successfully');
      _loadUsers();
    } catch (e) {
      _showErrorSnackbar('Failed to update user: $e');
    }
  }

  void _showDeleteDialog(UserModel user) {
    if (user.status != 'INACTIVE') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Cannot Delete'),
            ],
          ),
          content: Text(
            'User "${user.firstname} ${user.lastname}" must be INACTIVE before deletion.\n\nCurrent status: ${user.status}\n\nPlease edit the user and set status to INACTIVE first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditDialog(user);
              },
              child: const Text('Edit User'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Confirm Deletion'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Are you sure you want to permanently delete this user?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstname} ${user.lastname}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Email: ${user.username}'),
                  Text('Role: ${user.role}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '⚠️ This action cannot be undone!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(int id) async {
    try {
      await _userService.deleteUser(id);
      _showSuccessSnackbar('User deleted successfully');
      _loadUsers();
    } catch (e) {
      _showErrorSnackbar('Failed to delete user: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.grey;
      case 'SUSPENDED':
        return Colors.orange;
      case 'BLOCKED':
        return Colors.red;
      case 'PENDING_VERIFICATION':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.purple;
      case 'AGENT':
        return Colors.blue;
      case 'SHAREHOLDER':
        return Colors.orange;
      case 'USER':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _filterUsers();
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        _buildFilterDropdown(
                          value: _filterRole,
                          label: 'Role',
                          items: [
                            'ALL',
                            'ADMIN',
                            'AGENT',
                            'SHAREHOLDER',
                            'USER'
                          ],
                          onChanged: (value) {
                            setState(() => _filterRole = value!);
                            _filterUsers();
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFilterDropdown(
                          value: _filterStatus,
                          label: 'Status',
                          items: [
                            'ALL',
                            'ACTIVE',
                            'INACTIVE',
                            'SUSPENDED',
                            'PENDING_VERIFICATION',
                            'BLOCKED'
                          ],
                          onChanged: (value) {
                            setState(() => _filterStatus = value!);
                            _filterUsers();
                          },
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildFilterDropdown(
                            value: _filterRole,
                            label: 'Role',
                            items: [
                              'ALL',
                              'ADMIN',
                              'AGENT',
                              'SHAREHOLDER',
                              'USER'
                            ],
                            onChanged: (value) {
                              setState(() => _filterRole = value!);
                              _filterUsers();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFilterDropdown(
                            value: _filterStatus,
                            label: 'Status',
                            items: [
                              'ALL',
                              'ACTIVE',
                              'INACTIVE',
                              'SUSPENDED',
                              'PENDING_VERIFICATION',
                              'BLOCKED'
                            ],
                            onChanged: (value) {
                              setState(() => _filterStatus = value!);
                              _filterUsers();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadUsers,
                          tooltip: 'Refresh',
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),

        // Users Count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Users: ${_filteredUsers.length}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : FadeTransition(
                      opacity: _animationController,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 800) {
                            return _buildMobileView();
                          } else {
                            return _buildDesktopView();
                          }
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.filter_list),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildMobileView() {
    return ListView.builder(
      itemCount: _filteredUsers.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          _getRoleColor(user.role).withOpacity(0.2),
                      child: Text(
                        user.firstname[0].toUpperCase(),
                        style: TextStyle(
                          color: _getRoleColor(user.role),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.firstname} ${user.lastname}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(user.username,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role,
                        style: TextStyle(
                          color: _getRoleColor(user.role),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(user.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.status,
                        style: TextStyle(
                          color: _getStatusColor(user.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.edit, size: 20, color: Colors.blue),
                      onPressed: () => _showEditDialog(user),
                      tooltip: 'Edit',
                    ),
                    if (_currentUserRole == 'ADMIN')
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 20,
                          color: user.status == 'INACTIVE'
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () => _showDeleteDialog(user),
                        tooltip: user.status == 'INACTIVE'
                            ? 'Delete'
                            : 'Set to INACTIVE first',
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(
                label: Text('Name',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Email',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Role',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Actions',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _filteredUsers.map((user) {
            return DataRow(
              cells: [
                DataCell(Text('${user.firstname} ${user.lastname}')),
                DataCell(Text(user.username)),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role,
                      style: TextStyle(
                        color: _getRoleColor(user.role),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(user.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.status,
                      style: TextStyle(
                        color: _getStatusColor(user.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue, size: 20),
                        onPressed: () => _showEditDialog(user),
                        tooltip: 'Edit',
                      ),
                      if (_currentUserRole == 'ADMIN')
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: user.status == 'INACTIVE'
                                ? Colors.red
                                : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => _showDeleteDialog(user),
                          tooltip: user.status == 'INACTIVE'
                              ? 'Delete'
                              : 'Set to INACTIVE first',
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
