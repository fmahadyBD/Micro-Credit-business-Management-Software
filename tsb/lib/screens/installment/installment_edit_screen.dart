// lib/screens/installment/installment_edit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'installment_model.dart';
import 'installment_service.dart';
import 'package:http/http.dart' as http;

class InstallmentEditScreen extends StatefulWidget {
  final InstallmentModel installment;

  const InstallmentEditScreen({
    super.key,
    required this.installment,
  });

  @override
  State<InstallmentEditScreen> createState() => _InstallmentEditScreenState();
}

class _InstallmentEditScreenState extends State<InstallmentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final InstallmentService _installmentService = InstallmentService();
  final ImagePicker _imagePicker = ImagePicker();
  
  late TextEditingController _totalAmountController;
  late TextEditingController _otherCostController;
  late TextEditingController _advancedPaidController;
  late TextEditingController _installmentMonthsController;
  late TextEditingController _interestRateController;
  
  late String _selectedStatus;
  bool _isLoading = false;
  
  // Image management
  final List<File> _selectedImages = [];
  final List<String> _imagesToDelete = [];

  @override
  void initState() {
    super.initState();
    _totalAmountController = TextEditingController(
      text: widget.installment.totalAmountOfProduct.toString(),
    );
    _otherCostController = TextEditingController(
      text: widget.installment.otherCost.toString(),
    );
    _advancedPaidController = TextEditingController(
      text: widget.installment.advancedPaid.toString(),
    );
    _installmentMonthsController = TextEditingController(
      text: widget.installment.installmentMonths.toString(),
    );
    _interestRateController = TextEditingController(
      text: widget.installment.interestRate.toString(),
    );
    _selectedStatus = widget.installment.status;
  }

  Future<void> _updateInstallment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedInstallment = InstallmentModel(
        id: widget.installment.id,
        totalAmountOfProduct: double.parse(_totalAmountController.text),
        otherCost: double.tryParse(_otherCostController.text) ?? 0.0,
        advancedPaid: double.parse(_advancedPaidController.text),
        installmentMonths: int.parse(_installmentMonthsController.text),
        interestRate: double.parse(_interestRateController.text),
        status: _selectedStatus,
      );

      // First update the installment data
      await _installmentService.updateInstallment(
        widget.installment.id!,
        updatedInstallment,
      );

      // Handle image deletions
      for (String imagePath in _imagesToDelete) {
        try {
          await _installmentService.deleteInstallmentImage(widget.installment.id!, imagePath);
        } catch (e) {
          print('Failed to delete image: $e');
        }
      }

      // Handle new image uploads
      if (_selectedImages.isNotEmpty) {
        final imageFiles = await Future.wait(
          _selectedImages.map((file) async {
            final fileBytes = await file.readAsBytes();
            return InstallmentService.createMultipartFile(
              fileBytes,
              'installment_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
          }),
        );
        
        await _installmentService.uploadInstallmentImages(widget.installment.id!, imageFiles);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('কিস্তি সফলভাবে আপডেট করা হয়েছে'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ত্রুটি: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        for (var pickedFile in pickedFiles) {
          final file = File(pickedFile.path);
          final fileSize = await file.length();

          if (!InstallmentService.validateImageSize(fileSize)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ছবি ${pickedFile.name} খুব বড়। সর্বোচ্চ সাইজ ৫MB।'),
                backgroundColor: Colors.red,
              ),
            );
            continue;
          }

          setState(() {
            _selectedImages.add(file);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ছবি নির্বাচন করতে ব্যর্থ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      final removedImage = widget.installment.imageFilePaths.removeAt(index);
      _imagesToDelete.add(removedImage);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ছবি অপসারণের জন্য চিহ্নিত করা হয়েছে'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'কিস্তির ডকুমেন্ট',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        // Existing Images
        if (widget.installment.imageFilePaths.isNotEmpty) ...[
          Text(
            'বর্তমান ডকুমেন্ট (${widget.installment.imageFilePaths.length})',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.installment.imageFilePaths.asMap().entries.map((entry) {
              final index = entry.key;
              final imageUrl = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 24, color: Colors.grey),
                                  SizedBox(height: 4),
                                  Text('ব্যর্থ', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeExistingImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // New Images Selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'নতুন ডকুমেন্ট যোগ করুন',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('ছবি যোগ করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        
        // New Images Preview
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'নতুন ডকুমেন্ট (${_selectedImages.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedImages.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(file),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeNewImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
        
        // Summary
        if (widget.installment.imageFilePaths.isNotEmpty || _selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.installment.imageFilePaths.length}টি বর্তমান ছবি • ${_selectedImages.length}টি নতুন ছবি • ${_imagesToDelete.length}টি অপসারণের জন্য চিহ্নিত',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('কিস্তি সম্পাদনা করুন'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Display readonly info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'কিস্তির তথ্য',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('সদস্য', widget.installment.member?.name ?? 'নেই'),
                    _buildInfoRow('পণ্য', widget.installment.product?.name ?? 'নেই'),
                    _buildInfoRow('এজেন্ট', widget.installment.givenProductAgent?.name ?? 'নেই'),
                    _buildInfoRow('তৈরির তারিখ', widget.installment.createdTime?.toString().split('.')[0] ?? 'নেই'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Editable fields
            TextFormField(
              controller: _totalAmountController,
              decoration: InputDecoration(
                labelText: 'মোট টাকার পরিমাণ *',
                prefixText: '৳',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'প্রয়োজনীয়';
                if (double.tryParse(value!) == null) return 'অবৈধ পরিমাণ';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _otherCostController,
              decoration: InputDecoration(
                labelText: 'অন্যান্য খরচ',
                prefixText: '৳',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) return 'অবৈধ পরিমাণ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _advancedPaidController,
              decoration: InputDecoration(
                labelText: 'অগ্রিম প্রদত্ত টাকা *',
                prefixText: '৳',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'প্রয়োজনীয়';
                if (double.tryParse(value!) == null) return 'অবৈধ পরিমাণ';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _installmentMonthsController,
              decoration: InputDecoration(
                labelText: 'কিস্তির মাস (১-৬০) *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'প্রয়োজনীয়';
                final months = int.tryParse(value!);
                if (months == null || months < 1 || months > 60) {
                  return '১ থেকে ৬০ এর মধ্যে হতে হবে';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _interestRateController,
              decoration: InputDecoration(
                labelText: 'সুদ হার *',
                suffixText: '%',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'প্রয়োজনীয়';
                final rate = double.tryParse(value!);
                if (rate == null || rate < 0 || rate > 100) {
                  return '০ থেকে ১০০ এর মধ্যে হতে হবে';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'স্ট্যাটাস *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['চলমান', 'বিচারাধীন', 'সম্পন্ন', 'মেয়াদোত্তীর্ণ']
                  .map((status) => DropdownMenuItem(
                        value: _getEnglishStatus(status),
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatus = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Image Section
            _buildImageSection(),
            const SizedBox(height: 24),
            
            // Calculated fields display
            if (widget.installment.monthlyInstallmentAmount != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'গণনাকৃত তথ্য',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'মাসিক কিস্তি',
                        '৳${widget.installment.monthlyInstallmentAmount?.toStringAsFixed(2)}',
                      ),
                      _buildInfoRow(
                        'সুদসহ মোট',
                        '৳${widget.installment.totalAmountWithInterest?.toStringAsFixed(2)}',
                      ),
                      _buildInfoRow(
                        'পরিশোধ করতে হবে',
                        '৳${widget.installment.needPaidAmount?.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            ElevatedButton(
              onPressed: _isLoading ? null : _updateInstallment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'কিস্তি আপডেট করুন',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getEnglishStatus(String banglaStatus) {
    switch (banglaStatus) {
      case 'চলমান':
        return 'ACTIVE';
      case 'বিচারাধীন':
        return 'PENDING';
      case 'সম্পন্ন':
        return 'COMPLETED';
      case 'মেয়াদোত্তীর্ণ':
        return 'OVERDUE';
      default:
        return 'ACTIVE';
    }
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _otherCostController.dispose();
    _advancedPaidController.dispose();
    _installmentMonthsController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }
}