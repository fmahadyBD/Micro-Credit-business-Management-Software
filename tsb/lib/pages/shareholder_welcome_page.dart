import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/shareholder_model.dart';
import '../models/investment_history_model.dart';
import '../models/balance_model.dart';
import '../screens/installment/installment_model.dart';
import '../services/shareholder_service.dart';
import '../services/transaction_service.dart';
import '../screens/installment/installment_service.dart';
import '../widgets/topbar.dart';
import 'package:intl/intl.dart';

class ShareholderWelcomePage extends StatefulWidget {
  const ShareholderWelcomePage({super.key});

  @override
  State<ShareholderWelcomePage> createState() => _ShareholderWelcomePageState();
}

class _ShareholderWelcomePageState extends State<ShareholderWelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ShareholderService _shareholderService = ShareholderService();
  final TransactionService _transactionService = TransactionService();
  final InstallmentService _installmentService = InstallmentService();
  
  ShareholderModel? _shareholderProfile;
  List<InvestmentHistoryModel> _investmentHistory = [];
  BalanceModel? _currentBalance;
  List<InstallmentModel> _installments = [];
  
  bool _isLoadingProfile = true;
  bool _isLoadingHistory = true;
  bool _isLoadingBalance = true;
  bool _isLoadingInstallments = true;
  
  String _profileErrorMessage = '';
  String _historyErrorMessage = '';
  String _balanceErrorMessage = '';
  String _installmentsErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _loadAllData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadProfile(),
      _loadInvestmentHistory(),
      _loadBalanceData(),
      _loadInstallmentsData(),
    ]);
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoadingProfile = true;
        _profileErrorMessage = '';
      });

      final profile = await _shareholderService.getCurrentShareholderProfile();

      if (mounted) {
        setState(() {
          _shareholderProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profileErrorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _loadInvestmentHistory() async {
    try {
      setState(() {
        _isLoadingHistory = true;
        _historyErrorMessage = '';
      });

      final history = await _shareholderService.getMyInvestmentHistory();

      if (mounted) {
        setState(() {
          _investmentHistory = history;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyErrorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _loadBalanceData() async {
    try {
      setState(() {
        _isLoadingBalance = true;
        _balanceErrorMessage = '';
      });

      final balance = await _transactionService.getCurrentBalance();

      if (mounted) {
        setState(() {
          _currentBalance = balance;
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _balanceErrorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingBalance = false;
        });
      }
    }
  }

  Future<void> _loadInstallmentsData() async {
    try {
      setState(() {
        _isLoadingInstallments = true;
        _installmentsErrorMessage = '';
      });

      final installments = await _installmentService.getAllInstallments();

      if (mounted) {
        setState(() {
          _installments = installments;
          _isLoadingInstallments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _installmentsErrorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingInstallments = false;
        });
      }
    }
  }

  void _navigateToProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('প্রোফাইল পেজ শীঘ্রই আসছে')),
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
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

  Widget _buildLoadingCard(String message) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              CircularProgressIndicator(color: Colors.amber.shade300, strokeWidth: 3),
              const SizedBox(height: 16),
              Text(message,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, VoidCallback onRetry) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('পুনরায় চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    if (_isLoadingProfile) {
      return _buildLoadingCard('প্রোফাইল লোড হচ্ছে...');
    }

    if (_profileErrorMessage.isNotEmpty) {
      return _buildErrorCard(_profileErrorMessage, _loadProfile);
    }

    if (_shareholderProfile == null) {
      return _buildErrorCard('প্রোফাইল পাওয়া যায়নি', _loadProfile);
    }

    final profile = _shareholderProfile!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
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
                    child: Icon(Icons.person, color: Colors.amber.shade300, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(profile.status).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            profile.status == 'Active' ? 'সক্রিয়' : 'নিষ্ক্রিয়',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '#${profile.id}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Financial Overview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildFinancialRow('মোট বিনিয়োগ', profile.getFormattedInvestment(), 
                        Colors.blue.shade300, Icons.trending_up),
                    const SizedBox(height: 12),
                    _buildFinancialRow('মোট আয়', '৳${profile.totalEarning.toStringAsFixed(2)}', 
                        Colors.green.shade300, Icons.account_balance),
                    const SizedBox(height: 12),
                    _buildFinancialRow('বর্তমান ব্যালেন্স', profile.getFormattedBalance(), 
                        Colors.amber.shade300, Icons.account_balance_wallet),
                    const SizedBox(height: 12),
                    _buildFinancialRow('মোট শেয়ার', profile.totalShare.toString(), 
                        Colors.purple.shade300, Icons.pie_chart),
                    const SizedBox(height: 12),
                    _buildFinancialRow('ROI', '${profile.roi.toStringAsFixed(2)}%', 
                        Colors.orange.shade300, Icons.percent),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contact Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'যোগাযোগের তথ্য',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.email, profile.email),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone, profile.phone),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_city, '${profile.house}, ${profile.zila}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.calendar_today, 'যোগদান: ${profile.getFormattedJoinDate()}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    if (_isLoadingBalance) {
      return _buildLoadingCard('ব্যালেন্স লোড হচ্ছে...');
    }

    if (_balanceErrorMessage.isNotEmpty) {
      return _buildErrorCard('ব্যালেন্স লোড করতে সমস্যা: $_balanceErrorMessage', _loadBalanceData);
    }

    if (_currentBalance == null) {
      return _buildErrorCard('ব্যালেন্স ডেটা পাওয়া যায়নি', _loadBalanceData);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
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
                    child: Icon(Icons.account_balance_wallet,
                        color: Colors.amber.shade300, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'প্রধান ব্যালেন্স',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.amber.shade300),
                    onPressed: _loadBalanceData,
                    tooltip: 'রিফ্রেশ',
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat('মোট বিনিয়োগ',
                            _currentBalance!.totalInvestment, Colors.blue.shade300),
                        _buildMiniStat(
                            'মোট মুনাফা',
                            _currentBalance!.totalEarnings,
                            Colors.green.shade300),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat('পণ্য খরচ',
                            _currentBalance!.totalProductCost, Colors.red.shade300),
                        _buildMiniStat(
                            'রক্ষণাবেক্ষণ',
                            _currentBalance!.totalMaintenanceCost,
                            Colors.orange.shade300),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'নিট লাভ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '৳${_currentBalance!.netProfit.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _currentBalance!.netProfit >= 0
                                ? Colors.green.shade300
                                : Colors.red.shade300,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '৳${value.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentHistorySection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: Colors.amber.shade300, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'বিনিয়োগ ইতিহাস',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.amber.shade300),
                    onPressed: _loadInvestmentHistory,
                    tooltip: 'রিফ্রেশ',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_isLoadingHistory)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: Colors.amber.shade300),
                  ),
                )
              else if (_historyErrorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text(
                        _historyErrorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                )
              else if (_investmentHistory.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'কোন বিনিয়োগ ইতিহাস পাওয়া যায়নি',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _investmentHistory.map(_buildInvestmentHistoryCard).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestmentHistoryCard(InvestmentHistoryModel history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                history.getFormattedAmount(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade300,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300.withOpacity(0.5)),
                ),
                child: Text(
                  history.getFormattedDate(),
                  style: TextStyle(
                    color: Colors.blue.shade100,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            history.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.white.withOpacity(0.5)),
              const SizedBox(width: 6),
              Text(
                'দ্বারা: ${history.performedBy}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentsSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.amber.shade300, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'কিস্তি তালিকা',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.amber.shade300),
                    onPressed: _loadInstallmentsData,
                    tooltip: 'রিফ্রেশ',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_isLoadingInstallments)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: Colors.amber.shade300),
                  ),
                )
              else if (_installmentsErrorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'কিস্তি লোড করতে সমস্যা: $_installmentsErrorMessage',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                )
              else if (_installments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.credit_card_off, size: 64, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'কোন কিস্তি পাওয়া যায়নি',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _installments.map(_buildInstallmentCard).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstallmentCard(InstallmentModel installment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      installment.product?.name ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(installment.status).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  installment.status == 'ACTIVE' ? 'সক্রিয়' :
                  installment.status == 'COMPLETED' ? 'সম্পন্ন' :
                  installment.status == 'PENDING' ? 'অপেক্ষমাণ' :
                  installment.status == 'OVERDUE' ? 'বকেয়া' : installment.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInstallmentInfoColumn(
                  'মোট টাকা',
                  '৳${installment.totalAmountOfProduct.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildInstallmentInfoColumn(
                  'অগ্রিম',
                  '৳${installment.advancedPaid.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInstallmentInfoColumn(
                  'মাসিক কিস্তি',
                  '৳${installment.monthlyInstallmentAmount?.toStringAsFixed(2) ?? 'N/A'}',
                ),
              ),
              Expanded(
                child: _buildInstallmentInfoColumn(
                  'মেয়াদ',
                  '${installment.installmentMonths} মাস',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInstallmentInfoColumn(
                  'সুদ হার',
                  '${installment.interestRate}%',
                ),
              ),
              Expanded(
                child: _buildInstallmentInfoColumn(
                  'এজেন্ট',
                  installment.givenProductAgent?.name ?? 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = [
      Colors.deepPurple.shade900,
      Colors.deepPurple.shade700,
      Colors.purple.shade500,
    ];

    return Scaffold(
      appBar: TopBar(
        title: 'শেয়ারহোল্ডার ড্যাশবোর্ড',
        onProfileTap: _navigateToProfile,
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 6),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAllData,
            color: Colors.amber.shade300,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Welcome Header
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.amber.shade400,
                                        Colors.orange.shade500,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.5),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.business_center,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'স্বাগতম!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _shareholderProfile?.name ?? 'শেয়ারহোল্ডার',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(0.95),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Profile Card
                      _buildProfileCard(),

                      const SizedBox(height: 20),

                      // Balance Card
                      _buildBalanceCard(),

                      const SizedBox(height: 20),

                      // Investment History
                      _buildInvestmentHistorySection(),

                      const SizedBox(height: 20),

                      // Installments Section
                      _buildInstallmentsSection(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}