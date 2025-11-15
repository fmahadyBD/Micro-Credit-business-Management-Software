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

  final Map<String, Color> _typeColors = {
    'INVESTMENT': Colors.green,
    'WITHDRAWAL': Colors.red,
    'PRODUCT_COST': Colors.orange,
    'MAINTENANCE': Colors.purple,
    'INSTALLMENT_RETURN': Colors.blue,
    'ADVANCED_PAYMENT': Colors.teal,
    'EARNINGS': Colors.indigo,
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
            transaction.type.toLowerCase().contains(q);
        final matchesType = _filterType == 'ALL' || transaction.type == _filterType;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  Widget _buildBalanceCard() {
    if (_currentBalance == null) {
      return _buildLoadingCard();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.blue.shade700, Colors.blue.shade500]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Total Balance', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 16),
          Text('৳${_currentBalance!.totalBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildMiniStat('Investment', _currentBalance!.totalInvestment, Colors.green),
            _buildMiniStat('Earnings', _currentBalance!.totalEarnings, Colors.teal),
            _buildMiniStat('Expenses', _currentBalance!.totalExpenses, Colors.red),
          ]),
          const SizedBox(height: 8),
          Text('Last updated: ${DateFormat('dd MMM yyyy HH:mm').format(_currentBalance!.lastUpdated)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.blue.shade700, Colors.blue.shade500]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Loading balance...', style: TextStyle(color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _buildMiniStat(String title, double value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      Text('৳${value.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildCharts() {
    if (_transactions.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
        child: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bar_chart, size: 48, color: Colors.grey), SizedBox(height: 8), Text('No data available', style: TextStyle(color: Colors.grey))]),
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

    return Column(children: [
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Transaction Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(height: 250, child: PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 40))),
            const SizedBox(height: 16),
            Wrap(spacing: 16, runSpacing: 8, children: typeTotals.entries.map((entry) {
              return Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: _typeColors[entry.key], shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(entry.key.replaceAll('_', ' '), style: const TextStyle(fontSize: 12)),
              ]);
            }).toList()),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildTransactionTable() {
    if (_filteredTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Column(children: [Icon(Icons.receipt_long, size: 64, color: Colors.grey), SizedBox(height: 16), Text('No transactions found', style: TextStyle(color: Colors.grey))]),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) => _buildTransactionItem(_filteredTransactions[index]),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final color = _typeColors[transaction.type] ?? Colors.grey;
    final icon = _typeIcons[transaction.type] ?? Icons.receipt;
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
        title: Text(transaction.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(transaction.typeDisplayName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          if (transaction.description.isNotEmpty) Text(transaction.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(transaction.formattedAmount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: transaction.isPositive ? Colors.green : Colors.red)),
          Text(transaction.formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ]),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: _typeColors[transaction.type]?.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(_typeIcons[transaction.type] ?? Icons.receipt, color: _typeColors[transaction.type])),
                const SizedBox(width: 12),
                Expanded(child: Text(transaction.typeDisplayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ]),
              const SizedBox(height: 20),
              _buildDetailRow('Amount', transaction.formattedAmount, color: transaction.isPositive ? Colors.green : Colors.red),
              _buildDetailRow('Name', transaction.displayName),
              if (transaction.shareholderName != null && transaction.shareholderName!.isNotEmpty) _buildDetailRow('Shareholder', transaction.shareholderName!),
              if (transaction.memberName != null && transaction.memberName!.isNotEmpty) _buildDetailRow('Member', transaction.memberName!),
              if (transaction.description.isNotEmpty) _buildDetailRow('Description', transaction.description),
              _buildDetailRow('Date', DateFormat('dd MMM yyyy').format(transaction.timestamp)),
              _buildDetailRow('Time', transaction.formattedTime),
              if (transaction.memberId != null) _buildDetailRow('Member ID', transaction.memberId.toString()),
              if (transaction.shareholderId != null) _buildDetailRow('Shareholder ID', transaction.shareholderId.toString()),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 100, child: Text('$label:', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: TextStyle(color: color ?? Colors.black, fontWeight: color != null ? FontWeight.bold : FontWeight.normal))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
          decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.dashboard, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadDashboardData, tooltip: 'Refresh'),
            ]),
            const SizedBox(height: 16),
            _buildBalanceCard(),
          ]),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 64, color: Colors.red), const SizedBox(height: 16), Text('Error: $_errorMessage', textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: _loadDashboardData, child: const Text('Retry'))]))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: [
                              TextField(
                                onChanged: (value) {
                                  setState(() => _searchQuery = value);
                                  _filterTransactions();
                                },
                                decoration: InputDecoration(hintText: 'Search transactions...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _filterType,
                                decoration: InputDecoration(labelText: 'Filter by Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                                items: ['ALL', ..._typeColors.keys.toList()].map((type) {
                                  return DropdownMenuItem(value: type, child: Row(children: [if (type != 'ALL') Icon(_typeIcons[type], color: _typeColors[type], size: 16), const SizedBox(width: 8), Text(type == 'ALL' ? 'All Types' : type.replaceAll('_', ' '))]));
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _filterType = value);
                                  _filterTransactions();
                                },
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildCharts(),
                        const SizedBox(height: 20),
                        const Row(children: [Icon(Icons.history, size: 20), SizedBox(width: 8), Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 12),
                        _buildTransactionTable(),
                      ]),
                    ),
        ),
      ]),
    );
  }
}
