// lib/pages/all_members_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/models/member_model.dart';
import 'package:mobile_app/services/member_service.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/models/user_model.dart';

class AllMembersPage extends StatefulWidget {
  const AllMembersPage({super.key});

  @override
  State<AllMembersPage> createState() => _AllMembersPageState();
}

class _AllMembersPageState extends State<AllMembersPage> with SingleTickerProviderStateMixin {
  final MemberService _memberService = MemberService();
  final AuthService _authService = AuthService();
  List<MemberModel> _members = [];
  List<MemberModel> _filteredMembers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _filterStatus = 'ALL';
  String? _currentUserRole;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadMembers();
    _loadUserRole();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    // Implement getting current user's role from your auth service
    // For now, setting a default. Replace with actual implementation
    setState(() {
      _currentUserRole = 'ADMIN'; // Replace with actual role from auth service
    });
  }

  Future<void> _loadMembers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final members = await _memberService.getAllMembers();
      setState(() {
        _members = members;
        _filteredMembers = members;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterMembers() {
    setState(() {
      _filteredMembers = _members.where((member) {
        final matchesSearch = member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            member.phone.contains(_searchQuery) ||
            member.nidCardNumber.contains(_searchQuery);
        final matchesStatus = _filterStatus == 'ALL' || member.status == _filterStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _showMemberDetails(MemberModel member) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        member.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Personal Information', [
                        _buildDetailRow('Name', member.name),
                        _buildDetailRow('Phone', member.phone),
                        _buildDetailRow('Zila', member.zila),
                        _buildDetailRow('Village', member.village),
                        _buildDetailRow('NID', member.nidCardNumber),
                        _buildDetailRow('Join Date', member.getFormattedJoinDate()),
                        _buildDetailRow('Status', member.status),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Nominee Information', [
                        _buildDetailRow('Name', member.nomineeName),
                        _buildDetailRow('Phone', member.nomineePhone),
                        _buildDetailRow('NID', member.nomineeNidCardNumber),
                      ]),
                      const SizedBox(height: 16),
                      const Text('Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (member.photoPath != null) _buildImagePreview('Photo', member.photoPath!),
                      if (member.nidCardImagePath != null) _buildImagePreview('NID Card', member.nidCardImagePath!),
                      if (member.nomineeNidCardImagePath != null) _buildImagePreview('Nominee NID', member.nomineeNidCardImagePath!),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDialog(member);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_currentUserRole == 'ADMIN')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleDelete(member);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String title, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _memberService.getImageUrl(imagePath),
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showEditDialog(MemberModel member) {
    final nameController = TextEditingController(text: member.name);
    final phoneController = TextEditingController(text: member.phone);
    final zilaController = TextEditingController(text: member.zila);
    final villageController = TextEditingController(text: member.village);
    final nidController = TextEditingController(text: member.nidCardNumber);
    final nomineeNameController = TextEditingController(text: member.nomineeName);
    final nomineePhoneController = TextEditingController(text: member.nomineePhone);
    final nomineeNidController = TextEditingController(text: member.nomineeNidCardNumber);
    String selectedStatus = member.status;

    XFile? newNidCardImage;
    XFile? newPhoto;
    XFile? newNomineeNidImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Text('Edit Member', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
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
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: zilaController,
                          decoration: const InputDecoration(
                            labelText: 'Zila',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: villageController,
                          decoration: const InputDecoration(
                            labelText: 'Village',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nidController,
                          decoration: const InputDecoration(
                            labelText: 'NID Card Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: ['ACTIVE', 'INACTIVE', 'SUSPENDED'].map((status) {
                            return DropdownMenuItem(value: status, child: Text(status));
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedStatus = value!);
                          },
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text('Nominee Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nomineeNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nominee Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nomineePhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Nominee Phone',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nomineeNidController,
                          decoration: const InputDecoration(
                            labelText: 'Nominee NID',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
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
                            await _updateMember(
                              member.id,
                              nameController.text,
                              phoneController.text,
                              zilaController.text,
                              villageController.text,
                              nidController.text,
                              nomineeNameController.text,
                              nomineePhoneController.text,
                              nomineeNidController.text,
                              selectedStatus,
                              newNidCardImage,
                              newPhoto,
                              newNomineeNidImage,
                            );
                          },
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

  Future<void> _updateMember(
    int id,
    String name,
    String phone,
    String zila,
    String village,
    String nid,
    String nomineeName,
    String nomineePhone,
    String nomineeNid,
    String status,
    XFile? nidImage,
    XFile? photo,
    XFile? nomineeNidImage,
  ) async {
    try {
      final member = _members.firstWhere((m) => m.id == id);
      final updatedMember = member.copyWith(
        name: name,
        phone: phone,
        zila: zila,
        village: village,
        nidCardNumber: nid,
        nomineeName: nomineeName,
        nomineePhone: nomineePhone,
        nomineeNidCardNumber: nomineeNid,
        status: status,
      );

      await _memberService.updateMemberWithImages(
        id: id,
        member: updatedMember,
        nidCardImage: nidImage != null
            ? await MemberService.createMultipartFile(
                'nidCardImage',
                await nidImage.readAsBytes(),
                nidImage.name,
              )
            : null,
        photo: photo != null
            ? await MemberService.createMultipartFile(
                'photo',
                await photo.readAsBytes(),
                photo.name,
              )
            : null,
        nomineeNidCardImage: nomineeNidImage != null
            ? await MemberService.createMultipartFile(
                'nomineeNidCardImage',
                await nomineeNidImage.readAsBytes(),
                nomineeNidImage.name,
              )
            : null,
      );

      _showSuccessSnackbar('Member updated successfully');
      _loadMembers();
    } catch (e) {
      _showErrorSnackbar('Failed to update member: $e');
    }
  }

  void _handleDelete(MemberModel member) {
    if (member.status != 'INACTIVE') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Cannot Delete'),
            ],
          ),
          content: Text(
            'Member "${member.name}" must be INACTIVE before deletion.\n\nCurrent status: ${member.status}\n\nPlease edit the member and set status to INACTIVE first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditDialog(member);
              },
              child: const Text('Edit Member'),
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
            const Text('Are you sure you want to permanently delete this member?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Phone: ${member.phone}'),
                  Text('NID: ${member.nidCardNumber}'),
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
              await _deleteMember(member.id);
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

  Future<void> _deleteMember(int id) async {
    try {
      await _memberService.deleteMember(id);
      _showSuccessSnackbar('Member deleted successfully');
      _loadMembers();
    } catch (e) {
      _showErrorSnackbar('Failed to delete member: $e');
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
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Section
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
                  _filterMembers();
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, phone, or NID...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filterStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        prefixIcon: const Icon(Icons.filter_list),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['ALL', 'ACTIVE', 'INACTIVE', 'SUSPENDED'].map((status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _filterStatus = value!);
                        _filterMembers();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadMembers,
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ],
          ),
        ),
        // Members Count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Members: ${_filteredMembers.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        // Members List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: $_errorMessage'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadMembers,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filteredMembers.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No members found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        )
                      : FadeTransition(
                          opacity: _animationController,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 600) {
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

  Widget _buildMobileView() {
    return ListView.builder(
      itemCount: _filteredMembers.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final member = _filteredMembers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(member.status).withOpacity(0.2),
              child: Text(
                member.name[0].toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(member.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.phone),
                Text('${member.zila}, ${member.village}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(member.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                member.status,
                style: TextStyle(
                  color: _getStatusColor(member.status),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => _showMemberDetails(member),
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
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('NID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Join Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _filteredMembers.map((member) {
            return DataRow(
              cells: [
                DataCell(Text('#${member.id}')),
                DataCell(
                  Text(member.name),
                  onTap: () => _showMemberDetails(member),
                ),
                DataCell(Text(member.phone)),
                DataCell(Text('${member.zila}, ${member.village}')),
                DataCell(Text(member.nidCardNumber)),
                DataCell(Text(member.getFormattedJoinDate())),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(member.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      member.status,
                      style: TextStyle(
                        color: _getStatusColor(member.status),
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
                        icon: const Icon(Icons.visibility, size: 18),
                        onPressed: () => _showMemberDetails(member),
                        tooltip: 'View',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                        onPressed: () => _showEditDialog(member),
                        tooltip: 'Edit',
                      ),
                      if (_currentUserRole == 'ADMIN')
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: member.status == 'INACTIVE' ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                          onPressed: () => _handleDelete(member),
                          tooltip: member.status == 'INACTIVE' ? 'Delete' : 'Set to INACTIVE first',
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