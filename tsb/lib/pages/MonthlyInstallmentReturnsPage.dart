// lib/pages/monthly_INSTALLMENT_PAYMENTs_page.dart
// ⭐ CREATE THIS AS A NEW FILE ⭐

import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import 'package:intl/intl.dart';

class MonthlyInstallmentReturnsPage extends StatefulWidget {
  const MonthlyInstallmentReturnsPage({super.key});

  @override
  State<MonthlyInstallmentReturnsPage> createState() => _MonthlyInstallmentReturnsPageState();
}

class _MonthlyInstallmentReturnsPageState extends State<MonthlyInstallmentReturnsPage> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> _monthlyReturns = [];
  List<TransactionModel> _allInstallmentReturns = [];
  bool _isLoading = true;
  String _errorMessage = '';
  double _totalAmount = 0.0;
  
  // Month selection variables
  DateTime _selectedMonth = DateTime.now();
  List<Map<String, dynamic>> _availableMonths = [];
  bool _isMonthDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _loadMonthlyReturns();
  }

  Future<void> _loadMonthlyReturns() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Get all transactions
      final allTransactions = await _transactionService.getAllTransactions();
      
      // Filter for INSTALLMENT_PAYMENT transactions
      final installmentReturns = allTransactions.where((transaction) {
        return transaction.type == 'INSTALLMENT_PAYMENT';
      }).toList();

      // Get all unique months from the transactions
      final monthsSet = <DateTime>{};
      for (var transaction in installmentReturns) {
        final month = DateTime(transaction.timestamp.year, transaction.timestamp.month);
        monthsSet.add(month);
      }

      // Convert to list and sort descending (most recent first)
      final monthsList = monthsSet.toList();
      monthsList.sort((a, b) => b.compareTo(a));
      
      // Format months for display
      final formattedMonths = monthsList.map((month) {
        return {
          'date': month,
          'displayName': _formatMonthForDisplay(month),
          'yearMonth': '${month.year}-${month.month.toString().padLeft(2, '0')}',
        };
      }).toList();

      // If no months found, add current month
      if (formattedMonths.isEmpty) {
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);
        formattedMonths.add({
          'date': currentMonth,
          'displayName': _formatMonthForDisplay(currentMonth),
          'yearMonth': '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}',
        });
      }

      // Filter for selected month
      final selectedMonthStart = DateTime(_selectedMonth.year, _selectedMonth.month);
      final selectedMonthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
      
      final monthlyReturns = installmentReturns.where((transaction) {
        return transaction.timestamp.isAfter(selectedMonthStart.subtract(const Duration(days: 1))) &&
               transaction.timestamp.isBefore(selectedMonthEnd.add(const Duration(days: 1)));
      }).toList();

      // Sort by date (most recent first)
      monthlyReturns.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Calculate total
      double total = 0.0;
      for (var transaction in monthlyReturns) {
        total += transaction.amount;
      }

      setState(() {
        _monthlyReturns = monthlyReturns;
        _allInstallmentReturns = installmentReturns;
        _availableMonths = formattedMonths;
        _totalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatMonthForDisplay(DateTime date) {
    final monthsInBangla = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    
    final monthIndex = date.month - 1;
    final monthName = monthIndex >= 0 && monthIndex < monthsInBangla.length
        ? monthsInBangla[monthIndex]
        : DateFormat('MMMM', 'bn').format(date);
    
    return '$monthName ${date.year}';
  }

  String _formatMonthForDropdown(DateTime date) {
    final monthsInBangla = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    
    final monthIndex = date.month - 1;
    final monthName = monthIndex >= 0 && monthIndex < monthsInBangla.length
        ? monthsInBangla[monthIndex]
        : DateFormat('MMMM', 'bn').format(date);
    
    return '$monthName ${date.year}';
  }

  Widget _buildMonthSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'মাস নির্বাচন করুন',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isMonthDropdownOpen = !_isMonthDropdownOpen;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatMonthForDisplay(_selectedMonth),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _isMonthDropdownOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
            if (_isMonthDropdownOpen && _availableMonths.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _availableMonths.length,
                  itemBuilder: (context, index) {
                    final monthData = _availableMonths[index];
                    final monthDate = monthData['date'] as DateTime;
                    final isSelected = _selectedMonth.year == monthDate.year &&
                        _selectedMonth.month == monthDate.month;
                    
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.calendar_month,
                        color: isSelected ? const Color(0xFF10B981) : Colors.grey,
                        size: 18,
                      ),
                      title: Text(
                        monthData['displayName'],
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF10B981) : Colors.black,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF10B981),
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedMonth = monthDate;
                          _isMonthDropdownOpen = false;
                        });
                        _filterByMonth(monthDate);
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _filterByMonth(DateTime month) {
    final monthStart = DateTime(month.year, month.month);
    final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    final filteredReturns = _allInstallmentReturns.where((transaction) {
      return transaction.timestamp.isAfter(monthStart.subtract(const Duration(days: 1))) &&
             transaction.timestamp.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    filteredReturns.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    double total = 0.0;
    for (var transaction in filteredReturns) {
      total += transaction.amount;
    }

    setState(() {
      _monthlyReturns = filteredReturns;
      _totalAmount = total;
    });
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.green.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6F7F0),
              Color(0xFFB3E5D1),
              Color(0xFF80D4B2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment_return,
                    color: Color(0xFF059669),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'কালেকশন সারাংশ',
                        style: TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatMonthForDisplay(_selectedMonth),
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'মোট পরিমাণ',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '৳${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Color(0xFF059669), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${_monthlyReturns.length} টি লেনদেন',
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final displayName = transaction.memberName?.isNotEmpty == true
        ? transaction.memberName!
        : transaction.shareholderName?.isNotEmpty == true
            ? transaction.shareholderName!
            : transaction.displayName;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.assignment_return,
            color: Color(0xFF10B981),
            size: 24,
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'কালেকশন',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (transaction.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                transaction.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  _formatDate(transaction.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  transaction.formattedTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+৳${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    final displayName = transaction.memberName?.isNotEmpty == true
        ? transaction.memberName!
        : transaction.shareholderName?.isNotEmpty == true
            ? transaction.shareholderName!
            : transaction.displayName;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.assignment_return,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'কালেকশন',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('পরিমাণ', '+৳${transaction.amount.toStringAsFixed(2)}',
                    color: const Color(0xFF10B981)),
                _buildDetailRow('নাম', displayName),
                if (transaction.shareholderName != null &&
                    transaction.shareholderName!.isNotEmpty)
                  _buildDetailRow('শেয়ারহোল্ডার', transaction.shareholderName!),
                if (transaction.memberName != null && transaction.memberName!.isNotEmpty)
                  _buildDetailRow('সদস্য', transaction.memberName!),
                if (transaction.description.isNotEmpty)
                  _buildDetailRow('বিবরণ', transaction.description),
                _buildDetailRow('তারিখ', _formatDate(transaction.timestamp)),
                _buildDetailRow('সময়', transaction.formattedTime),
                _buildDetailRow('লেনদেনের ধরন', 'INSTALLMENT_PAYMENT'),
                if (transaction.memberId != null)
                  _buildDetailRow('সদস্য আইডি', transaction.memberId.toString()),
                if (transaction.shareholderId != null)
                  _buildDetailRow(
                      'শেয়ারহোল্ডার আইডি', transaction.shareholderId.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black,
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'ত্রুটি: $_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadMonthlyReturns,
                        icon: const Icon(Icons.refresh),
                        label: const Text('পুনরায় চেষ্টা করুন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMonthlyReturns,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.assignment_return,
                                    color: Color(0xFF10B981),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'মাস অনুযায়ী কালেকশন',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: _loadMonthlyReturns,
                                    tooltip: 'রিফ্রেশ',
                                    color: const Color(0xFF10B981),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildMonthSelector(),
                              const SizedBox(height: 16),
                              _buildSummaryCard(),
                              const SizedBox(height: 24),
                              if (_monthlyReturns.isEmpty)
                                Card(
                                  child: Container(
                                    padding: const EdgeInsets.all(40),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.inbox,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '${_formatMonthForDisplay(_selectedMonth)} মাসে কোন কালেকশন নেই',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.list, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'লেনদেনের তালিকা (${_monthlyReturns.length} টি)',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _monthlyReturns.length,
                                      itemBuilder: (context, index) =>
                                          _buildTransactionItem(_monthlyReturns[index]),
                                    ),
                                  ],
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
}