// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../models/balance_model.dart';
import '../services/transaction_service.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
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
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, _filteredTransactions.length);
    if (startIndex >= _filteredTransactions.length) return [];
    return _filteredTransactions.sublist(startIndex, endIndex);
  }

  // Transaction type definitions - Match your Java backend types
  final Map<String, Color> _typeColors = {
    'INVESTMENT': const Color(0xFF10B981),        // Green
    'WITHDRAWAL': const Color(0xFFEF4444),        // Red
    'PRODUCT_COST': const Color(0xFFF59E0B),      // Amber
    'MAINTENANCE': const Color(0xFF8B5CF6),       // Purple
    'INSTALLMENT_RETURN': const Color(0xFF3B82F6), // Blue
    'ADVANCED_PAYMENT': const Color(0xFF14B8A6),   // Teal
    'EARNINGS': const Color(0xFF6366F1),          // Indigo
    'INSTALLMENT_PAYMENT': const Color(0xFF10B981), // Green (same as INVESTMENT)
    'OTHER_COST_DEDUCTION': const Color(0xFFDC2626), // Dark Red
    'OTHER_COST_RETURN': const Color(0xFF059669),   // Dark Green
    'UPDATE_INSTALLMENT': const Color(0xFFF97316),  // Orange
  };

  final Map<String, IconData> _typeIcons = {
    'INVESTMENT': Icons.trending_up,
    'WITHDRAWAL': Icons.trending_down,
    'PRODUCT_COST': Icons.shopping_cart,
    'MAINTENANCE': Icons.build,
    'INSTALLMENT_RETURN': Icons.assignment_return,
    'ADVANCED_PAYMENT': Icons.payment,
    'EARNINGS': Icons.attach_money,
    'INSTALLMENT_PAYMENT': Icons.payment,
    'OTHER_COST_DEDUCTION': Icons.money_off,
    'OTHER_COST_RETURN': Icons.undo,
    'UPDATE_INSTALLMENT': Icons.edit,
  };

  // Bengali translations for all types
  final Map<String, String> _typeBengali = {
    'INVESTMENT': 'বিনিয়োগ',
    'WITHDRAWAL': 'উত্তোলন',
    'PRODUCT_COST': 'পণ্য খরচ',
    'MAINTENANCE': 'রক্ষণাবেক্ষণ',
    'INSTALLMENT_RETURN': 'কিস্তি ফেরত',
    'ADVANCED_PAYMENT': 'অগ্রিম পেমেন্ট',
    'EARNINGS': 'আয়',
    'INSTALLMENT_PAYMENT': 'কিস্তি পেমেন্ট',
    'OTHER_COST_DEDUCTION': 'অন্যান্য খরচ কাটা',
    'OTHER_COST_RETURN': 'অন্যান্য খরচ ফেরত',
    'UPDATE_INSTALLMENT': 'কিস্তি আপডেট',
    'ALL': 'সব ধরনের',
  };

  final Set<String> _positiveTransactionTypes = {
    'INVESTMENT',
    'INSTALLMENT_RETURN',
    'ADVANCED_PAYMENT',
    'EARNINGS',
    'INSTALLMENT_PAYMENT',
    'OTHER_COST_RETURN',  // Money returning to balance
  };

  final Set<String> _negativeTransactionTypes = {
    'WITHDRAWAL',
    'PRODUCT_COST',
    'MAINTENANCE',
    'OTHER_COST_DEDUCTION',  // Money deducted from balance
  };

  // All available transaction types for filtering
  final List<String> _availableTypes = [
    'ALL',
    'INVESTMENT',
    'WITHDRAWAL',
    'PRODUCT_COST',
    'MAINTENANCE',
    'INSTALLMENT_RETURN',
    'ADVANCED_PAYMENT',
    'EARNINGS',
    'INSTALLMENT_PAYMENT',
    'OTHER_COST_DEDUCTION',
    'OTHER_COST_RETURN',
    'UPDATE_INSTALLMENT',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
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
            _typeBengali[transaction.type]!.toLowerCase().contains(q) ?? false ||
            (transaction.shareholderName?.toLowerCase().contains(q) ?? false) ||
            (transaction.memberName?.toLowerCase().contains(q) ?? false);
        
        final matchesType = _filterType == 'ALL' || transaction.type == _filterType;
        
        return matchesSearch && matchesType;
      }).toList();
      _currentPage = 0;
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
              Color(0xFFE6F3FF),
              Color(0xFFB3D9FF),
              Color(0xFF80BFFF),
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
                  child: const Icon(Icons.account_balance_wallet,
                      color: Color(0xFF1E3A8A), size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'মোট ব্যালেন্স',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
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
                color: Color(0xFF1E3A8A),
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('মোট বিনিয়োগ',
                          _currentBalance!.totalInvestment, const Color(0xFF1E3A8A)),
                      _buildMiniStat('মোট আয়',
                          _currentBalance!.totalEarnings, const Color(0xFF059669)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('পণ্য খরচ',
                          _currentBalance!.totalProductCost, const Color(0xFFDC2626)),
                      _buildMiniStat('রক্ষণাবেক্ষণ',
                          _currentBalance!.totalMaintenanceCost, const Color(0xFFDC2626)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.black.withOpacity(0.6), thickness: 2),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'নিট লাভ',
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '৳${_currentBalance!.netProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: _currentBalance!.netProfit >= 0
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                          fontSize: 22,
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
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 12,
              ),
            ),
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
            style: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 23,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '৳ ${value.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
              Color(0xFFE6F3FF),
              Color(0xFFB3D9FF),
              Color(0xFF80BFFF),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF1E3A8A), strokeWidth: 3),
            SizedBox(height: 16),
            Text('ব্যালেন্স লোড হচ্ছে...',
                style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_transactions.isEmpty) {
      return Container(
        height: 300,
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
      typeTotals.update(
        transaction.type,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final bars = typeTotals.entries.map((entry) {
      return BarChartGroupData(
        x: typeTotals.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: _typeColors[entry.key] ?? Colors.grey,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    final maxY = typeTotals.values.reduce((a, b) => a > b ? a : b) * 1.1;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'লেনদেনের পরিমাণ (ধরন অনুযায়ী)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: bars,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final type = typeTotals.keys.elementAt(value.toInt());
                          final bengaliName = _typeBengali[type] ?? type;
                          final displayName = bengaliName.length > 8
                              ? '${bengaliName.substring(0, 8)}...'
                              : bengaliName;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              displayName,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '৳${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipMargin: 0,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final type = typeTotals.keys.elementAt(group.x);
                        final bengaliName = _typeBengali[type] ?? type;
                        return BarTooltipItem(
                          '$bengaliName\n৳${rod.toY.toStringAsFixed(2)}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: typeTotals.entries.map((entry) {
                final bengaliName = _typeBengali[entry.key] ?? entry.key;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _typeColors[entry.key],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bengaliName,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTable() {
    if (_filteredTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('কোন লেনদেন পাওয়া যায়নি',
                style: TextStyle(color: Colors.grey)),
            if (_filterType != 'ALL')
              Text('ফিল্টার: ${_typeBengali[_filterType] ?? _filterType}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filter info
        if (_filterType != 'ALL' || _searchQuery.isNotEmpty)
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade700),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ফিল্টার করা হয়েছে: ${_filterType != 'ALL' ? '${_typeBengali[_filterType] ?? _filterType}' : ''}${_searchQuery.isNotEmpty ? ' | সার্চ: "$_searchQuery"' : ''} | মোট: ${_filteredTransactions.length} টি',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                  ),
                ),
                if (_filterType != 'ALL' || _searchQuery.isNotEmpty)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _filterType = 'ALL';
                        _searchQuery = '';
                        _filterTransactions();
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.clear, size: 16, color: Colors.blue.shade700),
                        SizedBox(width: 4),
                        Text('সব ফিল্টার সরান', 
                            style: TextStyle(color: Colors.blue.shade700, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _currentPageTransactions.length,
          itemBuilder: (context, index) =>
              _buildTransactionItem(_currentPageTransactions[index]),
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
              IconButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage = 0)
                    : null,
                icon: const Icon(Icons.first_page),
                tooltip: 'প্রথম পৃষ্ঠা',
                color: Colors.blue,
                disabledColor: Colors.grey.shade400,
              ),
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
              ..._buildPageNumbers(),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _currentPage < _totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'পরবর্তী পৃষ্ঠা',
                color: Colors.blue,
                disabledColor: Colors.grey.shade400,
              ),
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
    if (transaction.memberName != null && transaction.memberName!.isNotEmpty) {
      return transaction.memberName!;
    } else if (transaction.shareholderName != null &&
        transaction.shareholderName!.isNotEmpty) {
      return transaction.shareholderName!;
    }
    return transaction.displayName;
  }

  bool _isPositiveTransaction(TransactionModel transaction) {
    if (_positiveTransactionTypes.contains(transaction.type)) return true;
    if (_negativeTransactionTypes.contains(transaction.type)) return false;
    
    // For types not explicitly defined, check the description or name
    return !transaction.description.toLowerCase().contains('কাটা') &&
           !transaction.description.toLowerCase().contains('খরচ') &&
           !transaction.description.toLowerCase().contains('deduction');
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final color = _typeColors[transaction.type] ?? Colors.grey;
    final icon = _typeIcons[transaction.type] ?? Icons.receipt;
    final displayName = _getTransactionDisplayName(transaction);
    final isPositive = _isPositiveTransaction(transaction);
    final amountColor = isPositive ? Colors.green : Colors.red;
    final amountPrefix = isPositive ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(displayName,
            style: const TextStyle(fontWeight: FontWeight.w500)),
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
              '$amountPrefix৳${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            Text(_formatDate(transaction.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    final displayName = _getTransactionDisplayName(transaction);
    final isPositive = _isPositiveTransaction(transaction);
    final amountPrefix = isPositive ? '+' : '-';

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
                      child: Icon(_typeIcons[transaction.type] ?? Icons.receipt,
                          color: _typeColors[transaction.type]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _typeBengali[transaction.type] ??
                            transaction.typeDisplayName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('পরিমাণ',
                    '$amountPrefix৳${transaction.amount.toStringAsFixed(2)}',
                    color: isPositive ? Colors.green : Colors.red),
                _buildDetailRow('ধরন', 
                    '${transaction.type} (${_typeBengali[transaction.type] ?? transaction.typeDisplayName})'),
                _buildDetailRow('নাম', displayName),
                if (transaction.shareholderName != null &&
                    transaction.shareholderName!.isNotEmpty)
                  _buildDetailRow(
                      'শেয়ারহোল্ডার', transaction.shareholderName!),
                if (transaction.memberName != null &&
                    transaction.memberName!.isNotEmpty)
                  _buildDetailRow('সদস্য', transaction.memberName!),
                if (transaction.description.isNotEmpty)
                  _buildDetailRow('বিবরণ', transaction.description),
                _buildDetailRow('তারিখ', _formatDate(transaction.timestamp)),
                _buildDetailRow('সময়', transaction.formattedTime),
                if (transaction.memberId != null)
                  _buildDetailRow(
                      'সদস্য আইডি', transaction.memberId.toString()),
                if (transaction.shareholderId != null)
                  _buildDetailRow('শেয়ারহোল্ডার আইডি',
                      transaction.shareholderId.toString()),
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
            child: Text('$label:',
                style: TextStyle(
                    color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  color: color ?? Colors.black,
                  fontWeight:
                      color != null ? FontWeight.bold : FontWeight.normal),
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
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('ত্রুটি: $_errorMessage',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _loadDashboardData,
                          child: const Text('পুনরায় চেষ্টা করুন')),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
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
                                const Icon(Icons.dashboard,
                                    color: Colors.white, size: 28),
                                const SizedBox(width: 12),
                                const Text('ড্যাশবোর্ড',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextField(
                                      onChanged: (value) {
                                        setState(() => _searchQuery = value);
                                        _filterTransactions();
                                      },
                                      controller: TextEditingController(text: _searchQuery),
                                      decoration: InputDecoration(
                                        hintText: 'লেনদেন খুঁজুন...',
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        suffixIcon: _searchQuery.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  setState(() => _searchQuery = '');
                                                  _filterTransactions();
                                                },
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: _filterType,
                                      decoration: InputDecoration(
                                        labelText: 'ধরন অনুসারে ফিল্টার',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      items: _availableTypes.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Row(
                                            children: [
                                              if (type != 'ALL')
                                                Container(
                                                  width: 16,
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    color: _typeColors[type],
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
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
                            _buildBarChart(),
                            const SizedBox(height: 20),
                            const Row(
                              children: [
                                Icon(Icons.history, size: 20),
                                SizedBox(width: 8),
                                Text('সাম্প্রতিক লেনদেন',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
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