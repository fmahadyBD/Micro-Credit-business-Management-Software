// lib/pages/installment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'installment_model.dart';
import 'installment_service.dart';

class InstallmentDetailPage extends StatefulWidget {
  final int installmentId;

  const InstallmentDetailPage({
    super.key,
    required this.installmentId,
  });

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
      
      // Debug: Print image URLs
      if (installment.imageFilePaths.isNotEmpty) {
        print('📸 Installment images found: ${installment.imageFilePaths.length}');
        for (int i = 0; i < installment.imageFilePaths.length; i++) {
          final imageUrl = _installmentService.getImageUrl(installment.imageFilePaths[i]);
          print('  Image $i: $imageUrl');
          
          // Test if image is accessible
          final isAccessible = await _installmentService.testImageUrl(installment.imageFilePaths[i]);
          print('  Accessible: $isAccessible');
        }
      } else {
        print('📸 No installment images found');
      }
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
        appBar: AppBar(title: const Text('কিস্তির বিবরণ')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('লোড হচ্ছে...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('কিস্তির বিবরণ')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'ত্রুটি: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInstallment,
                child: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      );
    }

    if (_installment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('কিস্তির বিবরণ')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('কিস্তি পাওয়া যায়নি'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('কিস্তির বিবরণ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInstallment,
            tooltip: 'রিফ্রেশ করুন',
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
            'সদস্যের তথ্য',
            [
              _buildInfoRow('নাম', _installment!.member?.name ?? 'নেই'),
              _buildInfoRow('ফোন', _installment!.member?.phone ?? 'নেই'),
              _buildInfoRow('গ্রাম', _installment!.member?.village ?? 'নেই'),
              _buildInfoRow('জেলা', _installment!.member?.zila ?? 'নেই'),
            ],
          ),
          const SizedBox(height: 16),

          // Product Information
          _buildSection(
            'পণ্যের তথ্য',
            [
              _buildInfoRow('পণ্যের নাম', _installment!.product?.name ?? 'নেই'),
              _buildInfoRow('ধরন', _installment!.product?.category ?? 'নেই'),
              _buildInfoRow('বিবরণ', _installment!.product?.description ?? 'বিবরণ নেই'),
              _buildInfoRow('দাম', '৳${_installment!.product?.price.toStringAsFixed(2) ?? 'নেই'}'),
            ],
          ),
          const SizedBox(height: 16),

          // Financial Details
          _buildSection(
            'আর্থিক বিবরণ',
            [
              _buildInfoRow('মোট টাকার পরিমাণ', '৳${_installment!.totalAmountOfProduct.toStringAsFixed(2)}'),
              _buildInfoRow('অন্যান্য খরচ', '৳${_installment!.otherCost.toStringAsFixed(2)}'),
              _buildInfoRow('অগ্রিম প্রদত্ত', '৳${_installment!.advancedPaid.toStringAsFixed(2)}'),
              _buildInfoRow('পরিশোধ করতে হবে', '৳${_installment!.needPaidAmount?.toStringAsFixed(2) ?? 'নেই'}'),
              _buildInfoRow('সুদসহ মোট', '৳${_installment!.totalAmountWithInterest?.toStringAsFixed(2) ?? 'নেই'}'),
              _buildInfoRow('মাসিক কিস্তি', '৳${_installment!.monthlyInstallmentAmount?.toStringAsFixed(2) ?? 'নেই'}'),
            ],
          ),
          const SizedBox(height: 16),

          // Installment Terms
          _buildSection(
            'কিস্তির শর্তাবলী',
            [
              _buildInfoRow('মেয়াদ', '${_installment!.installmentMonths} মাস'),
              _buildInfoRow('সুদ হার', '${_installment!.interestRate}%'),
              _buildInfoRow('এজেন্ট', _installment!.givenProductAgent?.name ?? 'নেই'),
              _buildInfoRow('তৈরির তারিখ', _formatDate(_installment!.createdTime)),
            ],
          ),
          const SizedBox(height: 16),

          // Product Images - FIXED: Use getImageUrl() method
          if (_installment!.imageFilePaths.isNotEmpty) ...[
            _buildSection(
              'কিস্তির ডকুমেন্ট',
              [
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _installment!.imageFilePaths.length,
                    itemBuilder: (context, index) {
                      // Use getImageUrl() to convert path to full URL
                      final imageUrl = _installmentService.getImageUrl(_installment!.imageFilePaths[index]);
                      
                      return GestureDetector(
                        onTap: () => _showImageDialog(imageUrl),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Failed to load image: $imageUrl');
                                print('Error: $error');
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'লোড করতে ব্যর্থ',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_installment!.imageFilePaths.length}টি ডকুমেন্ট',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Payment Schedule
          if (_installment!.paymentSchedules.isNotEmpty) ...[
            _buildSection(
              'পরিশোধের সময়সূচী',
              [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _installment!.paymentSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _installment!.paymentSchedules[index];
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
                        subtitle: Text('পরিশোধের তারিখ: ${_formatDate(schedule.dueDate)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getBanglaStatus(schedule.status),
                              style: TextStyle(
                                color: _getScheduleStatusColor(schedule.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (schedule.paidDate != null)
                              Text(
                                'পরিশোধ: ${_formatDate(schedule.paidDate)}',
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
            'স্ট্যাটাস: ${_getBanglaStatus(_installment!.status)}',
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
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('ডকুমেন্ট ছবি'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'ছবি লোড করতে ব্যর্থ',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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

  String _getBanglaStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'চলমান';
      case 'COMPLETED':
        return 'সম্পন্ন';
      case 'PENDING':
        return 'বিচারাধীন';
      case 'OVERDUE':
        return 'মেয়াদোত্তীর্ণ';
      case 'PAID':
        return 'পরিশোধিত';
      default:
        return status;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'নেই';
    return DateFormat('MMM dd, yyyy').format(date);
  }
}