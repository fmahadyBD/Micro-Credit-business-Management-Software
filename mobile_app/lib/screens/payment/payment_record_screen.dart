// lib/screens/payment/payment_record_screen.dart
import 'package:flutter/material.dart';

import 'package:mobile_app/models/payment_schedule_model.dart';
import 'package:mobile_app/models/agent_model.dart';
import 'package:mobile_app/screens/installment/installment_model.dart';
import 'package:mobile_app/screens/installment/installment_service.dart';

import 'package:mobile_app/services/payment_schedule_service.dart';
import 'package:mobile_app/services/agent_service.dart';
import 'package:mobile_app/screens/payment/payment_history_screen.dart';

class PaymentRecordScreen extends StatefulWidget {
  const PaymentRecordScreen({Key? key}) : super(key: key);

  @override
  State<PaymentRecordScreen> createState() => _PaymentRecordScreenState();
}

class _PaymentRecordScreenState extends State<PaymentRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final InstallmentService _installmentService = InstallmentService();
  final PaymentScheduleService _paymentService = PaymentScheduleService();
  final AgentService _agentService = AgentService();

  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  List<InstallmentModel> _installments = [];
  List<InstallmentModel> _filteredInstallments = [];
  List<AgentModel> _agents = [];
  
  InstallmentModel? _selectedInstallment;
  AgentModel? _selectedAgent;
  InstallmentBalanceModel? _balance;
  
  bool _isLoading = false;
  bool _isSearching = false;
  bool _hasPaymentThisMonth = false;
  bool _confirmExtraPayment = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final installments = await _installmentService.getAllInstallments();
      final agents = await _agentService.getAllAgents();
      
      setState(() {
        _installments = installments
            .where((i) => i.status != 'COMPLETED')
            .toList();
        _agents = agents;
        if (_agents.isNotEmpty) {
          _selectedAgent = _agents.first;
        }
      });
    } catch (e) {
      _showErrorSnackBar('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _searchInstallments(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredInstallments.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final filtered = _installments.where((installment) {
      final memberName = installment.member?.name?.toLowerCase() ?? '';
      final memberPhone = installment.member?.phone?.toLowerCase() ?? '';
      final productName = installment.product?.name.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return memberName.contains(searchLower) ||
             memberPhone.contains(searchLower) ||
             productName.contains(searchLower);
    }).toList();

    setState(() {
      _filteredInstallments = filtered;
      _isSearching = false;
    });
  }

  Future<void> _selectInstallment(InstallmentModel installment) async {
    setState(() {
      _selectedInstallment = installment;
      _searchController.clear();
      _filteredInstallments.clear();
      _amountController.text = installment.monthlyInstallmentAmount?.toString() ?? '';
    });

    // Load balance
    try {
      final balance = await _paymentService.getInstallmentBalance(installment.id!);
      setState(() => _balance = balance);
    } catch (e) {
      _showErrorSnackBar('Error loading balance: $e');
    }

    // Check if payment exists this month
    try {
      final hasPayment = await _paymentService.hasPaymentThisMonth(installment.id!);
      setState(() => _hasPaymentThisMonth = hasPayment);
      
      if (hasPayment) {
        _showWarningDialog();
      }
    } catch (e) {
      print('Error checking monthly payment: $e');
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 32),
            SizedBox(width: 12),
            Text('Payment Already Made'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This member has already made a payment this month.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Do you want to add an extra payment for this month?',
                      style: TextStyle(color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedInstallment = null;
                _balance = null;
                _hasPaymentThisMonth = false;
                _confirmExtraPayment = false;
              });
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _confirmExtraPayment = true);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
            ),
            child: Text('Add Extra Payment'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedInstallment == null) {
      _showErrorSnackBar('Please select an installment');
      return;
    }
    
    if (_selectedAgent == null) {
      _showErrorSnackBar('Please select an agent');
      return;
    }

    if (_hasPaymentThisMonth && !_confirmExtraPayment) {
      _showWarningDialog();
      return;
    }

    // Final confirmation
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      await _paymentService.createPayment(
        installmentId: _selectedInstallment!.id!,
        agentId: _selectedAgent!.id,
        amount: double.parse(_amountController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      _showSuccessSnackBar('Payment recorded successfully!');
      
      // Reset form
      setState(() {
        _selectedInstallment = null;
        _balance = null;
        _amountController.clear();
        _notesController.clear();
        _hasPaymentThisMonth = false;
        _confirmExtraPayment = false;
      });

      // Reload data
      _loadInitialData();
      
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmationRow('Member', _selectedInstallment!.member!.name!),
            _buildConfirmationRow('Amount', '৳${_amountController.text}'),
            _buildConfirmationRow('Agent', _selectedAgent!.name),
            if (_hasPaymentThisMonth)
              Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚠️ Extra payment this month',
                  style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Record', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentHistoryScreen()),
              );
            },
            tooltip: 'Payment History',
          ),
        ],
      ),
      body: _isLoading && _selectedInstallment == null
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // Search Section
                  _buildSearchSection(),
                  
                  if (_selectedInstallment != null) ...[
                    SizedBox(height: 24),
                    _buildSelectedInstallmentCard(),
                    SizedBox(height: 24),
                    _buildPaymentForm(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Installment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by member name, phone, or product...',
            prefixIcon: Icon(Icons.search, color: Colors.green[700]),
            suffixIcon: _isSearching
                ? Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green[700]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: _searchInstallments,
        ),
        
        if (_filteredInstallments.isNotEmpty) ...[
          SizedBox(height: 12),
          Container(
            constraints: BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredInstallments.length,
              itemBuilder: (context, index) {
                final installment = _filteredInstallments[index];
                return _buildInstallmentListItem(installment);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInstallmentListItem(InstallmentModel installment) {
    return InkWell(
      onTap: () => _selectInstallment(installment),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.person, color: Colors.green[700]),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    installment.member?.name ?? 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    installment.product?.name ?? 'N/A',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    installment.member?.phone ?? 'N/A',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedInstallmentCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 28),
                SizedBox(width: 12),
                Text(
                  'Selected Installment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            
            _buildInfoRow('Member', _selectedInstallment!.member!.name!),
            _buildInfoRow('Phone', _selectedInstallment!.member!.phone!),
            _buildInfoRow('Product', _selectedInstallment!.product!.name),
            
            if (_balance != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    _buildBalanceRow(
                      'Total Amount', 
                      '৳${_balance!.totalAmount.toStringAsFixed(2)}',
                      Colors.grey[700]!,
                    ),
                    _buildBalanceRow(
                      'Total Paid', 
                      '৳${_balance!.totalPaid.toStringAsFixed(2)}',
                      Colors.green[700]!,
                    ),
                    _buildBalanceRow(
                      'Remaining', 
                      '৳${_balance!.remainingBalance.toStringAsFixed(2)}',
                      Colors.red[700]!,
                    ),
                    Divider(),
                    _buildBalanceRow(
                      'Monthly Amount', 
                      '৳${_balance!.monthlyAmount.toStringAsFixed(2)}',
                      Colors.blue[700]!,
                    ),
                    _buildBalanceRow(
                      'Payments Made', 
                      '${_balance!.totalPayments} times',
                      Colors.grey[600]!,
                    ),
                  ],
                ),
              ),
            ],

            if (_hasPaymentThisMonth && !_confirmExtraPayment) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Payment already made this month!',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_confirmExtraPayment) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Extra payment confirmed for this month',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentHistoryScreen(
                      installmentId: _selectedInstallment!.id!,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.history),
              label: Text('View Payment History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),
            
            // Amount
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Payment Amount *',
                prefixIcon: Icon(Icons.attach_money, color: Colors.green[700]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (double.tryParse(value) == null) return 'Invalid amount';
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Agent
            DropdownButtonFormField<AgentModel>(
              value: _selectedAgent,
              decoration: InputDecoration(
                labelText: 'Collecting Agent *',
                prefixIcon: Icon(Icons.person, color: Colors.green[700]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: _agents.map((agent) {
                return DropdownMenuItem(
                  value: agent,
                  child: Text(agent.name),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedAgent = value),
              validator: (value) => value == null ? 'Required' : null,
            ),
            SizedBox(height: 16),
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                prefixIcon: Icon(Icons.note, color: Colors.green[700]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Record Payment',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}