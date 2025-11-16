import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile_app/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/balance_model.dart';
import 'package:mobile_app/models/transaction_model.dart';
import 'package:mobile_app/services/transaction_service.dart';
import 'package:mobile_app/screens/installment/installment_model.dart';
import 'package:mobile_app/screens/installment/installment_service.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/widgets/topbar.dart'; // Add this import

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
  String userName = 'Shareholder';
  
  // New state variables for balance and installments
  final TransactionService _transactionService = TransactionService();
  final InstallmentService _installmentService = InstallmentService();
  BalanceModel? _currentBalance;
  List<InstallmentModel> _installments = [];
  bool _isLoadingBalance = true;
  bool _isLoadingInstallments = true;
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
    _loadUserInfo();
    _loadBalanceData();
    _loadInstallmentsData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        final decodedToken = JwtDecoder.decode(token);
        setState(() {
          userName = decodedToken['sub'] ?? 'Shareholder';
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
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
          _balanceErrorMessage = e.toString();
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
          _installmentsErrorMessage = e.toString();
          _isLoadingInstallments = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  // Add this method for profile navigation (required by TopBar)
  void _navigateToProfile() {
    // You can add profile navigation logic here if needed
    print('Shareholder Dashboard: Profile navigation');
    // For now, we'll just show a snackbar or you can navigate to profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile page coming soon')),
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
                    'মোট ব্যালেন্স',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '৳${_currentBalance!.totalBalance.toStringAsFixed(2)}',
                style: TextStyle(
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
                    // First row - Main metrics
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
                    // Second row - Cost metrics
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
                    // Net profit row
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

  Widget _buildInstallmentCard(InstallmentModel installment) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        installment.status,
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
          ),
        ),
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
                _buildLoadingCard('কিস্তি ডেটা লোড হচ্ছে...')
              else if (_installmentsErrorMessage.isNotEmpty)
                _buildErrorCard('কিস্তি লোড করতে সমস্যা: $_installmentsErrorMessage', _loadInstallmentsData)
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
                  children: [
                    ..._installments.map(_buildInstallmentCard).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
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
        title: 'Shareholder Dashboard', // You can customize this title
        onProfileTap: _navigateToProfile, // Added profile navigation callback
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main Welcome Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(48),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(32),
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logo/Icon
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 800),
                                  builder: (context, double value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.amber.shade400,
                                              Colors.orange.shade500,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.amber
                                                  .withOpacity(0.5),
                                              blurRadius: 25,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.business_center,
                                          color: Colors.white,
                                          size: 60,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 32),

                                // Welcome Text
                                Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 12),

                                // User Name
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber.shade300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 24),

                                // Role Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_user,
                                        color: Colors.amber.shade300,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Shareholder',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Welcome Message
                                Text(
                                  'Thank you for being a valued shareholder.\nManage your investments and track installments.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Balance Card
                      _buildBalanceCard(),

                      const SizedBox(height: 32),

                      // Installments Section
                      _buildInstallmentsSection(),

                      const SizedBox(height: 32),

                      // Info Cards
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildInfoCard(
                            icon: Icons.insights,
                            title: 'Analytics',
                            subtitle: 'Coming Soon',
                            color: Colors.blue,
                          ),
                          _buildInfoCard(
                            icon: Icons.account_balance,
                            title: 'Reports',
                            subtitle: 'Coming Soon',
                            color: Colors.green,
                          ),
                          _buildInfoCard(
                            icon: Icons.notifications_active,
                            title: 'Updates',
                            subtitle: 'Coming Soon',
                            color: Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Remove the old logout button since we now have TopBar
                      // The logout functionality is now in the TopBar
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}