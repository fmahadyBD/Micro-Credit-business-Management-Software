import 'package:flutter/material.dart';
import '../models/shareholder_model.dart';
import 'new_shareholder_page.dart';
import '../services/shareholder_service.dart';
import '../services/auth_service.dart';

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
  String _filterStatus = 'সব';
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
            _filterStatus == 'সব' || _getEnglishStatus(_filterStatus) == shareholder.status;
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
                      _buildDetailSection('ব্যক্তিগত তথ্য', [
                        _buildDetailRow('নাম', shareholder.name),
                        _buildDetailRow('ইমেইল', shareholder.email),
                        _buildDetailRow('ফোন', shareholder.phone),
                        _buildDetailRow('এনআইডি', shareholder.nidCard),
                        _buildDetailRow('ভূমিকা', shareholder.role),
                        _buildDetailRow(
                            'যোগদান তারিখ', shareholder.getFormattedJoinDate()),
                        _buildDetailRow('স্ট্যাটাস', _getBanglaStatus(shareholder.status)),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('ঠিকানা তথ্য', [
                        _buildDetailRow('জেলা', shareholder.zila),
                        _buildDetailRow('বাড়ির ঠিকানা', shareholder.house),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('মনোনীত ব্যক্তির তথ্য', [
                        _buildDetailRow('মনোনীত ব্যক্তির নাম', shareholder.nominee),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('আর্থিক তথ্য', [
                        _buildDetailRow(
                            'বিনিয়োগ', shareholder.getFormattedInvestment()),
                        _buildDetailRow(
                            'মোট শেয়ার', shareholder.totalShare.toString()),
                        _buildDetailRow('মোট আয়',
                            '৳${shareholder.totalEarning.toStringAsFixed(2)}'),
                        _buildDetailRow('বর্তমান ব্যালেন্স',
                            shareholder.getFormattedBalance()),
                        _buildDetailRow(
                            'রিটার্ন', '${shareholder.roi.toStringAsFixed(2)}%'),
                        _buildDetailRow('মোট মূল্য',
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
                        label: const Text('সম্পাদনা'),
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
                          label: const Text('ডিলিট'),
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
    String selectedStatus = _getBanglaStatus(shareholder.status);

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
                      const Text('শেয়ারহোল্ডার সম্পাদনা করুন',
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
                            labelText: 'পুরো নাম',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'ইমেইল',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'ফোন',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nidController,
                          decoration: const InputDecoration(
                            labelText: 'এনআইডি নম্বর',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: zilaController,
                          decoration: const InputDecoration(
                            labelText: 'জেলা',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: houseController,
                          decoration: const InputDecoration(
                            labelText: 'বাড়ির ঠিকানা',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: investmentController,
                          decoration: const InputDecoration(
                            labelText: 'বিনিয়োগের পরিমাণ',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: roleController,
                          decoration: const InputDecoration(
                            labelText: 'ভূমিকা',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'স্ট্যাটাস',
                            border: OutlineInputBorder(),
                          ),
                          items: ['সক্রিয়', 'নিষ্ক্রিয়'].map((status) {
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
                        const Text('মনোনীত ব্যক্তির তথ্য',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nomineeController,
                          decoration: const InputDecoration(
                            labelText: 'মনোনীত ব্যক্তির নাম',
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
                          child: const Text('বাতিল'),
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
                          child: const Text('আপডেট করুন'),
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
        status: _getEnglishStatus(status),
      );

      await _shareholderService.updateShareholder(id, updatedShareholder);

      _showSuccessSnackbar('শেয়ারহোল্ডার সফলভাবে আপডেট করা হয়েছে');
      _loadShareholders();
    } catch (e) {
      _showErrorSnackbar('শেয়ারহোল্ডার আপডেট করতে ব্যর্থ: $e');
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
              Text('ডিলিট করা যাবে না'),
            ],
          ),
          content: Text(
            'শেয়ারহোল্ডার "${shareholder.name}" এর ব্যালেন্স রয়েছে: ${shareholder.getFormattedBalance()}\n\nডিলিট করার আগে ব্যালেন্স ক্লিয়ার করুন।',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ঠিক আছে'),
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
            Text('ডিলিট নিশ্চিত করুন'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'আপনি কি এই শেয়ারহোল্ডারকে স্থায়ীভাবে ডিলিট করতে চান?'),
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
                  Text('ইমেইল: ${shareholder.email}'),
                  Text('ফোন: ${shareholder.phone}'),
                  Text('বিনিয়োগ: ${shareholder.getFormattedInvestment()}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '⚠️ এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
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
            child: const Text('ডিলিট'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteShareholder(int id) async {
    try {
      await _shareholderService.deleteShareholder(id);
      _showSuccessSnackbar('শেয়ারহোল্ডার সফলভাবে ডিলিট করা হয়েছে');
      _loadShareholders();
    } catch (e) {
      _showErrorSnackbar('শেয়ারহোল্ডার ডিলিট করতে ব্যর্থ: $e');
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

  String _getBanglaStatus(String englishStatus) {
    switch (englishStatus) {
      case 'Active':
        return 'সক্রিয়';
      case 'Inactive':
        return 'নিষ্ক্রিয়';
      default:
        return englishStatus;
    }
  }

  String _getEnglishStatus(String banglaStatus) {
    switch (banglaStatus) {
      case 'সক্রিয়':
        return 'Active';
      case 'নিষ্ক্রিয়':
        return 'Inactive';
      case 'সব':
        return 'ALL';
      default:
        return banglaStatus;
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
                        'শেয়ারহোল্ডার ব্যবস্থাপনা',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: _loadShareholders,
                        tooltip: 'রিফ্রেশ',
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
                          hintText: 'নাম, ইমেইল, ফোন, বা এনআইডি দিয়ে খুঁজুন...',
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
                        initialValue: _filterStatus,
                        decoration: InputDecoration(
                          labelText: 'স্ট্যাটাস',
                          prefixIcon: const Icon(Icons.filter_alt_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['সব', 'সক্রিয়', 'নিষ্ক্রিয়'].map((status) {
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
                        'মোট শেয়ারহোল্ডার: ${_filteredShareholders.length}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_shareholders.where((s) => s.status == 'Active').length} সক্রিয় • ${_shareholders.where((s) => s.status == 'Inactive').length} নিষ্ক্রিয়',
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
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('লোড হচ্ছে...'),
                      ],
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red.shade400),
                            const SizedBox(height: 16),
                            Text('ত্রুটি: $_errorMessage',
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadShareholders,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('আবার চেষ্টা করুন'),
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
                                      ? 'কোন শেয়ারহোল্ডার পাওয়া যায়নি'
                                      : 'মিলছে এমন কোন শেয়ারহোল্ডার নেই',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'আপনার প্রথম শেয়ারহোল্ডার যোগ করে শুরু করুন'
                                      : 'আপনার অনুসন্ধানের শর্ত সামঞ্জস্য করুন',
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
              label: const Text('বিনিয়োগ যোগ করুন'),
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
              label: const Text('নতুন শেয়ারহোল্ডার'),
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
                _getBanglaStatus(shareholder.status),
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
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            columns: const [
              DataColumn(
                  label: Text('আইডি',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('নাম',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('ইমেইল',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('ফোন',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('বিনিয়োগ',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('ব্যালেন্স',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('শেয়ার',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('যোগদান তারিখ',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('স্ট্যাটাস',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('কর্ম',
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
                        _getBanglaStatus(shareholder.status),
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
                          tooltip: 'বিস্তারিত দেখুন',
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              size: 18, color: Colors.orange.shade600),
                          onPressed: () => _showEditDialog(shareholder),
                          tooltip: 'সম্পাদনা',
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
                                ? 'ডিলিট'
                                : 'প্রথমে ব্যালেন্স ক্লিয়ার করুন',
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
                          'নতুন বিনিয়োগ যোগ করুন',
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
                          'শেয়ারহোল্ডার খুঁজুন',
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
                                  labelText: 'ইমেইল বা আইডি',
                                  hintText: 'ইমেইল বা শেয়ারহোল্ডার আইডি লিখুন',
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
                                              'দয়া করে ইমেইল বা আইডি লিখুন';
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
                                  Text(isSearching ? 'খুঁজছি...' : 'খুঁজুন'),
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
                                      'শেয়ারহোল্ডার পাওয়া গেছে',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow(
                                    'নাম', selectedShareholder!.name),
                                _buildInfoRow(
                                    'আইডি', '#${selectedShareholder!.id}'),
                                _buildInfoRow(
                                    'ইমেইল', selectedShareholder!.email),
                                _buildInfoRow(
                                    'ফোন', selectedShareholder!.phone),
                                _buildInfoRow(
                                  'বর্তমান বিনিয়োগ',
                                  selectedShareholder!.getFormattedInvestment(),
                                ),
                                _buildInfoRow(
                                  'বর্তমান ব্যালেন্স',
                                  selectedShareholder!.getFormattedBalance(),
                                ),
                                _buildInfoRow(
                                  'মোট শেয়ার',
                                  selectedShareholder!.totalShare.toString(),
                                ),
                                _buildInfoRow(
                                  'স্ট্যাটাস',
                                  _getBanglaStatus(selectedShareholder!.status),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 24),

                          // Investment Details
                          const Text(
                            'বিনিয়োগের বিবরণ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: amountController,
                            decoration: InputDecoration(
                              labelText: 'পরিমাণ (৳)',
                              hintText: 'বিনিয়োগের পরিমাণ লিখুন',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              helperText: 'সাজেস্টেড: ৳1000',
                            ),
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 16),

                          TextField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: 'বিবরণ',
                              hintText: 'বিনিয়োগের বিবরণ লিখুন',
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
                          child: const Text('বাতিল'),
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
                                          'দয়া করে একটি বৈধ পরিমাণ লিখুন';
                                    });
                                    return;
                                  }

                                  if (description.isEmpty) {
                                    setDialogState(() {
                                      searchError =
                                          'দয়া করে একটি বিবরণ লিখুন';
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
                          child: const Text('বিনিয়োগ যোগ করুন'),
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
      _showSuccessSnackbar('বিনিয়োগ সফলভাবে যোগ করা হয়েছে!');
      _loadShareholders();
    } catch (e) {
      _showErrorSnackbar('বিনিয়োগ যোগ করতে ব্যর্থ: $e');
    }
  }
}