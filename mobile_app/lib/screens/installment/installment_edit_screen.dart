// lib/screens/installment/installment_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/screens/installment/installment_model.dart';
import 'package:mobile_app/screens/installment/installment_service.dart';


class InstallmentEditScreen extends StatefulWidget {
  final InstallmentModel installment;

  const InstallmentEditScreen({
    Key? key,
    required this.installment,
  }) : super(key: key);

  @override
  State<InstallmentEditScreen> createState() => _InstallmentEditScreenState();
}

class _InstallmentEditScreenState extends State<InstallmentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final InstallmentService _installmentService = InstallmentService();
  
  late TextEditingController _totalAmountController;
  late TextEditingController _otherCostController;
  late TextEditingController _advancedPaidController;
  late TextEditingController _installmentMonthsController;
  late TextEditingController _interestRateController;
  
  late String _selectedStatus;
  bool _isLoading = false;

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

      await _installmentService.updateInstallment(
        widget.installment.id!,
        updatedInstallment,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Installment updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Installment'),
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
                      'Installment Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Member', widget.installment.member?.name ?? 'N/A'),
                    _buildInfoRow('Product', widget.installment.product?.name ?? 'N/A'),
                    _buildInfoRow('Agent', widget.installment.givenProductAgent?.name ?? 'N/A'),
                    _buildInfoRow('Created', widget.installment.createdTime?.toString().split('.')[0] ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Editable fields
            TextFormField(
              controller: _totalAmountController,
              decoration: InputDecoration(
                labelText: 'Total Amount *',
                prefixText: '৳',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _otherCostController,
              decoration: InputDecoration(
                labelText: 'Other Cost',
                prefixText: '৳',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) return 'Invalid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _advancedPaidController,
              decoration: InputDecoration(
                labelText: 'Advanced Payment *',
                prefixText: '৳',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _installmentMonthsController,
              decoration: InputDecoration(
                labelText: 'Installment Months (1-60) *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                final months = int.tryParse(value!);
                if (months == null || months < 1 || months > 60) {
                  return 'Must be between 1 and 60';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _interestRateController,
              decoration: InputDecoration(
                labelText: 'Interest Rate *',
                suffixText: '%',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                final rate = double.tryParse(value!);
                if (rate == null || rate < 0 || rate > 100) {
                  return 'Must be between 0 and 100';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['ACTIVE', 'PENDING', 'COMPLETED', 'OVERDUE']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatus = value);
                }
              },
            ),
            const SizedBox(height: 32),
            
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
                        'Calculated Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Monthly Payment',
                        '৳${widget.installment.monthlyInstallmentAmount?.toStringAsFixed(2)}',
                      ),
                      _buildInfoRow(
                        'Total with Interest',
                        '৳${widget.installment.totalAmountWithInterest?.toStringAsFixed(2)}',
                      ),
                      _buildInfoRow(
                        'Need to Pay',
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
                      'Update Installment',
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