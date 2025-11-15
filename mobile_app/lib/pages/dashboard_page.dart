// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_app/models/transaction_model.dart';
import 'package:mobile_app/models/balance_model.dart';
import 'package:mobile_app/services/transaction_service.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  BalanceModel? _currentBalance;
  bool _isLoading = true;
  String _errorMessage = '';
  String _filterType = 'ALL';
  String _searchQuery = '';
  late AnimationController _animationController;
  
  // Pagination
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  
  int get _totalPages => (_filteredTransactions.length / _itemsPerPage).ceil();
  List<TransactionModel> get _currentPageTransactions {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _filteredTransactions.length);
    if (startIndex >= _filteredTransactions.length) return [];
    return _filteredTransactions.sublist(startIndex, endIndex);
  }

  final Map<String, Color> _typeColors = {
    'INVESTMENT': const Color(0xFF10B981),
    'WITHDRAWAL': const Color(0xFFEF4444),
    'PRODUCT_COST': const Color(0xFFF59E0B),
    'MAINTENANCE': const Color(0xFF8B5CF6),
    'INSTALLMENT_RETURN': const Color(0xFF3B82F6),
    'ADVANCED_PAYMENT': const Color(0xFF14B8A6),
    'EARNINGS': const Color(0xFF6366F1),
  };

  final Map<String, IconData> _typeIcons = {
    'INVESTMENT': Icons.trending_up,
    'WITHDRAWAL': Icons.trending_down,
    'PRODUCT_COST': Icons.shopping_cart,
    'MAINTENANCE': Icons.build,
    'INSTALLMENT_RETURN': Icons.assignment_return,
    'ADVANCED_PAYMENT': Icons.payment,
    'EARNINGS': Icons.attach_money,
  };

  // Bengali translations
  final Map<String, String> _typeBengali = {
    'INVESTMENT': 'বিনিয়োগ',
    'WITHDRAWAL': 'উত্তোলন',
    'PRODUCT_COST': 'পণ্য খরচ',
    'MAINTENANCE': 'রক্ষণাবেক্ষণ',
    'INSTALLMENT_RETURN': 'কিস্তি ফেরত',
    'ADVANCED_PAYMENT': 'অগ্রিম পেমেন্ট',
    'EARNINGS': 'মুনাফা',
    'ALL': 'সব ধরনের',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final transactions = await _transactionService.getAllTransactions();
      final balance = await _transactionService.getCurrentBalance();

      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _filteredTransactions = transactions;
        _currentBalance = balance;
        _currentPage = 0;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterTransactions() {
    setState(() {
      final q = _searchQuery.trim().toLowerCase();
      _filteredTransactions = _transactions.where((transaction) {
        final matchesSearch = q.isEmpty ||
            transaction.displayName.toLowerCase().contains(q) ||
            transaction.description.toLowerCase().contains(q) ||
            transaction.type.toLowerCase().contains(q) ||
            (transaction.shareholderName?.toLowerCase().contains(q) ?? false) ||
            (transaction.memberName?.toLowerCase().contains(q) ?? false);
        final matchesType = _filterType == 'ALL' || transaction.type == _filterType;
        return matchesSearch && matchesType;
      }).toList();
      _currentPage = 0; // Reset to first page when filtering
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

  Widget _buildBalanceCard() {
    if (_currentBalance == null) {
      return _buildLoadingCard();
    }

    return Card(
      elevation: 8,
      shadowColor: Colors.blue.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A), // Deep blue
              Color(0xFF3B82F6), // Bright blue
              Color(0xFF60A5FA), // Light blue
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'মোট ব্যালেন্স',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '৳${_currentBalance!.totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('বিনিয়োগ', _currentBalance!.totalInvestment, const Color.fromARGB(255, 255, 255, 255)),
                      _buildMiniStat('মুনাফা', _currentBalance!.totalEarnings, const Color.fromARGB(255, 238, 238, 238)),
                      _buildMiniStat('খরচ', _currentBalance!.totalExpenses, const Color(0xFFEF4444)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'নিট লাভ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '৳${_currentBalance!.netProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: _currentBalance!.netProfit >= 0 ? const Color.fromARGB(255, 255, 252, 252) : const Color(0xFFEF4444),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'সর্বশেষ আপডেট: ${_formatDateTime(_currentBalance!.lastUpdated)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.blue.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            SizedBox(height: 16),
            Text('ব্যালেন্স লোড হচ্ছে...', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String title, double value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '৳${value.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    if (_transactions.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('কোন ডেটা নেই', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final Map<String, double> typeTotals = {};
    for (var transaction in _transactions) {
      typeTotals.update(transaction.type, (value) => value + transaction.amount, ifAbsent: () => transaction.amount);
    }

    final sections = typeTotals.entries.map((entry) {
      final color = _typeColors[entry.key] ?? Colors.grey;
      return PieChartSectionData(
        value: entry.value,
        title: '৳${entry.value.toStringAsFixed(0)}',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('লেনদেন বিতরণ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 40)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: typeTotals.entries.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(color: _typeColors[entry.key], shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(_typeBengali[entry.key] ?? entry.key, style: const TextStyle(fontSize: 12)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTable() {
    if (_filteredTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Column(
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('কোন লেনদেন পাওয়া যায়নি', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _currentPageTransactions.length,
          itemBuilder: (context, index) => _buildTransactionItem(_currentPageTransactions[index]),
        ),
        if (_totalPages > 1) _buildPagination(),
      ],
    );
  }

  Widget _buildPagination() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'পৃষ্ঠা ${_currentPage + 1} / $_totalPages (মোট ${_filteredTransactions.length} টি লেনদেন)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First page button
              IconButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage = 0)
                    : null,
                icon: const Icon(Icons.first_page),
                tooltip: 'প্রথম পৃষ্ঠা',
                color: Colors.blue,
                disabledColor: Colors.grey.shade400,
              ),
              // Previous page button
              IconButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'আগের পৃষ্ঠা',
                color: Colors.blue,
                disabledColor: Colors.grey.shade400,
              ),
              const SizedBox(width: 16),
              // Page numbers
              ..._buildPageNumbers(),
              const SizedBox(width: 16),
              // Next page button
              IconButton(
                onPressed: _currentPage < _totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'পরবর্তী পৃষ্ঠা',
                color: Colors.blue,
                disabledColor: Colors.grey.shade400,
              ),
              // Last page button
              IconButton(
                onPressed: _currentPage < _totalPages - 1
                    ? () => setState(() => _currentPage = _totalPages - 1)
                    : null,
                icon: const Icon(Icons.last_page),
                tooltip: 'শেষ পৃষ্ঠা',
                color: Colors.blue,
                disabledColor: Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageButtons = [];
    int startPage = (_currentPage - 2).clamp(0, _totalPages - 1);
    int endPage = (_currentPage + 2).clamp(0, _totalPages - 1);

    if (startPage > 0) {
      pageButtons.add(_buildPageButton(0));
      if (startPage > 1) {
        pageButtons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(fontSize: 16)),
        ));
      }
    }

    for (int i = startPage; i <= endPage && i < _totalPages; i++) {
      pageButtons.add(_buildPageButton(i));
    }

    if (endPage < _totalPages - 1) {
      if (endPage < _totalPages - 2) {
        pageButtons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(fontSize: 16)),
        ));
      }
      pageButtons.add(_buildPageButton(_totalPages - 1));
    }

    return pageButtons;
  }

  Widget _buildPageButton(int pageIndex) {
    final isCurrentPage = pageIndex == _currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => setState(() => _currentPage = pageIndex),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrentPage ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrentPage ? Colors.blue : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '${pageIndex + 1}',
              style: TextStyle(
                color: isCurrentPage ? Colors.white : Colors.grey.shade700,
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTransactionDisplayName(TransactionModel transaction) {
    // Priority: memberName > shareholderName > displayName
    if (transaction.memberName != null && transaction.memberName!.isNotEmpty) {
      return transaction.memberName!;
    } else if (transaction.shareholderName != null && transaction.shareholderName!.isNotEmpty) {
      return transaction.shareholderName!;
    }
    return transaction.displayName;
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final color = _typeColors[transaction.type] ?? Colors.grey;
    final icon = _typeIcons[transaction.type] ?? Icons.receipt;
    final displayName = _getTransactionDisplayName(transaction);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _typeBengali[transaction.type] ?? transaction.typeDisplayName,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (transaction.description.isNotEmpty)
              Text(
                transaction.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.formattedAmount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: transaction.isPositive ? Colors.green : Colors.red,
              ),
            ),
            Text(_formatDate(transaction.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    final displayName = _getTransactionDisplayName(transaction);
    
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
                        color: _typeColors[transaction.type]?.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_typeIcons[transaction.type] ?? Icons.receipt, color: _typeColors[transaction.type]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _typeBengali[transaction.type] ?? transaction.typeDisplayName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('পরিমাণ', transaction.formattedAmount,
                    color: transaction.isPositive ? Colors.green : Colors.red),
                _buildDetailRow('নাম', displayName),
                if (transaction.shareholderName != null && transaction.shareholderName!.isNotEmpty)
                  _buildDetailRow('শেয়ারহোল্ডার', transaction.shareholderName!),
                if (transaction.memberName != null && transaction.memberName!.isNotEmpty)
                  _buildDetailRow('সদস্য', transaction.memberName!),
                if (transaction.description.isNotEmpty) _buildDetailRow('বিবরণ', transaction.description),
                _buildDetailRow('তারিখ', _formatDate(transaction.timestamp)),
                _buildDetailRow('সময়', transaction.formattedTime),
                if (transaction.memberId != null) _buildDetailRow('সদস্য আইডি', transaction.memberId.toString()),
                if (transaction.shareholderId != null)
                  _buildDetailRow('শেয়ারহোল্ডার আইডি', transaction.shareholderId.toString()),
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
            child: Text('$label:', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color ?? Colors.black, fontWeight: color != null ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
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
                      Text('ত্রুটি: $_errorMessage', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadDashboardData, child: const Text('পুনরায় চেষ্টা করুন')),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Header with gradient and balance card
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.dashboard, color: Colors.white, size: 28),
                                const SizedBox(width: 12),
                                const Text('ড্যাশবোর্ড', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  onPressed: _loadDashboardData,
                                  tooltip: 'রিফ্রেশ',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildBalanceCard(),
                          ],
                        ),
                      ),
                    ),
                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextField(
                                      onChanged: (value) {
                                        setState(() => _searchQuery = value);
                                        _filterTransactions();
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'লেনদেন খুঁজুন...',
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: _filterType,
                                      decoration: InputDecoration(
                                        labelText: 'ধরন অনুসারে ফিল্টার',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      items: ['ALL', ..._typeColors.keys.toList()].map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Row(
                                            children: [
                                              if (type != 'ALL') Icon(_typeIcons[type], color: _typeColors[type], size: 16),
                                              const SizedBox(width: 8),
                                              Text(_typeBengali[type] ?? type),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() => _filterType = value);
                                        _filterTransactions();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildCharts(),
                            const SizedBox(height: 20),
                            const Row(
                              children: [
                                Icon(Icons.history, size: 20),
                                SizedBox(width: 8),
                                Text('সাম্প্রতিক লেনদেন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTransactionTable(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}