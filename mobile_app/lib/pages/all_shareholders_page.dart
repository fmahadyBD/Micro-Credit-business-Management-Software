import 'package:flutter/material.dart';
import 'package:mobile_app/models/shareholder_model.dart';
import 'package:mobile_app/pages/new_shareholder_page.dart';
import 'package:mobile_app/services/shareholder_service.dart';
import 'package:mobile_app/services/auth_service.dart';

class AllShareholdersPage extends StatefulWidget {
  const AllShareholdersPage({super.key});

  @override
  State<AllShareholdersPage> createState() => _AllShareholdersPageState();
}

class _AllShareholdersPageState extends State<AllShareholdersPage>
    with SingleTickerProviderStateMixin {
  final ShareholderService _shareholderService = ShareholderService();
  final AuthService _authService = AuthService();
  List<ShareholderModel> _shareholders = [];
  List<ShareholderModel> _filteredShareholders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _filterStatus = 'ALL';
  String? _currentUserRole;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadShareholders();
    _loadUserRole();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    setState(() {
      _currentUserRole = 'ADMIN';
    });
  }

  Future<void> _loadShareholders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final shareholders = await _shareholderService.getAllShareholders();
      setState(() {
        _shareholders = shareholders;
        _filteredShareholders = shareholders;
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

  void _filterShareholders() {
    setState(() {
      _filteredShareholders = _shareholders.where((shareholder) {
        final matchesSearch = shareholder.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            shareholder.email
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            shareholder.phone.contains(_searchQuery) ||
            shareholder.nidCard.contains(_searchQuery);
        final matchesStatus =
            _filterStatus == 'ALL' || shareholder.status == _filterStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _showShareholderDetails(ShareholderModel shareholder) {
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        shareholder.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                        _buildDetailRow('Name', shareholder.name),
                        _buildDetailRow('Email', shareholder.email),
                        _buildDetailRow('Phone', shareholder.phone),
                        _buildDetailRow('NID', shareholder.nidCard),
                        _buildDetailRow('Role', shareholder.role),
                        _buildDetailRow(
                            'Join Date', shareholder.getFormattedJoinDate()),
                        _buildDetailRow('Status', shareholder.status),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Address Information', [
                        _buildDetailRow('District', shareholder.zila),
                        _buildDetailRow('House Address', shareholder.house),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Nominee Information', [
                        _buildDetailRow('Nominee Name', shareholder.nominee),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Financial Information', [
                        _buildDetailRow(
                            'Investment', shareholder.getFormattedInvestment()),
                        _buildDetailRow(
                            'Total Shares', shareholder.totalShare.toString()),
                        _buildDetailRow('Total Earnings',
                            '৳${shareholder.totalEarning.toStringAsFixed(2)}'),
                        _buildDetailRow('Current Balance',
                            shareholder.getFormattedBalance()),
                        _buildDetailRow(
                            'ROI', '${shareholder.roi.toStringAsFixed(2)}%'),
                        _buildDetailRow('Total Value',
                            shareholder.getFormattedTotalValue()),
                      ]),
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
                          _showEditDialog(shareholder);
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
                            _handleDelete(shareholder);
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
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            width: 120,
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

  void _showEditDialog(ShareholderModel shareholder) {
    final nameController = TextEditingController(text: shareholder.name);
    final emailController = TextEditingController(text: shareholder.email);
    final phoneController = TextEditingController(text: shareholder.phone);
    final nidController = TextEditingController(text: shareholder.nidCard);
    final nomineeController = TextEditingController(text: shareholder.nominee);
    final zilaController = TextEditingController(text: shareholder.zila);
    final houseController = TextEditingController(text: shareholder.house);
    final investmentController =
        TextEditingController(text: shareholder.investment.toString());
    final roleController = TextEditingController(text: shareholder.role);
    String selectedStatus = shareholder.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                      const Icon(Icons.edit, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Text('Edit Shareholder',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
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
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
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
                          controller: nidController,
                          decoration: const InputDecoration(
                            labelText: 'NID Card Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: zilaController,
                          decoration: const InputDecoration(
                            labelText: 'District',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: houseController,
                          decoration: const InputDecoration(
                            labelText: 'House Address',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: investmentController,
                          decoration: const InputDecoration(
                            labelText: 'Investment Amount',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: roleController,
                          decoration: const InputDecoration(
                            labelText: 'Role',
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
                          items: ['Active', 'Inactive'].map((status) {
                            return DropdownMenuItem(
                                value: status, child: Text(status));
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedStatus = value!);
                          },
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text('Nominee Information',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nomineeController,
                          decoration: const InputDecoration(
                            labelText: 'Nominee Name',
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
                            await _updateShareholder(
                              shareholder.id,
                              nameController.text,
                              emailController.text,
                              phoneController.text,
                              nidController.text,
                              nomineeController.text,
                              zilaController.text,
                              houseController.text,
                              double.tryParse(investmentController.text) ??
                                  shareholder.investment,
                              roleController.text,
                              selectedStatus,
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

  Future<void> _updateShareholder(
    int id,
    String name,
    String email,
    String phone,
    String nid,
    String nominee,
    String zila,
    String house,
    double investment,
    String role,
    String status,
  ) async {
    try {
      final shareholder = _shareholders.firstWhere((s) => s.id == id);
      final updatedShareholder = shareholder.copyWith(
        name: name,
        email: email,
        phone: phone,
        nidCard: nid,
        nominee: nominee,
        zila: zila,
        house: house,
        investment: investment,
        role: role,
        status: status,
      );

      await _shareholderService.updateShareholder(id, updatedShareholder);

      _showSuccessSnackbar('Shareholder updated successfully');
      _loadShareholders();
    } catch (e) {
      _showErrorSnackbar('Failed to update shareholder: $e');
    }
  }

  void _handleDelete(ShareholderModel shareholder) {
    if (shareholder.currentBalance > 0) {
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
            'Shareholder "${shareholder.name}" has outstanding balance: ${shareholder.getFormattedBalance()}\n\nPlease clear the balance before deletion.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
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
                'Are you sure you want to permanently delete this shareholder?'),
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
                  Text(shareholder.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Email: ${shareholder.email}'),
                  Text('Phone: ${shareholder.phone}'),
                  Text('Investment: ${shareholder.getFormattedInvestment()}'),
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
              await _deleteShareholder(shareholder.id);
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

  Future<void> _deleteShareholder(int id) async {
    try {
      await _shareholderService.deleteShareholder(id);
      _showSuccessSnackbar('Shareholder deleted successfully');
      _loadShareholders();
    } catch (e) {
      _showErrorSnackbar('Failed to delete shareholder: $e');
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
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(20),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.people_outline,
                          color: Colors.blue.shade700, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Shareholders Management',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: _loadShareholders,
                        tooltip: 'Refresh',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          _filterShareholders();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, phone, or NID...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          prefixIcon: const Icon(Icons.filter_alt_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['ALL', 'Active', 'Inactive'].map((status) {
                          return DropdownMenuItem(
                              value: status, child: Text(status));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _filterStatus = value!);
                          _filterShareholders();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Shareholders Count and Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Shareholders: ${_filteredShareholders.length}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_shareholders.where((s) => s.status == 'Active').length} Active • ${_shareholders.where((s) => s.status == 'Inactive').length} Inactive',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Shareholders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red.shade400),
                            const SizedBox(height: 16),
                            Text('Error: $_errorMessage',
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadShareholders,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredShareholders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 80, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No shareholders found'
                                      : 'No matching shareholders',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Add your first shareholder to get started'
                                      : 'Try adjusting your search criteria',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 768) {
                                  return _buildMobileView();
                                } else {
                                  return _buildDesktopView();
                                }
                              },
                            ),
                          ),
          ),
        ],
      ),

      // // Floating Action Button for New Shareholder
      // floatingActionButton: ScaleTransition(
      //   scale: _fadeAnimation,
      //   child: FloatingActionButton.extended(
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => const NewShareholderPage()),
      //       ).then((_) => _loadShareholders());
      //     },
      //     backgroundColor: Colors.blue.shade700,
      //     foregroundColor: Colors.white,
      //     elevation: 4,
      //     icon: const Icon(Icons.person_add_alt_1),
      //     label: const Text('New Shareholder'),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Add this button next to the "New Shareholder" button
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ScaleTransition(
            scale: _fadeAnimation,
            child: FloatingActionButton.extended(
              onPressed: _showAddInvestmentDialog,
              heroTag: 'add_investment',
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_card),
              label: const Text('Add Investment'),
            ),
          ),
          const SizedBox(height: 12),
          ScaleTransition(
            scale: _fadeAnimation,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NewShareholderPage()),
                ).then((_) => _loadShareholders());
              },
              heroTag: 'new_shareholder',
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('New Shareholder'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    return ListView.builder(
      itemCount: _filteredShareholders.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final shareholder = _filteredShareholders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  _getStatusColor(shareholder.status).withOpacity(0.2),
              child: Icon(
                Icons.person_outline,
                color: _getStatusColor(shareholder.status),
                size: 20,
              ),
            ),
            title: Text(
              shareholder.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  shareholder.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${shareholder.phone} • ${shareholder.getFormattedInvestment()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(shareholder.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                shareholder.status,
                style: TextStyle(
                  color: _getStatusColor(shareholder.status),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () => _showShareholderDetails(shareholder),
          ),
        );
      },
    );
  }

  Widget _buildDesktopView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            columns: const [
              DataColumn(
                  label: Text('ID',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Name',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Email',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Phone',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Investment',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Balance',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Shares',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Join Date',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Status',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Actions',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _filteredShareholders.map((shareholder) {
              return DataRow(
                cells: [
                  DataCell(Text('#${shareholder.id}')),
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getStatusColor(shareholder.status)
                              .withOpacity(0.2),
                          radius: 16,
                          child: Icon(
                            Icons.person_outline,
                            color: _getStatusColor(shareholder.status),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(shareholder.name),
                      ],
                    ),
                    onTap: () => _showShareholderDetails(shareholder),
                  ),
                  DataCell(Text(shareholder.email)),
                  DataCell(Text(shareholder.phone)),
                  DataCell(Text(shareholder.getFormattedInvestment())),
                  DataCell(Text(shareholder.getFormattedBalance())),
                  DataCell(Text(shareholder.totalShare.toString())),
                  DataCell(Text(shareholder.getFormattedJoinDate())),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(shareholder.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        shareholder.status,
                        style: TextStyle(
                          color: _getStatusColor(shareholder.status),
                          fontWeight: FontWeight.w600,
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
                          icon: Icon(Icons.visibility_outlined,
                              size: 18, color: Colors.blue.shade600),
                          onPressed: () => _showShareholderDetails(shareholder),
                          tooltip: 'View Details',
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              size: 18, color: Colors.orange.shade600),
                          onPressed: () => _showEditDialog(shareholder),
                          tooltip: 'Edit',
                        ),
                        if (_currentUserRole == 'ADMIN')
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: shareholder.currentBalance == 0
                                  ? Colors.red.shade600
                                  : Colors.grey.shade400,
                            ),
                            onPressed: shareholder.currentBalance == 0
                                ? () => _handleDelete(shareholder)
                                : null,
                            tooltip: shareholder.currentBalance == 0
                                ? 'Delete'
                                : 'Clear balance first',
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Add this method to _AllShareholdersPageState class

  void _showAddInvestmentDialog() {
    final searchController = TextEditingController();
    final amountController = TextEditingController(text: '1000');
    final descriptionController = TextEditingController();
    ShareholderModel? selectedShareholder;
    bool isSearching = false;
    String searchError = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade500],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_card, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Add New Investment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Section
                        const Text(
                          'Search Shareholder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  labelText: 'Email or ID',
                                  hintText: 'Enter email or shareholder ID',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorText:
                                      searchError.isEmpty ? null : searchError,
                                ),
                                onChanged: (value) {
                                  setDialogState(() {
                                    searchError = '';
                                    selectedShareholder = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: isSearching
                                  ? null
                                  : () async {
                                      final query =
                                          searchController.text.trim();
                                      if (query.isEmpty) {
                                        setDialogState(() {
                                          searchError =
                                              'Please enter email or ID';
                                        });
                                        return;
                                      }

                                      setDialogState(() {
                                        isSearching = true;
                                        searchError = '';
                                        selectedShareholder = null;
                                      });

                                      try {
                                        ShareholderModel? shareholder;

                                        // Try to parse as ID first
                                        final id = int.tryParse(query);
                                        if (id != null) {
                                          shareholder =
                                              await _shareholderService
                                                  .getShareholderById(id);
                                        } else {
                                          // Search by email
                                          shareholder =
                                              await _shareholderService
                                                  .getShareholderByEmail(query);
                                        }

                                        setDialogState(() {
                                          selectedShareholder = shareholder;
                                          isSearching = false;
                                        });
                                      } catch (e) {
                                        setDialogState(() {
                                          searchError = e
                                              .toString()
                                              .replaceAll('Exception: ', '');
                                          isSearching = false;
                                        });
                                      }
                                    },
                              icon: isSearching
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.search),
                              label:
                                  Text(isSearching ? 'Searching...' : 'Search'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Shareholder Details (if found)
                        if (selectedShareholder != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade700,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Shareholder Found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow(
                                    'Name', selectedShareholder!.name),
                                _buildInfoRow(
                                    'ID', '#${selectedShareholder!.id}'),
                                _buildInfoRow(
                                    'Email', selectedShareholder!.email),
                                _buildInfoRow(
                                    'Phone', selectedShareholder!.phone),
                                _buildInfoRow(
                                  'Current Investment',
                                  selectedShareholder!.getFormattedInvestment(),
                                ),
                                _buildInfoRow(
                                  'Current Balance',
                                  selectedShareholder!.getFormattedBalance(),
                                ),
                                _buildInfoRow(
                                  'Total Shares',
                                  selectedShareholder!.totalShare.toString(),
                                ),
                                _buildInfoRow(
                                  'Status',
                                  selectedShareholder!.status,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 24),

                          // Investment Details
                          const Text(
                            'Investment Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: amountController,
                            decoration: InputDecoration(
                              labelText: 'Amount (৳)',
                              hintText: 'Enter investment amount',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              helperText: 'Suggested: ৳1000',
                            ),
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 16),

                          TextField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter investment description',
                              prefixIcon: const Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Footer Actions
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
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedShareholder == null
                              ? null
                              : () async {
                                  final amount =
                                      double.tryParse(amountController.text);
                                  final description =
                                      descriptionController.text.trim();

                                  if (amount == null || amount <= 0) {
                                    setDialogState(() {
                                      searchError =
                                          'Please enter a valid amount';
                                    });
                                    return;
                                  }

                                  if (description.isEmpty) {
                                    setDialogState(() {
                                      searchError =
                                          'Please enter a description';
                                    });
                                    return;
                                  }

                                  Navigator.pop(context);
                                  await _addInvestment(
                                    selectedShareholder!.id,
                                    amount,
                                    description,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Add Investment'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addInvestment(
      int shareholderId, double amount, String description) async {
    try {
      await _shareholderService.addInvestment(
          shareholderId, amount, description);
      _showSuccessSnackbar('Investment added successfully!');
      _loadShareholders();
    } catch (e) {
      _showErrorSnackbar('Failed to add investment: $e');
    }
  }
}
