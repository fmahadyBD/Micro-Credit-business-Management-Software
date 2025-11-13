import 'package:flutter/material.dart';
import 'package:mobile_app/pages/all_products_page.dart';
import 'package:mobile_app/pages/new_product_page.dart';
import 'package:mobile_app/pages/all_members_page.dart';
import 'package:mobile_app/pages/new_member_page.dart';
import 'package:mobile_app/screens/installment/installment_add_screen.dart';
import 'package:mobile_app/screens/installment/installment_list_screen.dart';
import 'package:mobile_app/screens/payment/payment_record_screen.dart';
import 'package:mobile_app/widgets/agent_sidebar.dart';
import 'package:mobile_app/widgets/topbar.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard>
    with SingleTickerProviderStateMixin {
  String currentPage = 'dashboard';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getPageTitle() {
    final titles = {
      'dashboard': 'Agent Dashboard',
      'all_products': 'All Products',
      'add_product': 'Add Product',
      'all_members': 'All Members',
      'new_member': 'New Member',
      'manage_installment': 'Manage Installment',
      'add_installment': 'Add Installment',
      'record_payment': 'Record Payment',
    };
    return titles[currentPage] ?? 'Agent Dashboard';
  }

  Widget _buildPageContent() {
    Widget pageContent;

    switch (currentPage) {
      case 'all_products':
        pageContent = const AllProductsPage();
        break;

      case 'add_product':
        pageContent = Builder(
          builder: (context) => NewProductPage(
            key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          ),
        );
        break;

      case 'all_members':
        pageContent = const AllMembersPage();
        break;

      case 'new_member':
        pageContent = const NewMemberPage();
        break;

      case 'manage_installment':
        pageContent = const InstallmentListScreen();
        break;

      case 'add_installment':
        pageContent = const InstallmentAddScreen();
        break;

      case 'record_payment':
        pageContent = const PaymentRecordScreen();
        break;

      default:
        pageContent = _buildAgentDashboardHome();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: pageContent,
      ),
    );
  }

  /// Agent Dashboard Home with stats
  Widget _buildAgentDashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back, Agent!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage members, products, and payments',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
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

          const SizedBox(height: 32),

          // Quick Stats Grid
          const Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                icon: Icons.inventory_2_outlined,
                title: 'Products',
                value: '---',
                color: Colors.purple,
              ),
              _buildStatCard(
                icon: Icons.people_outline,
                title: 'Members',
                value: '---',
                color: Colors.green,
              ),
              _buildStatCard(
                icon: Icons.payment_outlined,
                title: 'Installments',
                value: '---',
                color: Colors.orange,
              ),
              _buildStatCard(
                icon: Icons.receipt_long,
                title: 'Payments',
                value: '---',
                color: Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildQuickActionCard(
            icon: Icons.person_add_alt,
            title: 'Add New Member',
            subtitle: 'Register a new member to the system',
            color: Colors.teal,
            onTap: () {
              setState(() {
                currentPage = 'new_member';
                _animationController.reset();
                _animationController.forward();
              });
            },
          ),

          const SizedBox(height: 12),

          _buildQuickActionCard(
            icon: Icons.receipt_long,
            title: 'Record Payment',
            subtitle: 'Record a new payment transaction',
            color: Colors.indigo,
            onTap: () {
              setState(() {
                currentPage = 'record_payment';
                _animationController.reset();
                _animationController.forward();
              });
            },
          ),

          const SizedBox(height: 12),

          _buildQuickActionCard(
            icon: Icons.add_card,
            title: 'Add Installment',
            subtitle: 'Create a new installment plan',
            color: Colors.deepOrange,
            onTap: () {
              setState(() {
                currentPage = 'add_installment';
                _animationController.reset();
                _animationController.forward();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: _getPageTitle()),
      drawer: AgentSideBar(
        onItemSelected: (page) {
          setState(() {
            currentPage = page;
            _animationController.reset();
            _animationController.forward();
          });
          Navigator.pop(context); // Close drawer
        },
      ),
      body: _buildPageContent(),
    );
  }
}