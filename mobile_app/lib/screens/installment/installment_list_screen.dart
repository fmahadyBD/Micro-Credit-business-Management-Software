// lib/screens/installment/installment_list_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/screens/installment/installment_add_screen.dart';
import 'package:mobile_app/screens/installment/installment_edit_screen.dart';
import 'package:mobile_app/screens/installment/installment_detail_screen.dart';
import 'package:mobile_app/screens/installment/installment_model.dart';
import 'package:mobile_app/screens/installment/installment_service.dart';

class InstallmentListScreen extends StatefulWidget {
  const InstallmentListScreen({Key? key}) : super(key: key);

  @override
  State<InstallmentListScreen> createState() => _InstallmentListScreenState();
}

class _InstallmentListScreenState extends State<InstallmentListScreen> {
  final InstallmentService _installmentService = InstallmentService();
  List<InstallmentModel> _installments = [];
  List<InstallmentModel> _filteredInstallments = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInstallments();
  }

  Future<void> _loadInstallments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final installments = await _installmentService.getAllInstallments();
      setState(() {
        _installments = installments;
        _filteredInstallments = installments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _searchInstallments(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredInstallments = _installments;
      });
      return;
    }

    setState(() {
      _filteredInstallments = _installments.where((installment) {
        final memberName = installment.member?.name?.toLowerCase() ?? '';
        final productName = installment.product?.name?.toLowerCase() ?? '';
        final phone = installment.member?.phone?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        
        return memberName.contains(searchLower) ||
               productName.contains(searchLower) ||
               phone.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _performSearch(String keyword) async {
    if (keyword.trim().isEmpty) {
      _loadInstallments();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _installmentService.searchInstallments(keyword);
      setState(() {
        _filteredInstallments = results;
        _isLoading = false;
      });

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No installments found')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteInstallment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this installment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _installmentService.deleteInstallment(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Installment deleted successfully')),
        );
        _loadInstallments();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInstallments,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by member, product, or phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadInstallments();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchInstallments,
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadInstallments,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredInstallments.isEmpty
                        ? const Center(child: Text('No installments found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredInstallments.length,
                            itemBuilder: (context, index) {
                              final installment = _filteredInstallments[index];
                              return _buildInstallmentCard(installment);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InstallmentAddScreen(),
            ),
          );
          if (result == true) {
            _loadInstallments();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Installment'),
      ),
    );
  }

  Widget _buildInstallmentCard(InstallmentModel installment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        installment.member?.name ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        installment.product?.name ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(installment.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    installment.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    'Total Amount',
                    '৳${installment.totalAmountOfProduct.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    'Advance Paid',
                    '৳${installment.advancedPaid.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    'Monthly',
                    '৳${installment.monthlyInstallmentAmount?.toStringAsFixed(2) ?? 'N/A'}',
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    'Duration',
                    '${installment.installmentMonths} months',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    'Interest Rate',
                    '${installment.interestRate}%',
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    'Agent',
                    installment.givenProductAgent?.name ?? 'N/A',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InstallmentDetailPage(
                          installmentId: installment.id!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Details'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InstallmentEditScreen(
                          installment: installment,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadInstallments();
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _deleteInstallment(installment.id!),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'COMPLETED':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'OVERDUE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}