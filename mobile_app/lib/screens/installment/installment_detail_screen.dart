// lib/pages/installment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/screens/installment/installment_model.dart';
import 'package:mobile_app/screens/installment/installment_service.dart';

class InstallmentDetailPage extends StatefulWidget {
  final int installmentId;

  const InstallmentDetailPage({
    Key? key,
    required this.installmentId,
  }) : super(key: key);

  @override
  State<InstallmentDetailPage> createState() => _InstallmentDetailPageState();
}

class _InstallmentDetailPageState extends State<InstallmentDetailPage> {
  final InstallmentService _installmentService = InstallmentService();
  InstallmentModel? _installment;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInstallment();
  }

  Future<void> _loadInstallment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final installment = await _installmentService.getInstallmentById(widget.installmentId);
      setState(() {
        _installment = installment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Installment Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Installment Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(_errorMessage, 
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInstallment,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_installment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Installment Details')),
        body: const Center(child: Text('Installment not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Installment Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInstallment,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Badge
          _buildStatusBadge(),
          const SizedBox(height: 24),

          // Member Information
          _buildSection(
            'Member Information',
            [
              _buildInfoRow('Name', _installment!.member?.name ?? 'N/A'),
              _buildInfoRow('Phone', _installment!.member?.phone ?? 'N/A'),
              _buildInfoRow('Village', _installment!.member?.village ?? 'N/A'),
              _buildInfoRow('Zila', _installment!.member?.zila ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),

          // Product Information
          _buildSection(
            'Product Information',
            [
              _buildInfoRow('Product', _installment!.product?.name ?? 'N/A'),
              _buildInfoRow('Category', _installment!.product?.category ?? 'N/A'),
              _buildInfoRow('Description', _installment!.product?.description ?? 'N/A'),
              _buildInfoRow('Price', '৳${_installment!.product?.price?.toStringAsFixed(2) ?? 'N/A'}'),
            ],
          ),
          const SizedBox(height: 16),

          // Financial Details
          _buildSection(
            'Financial Details',
            [
              _buildInfoRow('Total Amount', '৳${_installment!.totalAmountOfProduct.toStringAsFixed(2)}'),
              _buildInfoRow('Other Cost', '৳${_installment!.otherCost.toStringAsFixed(2)}'),
              _buildInfoRow('Advanced Paid', '৳${_installment!.advancedPaid.toStringAsFixed(2)}'),
              _buildInfoRow('Need to Pay', '৳${_installment!.needPaidAmount?.toStringAsFixed(2) ?? 'N/A'}'),
              _buildInfoRow('Total with Interest', '৳${_installment!.totalAmountWithInterest?.toStringAsFixed(2) ?? 'N/A'}'),
              _buildInfoRow('Monthly Payment', '৳${_installment!.monthlyInstallmentAmount?.toStringAsFixed(2) ?? 'N/A'}'),
            ],
          ),
          const SizedBox(height: 16),

          // Installment Terms
          _buildSection(
            'Installment Terms',
            [
              _buildInfoRow('Duration', '${_installment!.installmentMonths} months'),
              _buildInfoRow('Interest Rate', '${_installment!.interestRate}%'),
              _buildInfoRow('Agent', _installment!.givenProductAgent?.name ?? 'N/A'),
              _buildInfoRow('Created Date', _formatDate(_installment!.createdTime)),
            ],
          ),
          const SizedBox(height: 16),

          // Product Images
          if (_installment!.imageFilePaths != null && _installment!.imageFilePaths!.isNotEmpty) ...[
            _buildSection(
              'Product Images',
              [
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _installment!.imageFilePaths!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showImageDialog(_installment!.imageFilePaths![index]),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(_installment!.imageFilePaths![index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Payment Schedule
          if (_installment!.paymentSchedules != null && _installment!.paymentSchedules!.isNotEmpty) ...[
            _buildSection(
              'Payment Schedule',
              [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _installment!.paymentSchedules!.length,
                  itemBuilder: (context, index) {
                    final schedule = _installment!.paymentSchedules![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getScheduleStatusColor(schedule.status),
                          child: Text(
                            '${schedule.scheduleNumber}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text('৳${schedule.amountDue.toStringAsFixed(2)}'),
                        subtitle: Text('Due: ${_formatDate(schedule.dueDate)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              schedule.status,
                              style: TextStyle(
                                color: _getScheduleStatusColor(schedule.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (schedule.paidDate != null)
                              Text(
                                'Paid: ${_formatDate(schedule.paidDate)}',
                                style: const TextStyle(fontSize: 10),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(_installment!.status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Status: ${_installment!.status}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Image'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Padding(
                padding: EdgeInsets.all(32),
                child: Icon(Icons.image_not_supported, size: 100),
              ),
            ),
          ],
        ),
      ),
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

  Color _getScheduleStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'OVERDUE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }
}