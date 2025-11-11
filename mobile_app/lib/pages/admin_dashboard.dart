// lib/pages/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/sidebar.dart';
import 'package:mobile_app/widgets/topbar.dart';
import 'package:mobile_app/pages/all_users_page.dart';
import 'products_page.dart';
import 'package:mobile_app/pages/all_agents_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
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
      'dashboard': 'Dashboard',
      'all_products': 'All Products',
      'add_product': 'Add Product',
      'all_users': 'All Users',
      'all_members': 'All Members',
      'new_member': 'New Member',
      'all_shareholders': 'All Shareholders',
      'add_shareholder': 'Add Shareholder',
      'manage_installment': 'Manage Installment',
      'add_installment': 'Add Installment',
      'record_payment': 'Record Payment',
      'all_agents': 'All Agents',
      'new_agent': 'New Agent',
    };
    return titles[currentPage] ?? 'Dashboard';
  }

  Widget _buildPageContent() {
    Widget pageContent;
    
    switch (currentPage) {
      case 'all_products':
      case 'add_product':
        pageContent = const ProductsPage();
        break;
      case 'all_users':
        pageContent = const AllUsersPage();
        break;
      case 'all_members':
        pageContent = _buildPlaceholder('All Members', Icons.card_membership, Colors.green);
        break;
      case 'new_member':
        pageContent = _buildPlaceholder('New Member', Icons.person_add, Colors.teal);
        break;
      case 'all_shareholders':
        pageContent = _buildPlaceholder('All Shareholders', Icons.business, Colors.orange);
        break;
      case 'add_shareholder':
        pageContent = _buildPlaceholder('Add Shareholder', Icons.business_center, Colors.deepOrange);
        break;
      case 'manage_installment':
        pageContent = _buildPlaceholder('Manage Installment', Icons.payment, Colors.purple);
        break;
      case 'add_installment':
        pageContent = _buildPlaceholder('Add Installment', Icons.add_card, Colors.deepPurple);
        break;
      case 'record_payment':
        pageContent = _buildPlaceholder('Record Payment', Icons.receipt_long, Colors.indigo);
        break;
      case 'all_agents':
        // pageContent = _buildPlaceholder('All Agents', Icons.support_agent, Colors.cyan);
        pageContent = const AllAgentsPage();
        break;
      case 'new_agent':
        pageContent = _buildPlaceholder('New Agent', Icons.person_add_alt_1, Colors.lightBlue);
        break;
      default:
        pageContent = _buildDashboardHome();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: pageContent,
      ),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 80, color: color),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This page is under development',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.construction, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.dashboard, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Here\'s what\'s happening today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildDashboardCard(
                'Users',
                '1,234',
                Icons.people,
                Colors.blue,
                '+12%',
              ),
              _buildDashboardCard(
                'Members',
                '567',
                Icons.card_membership,
                Colors.green,
                '+8%',
              ),
              _buildDashboardCard(
                'Shareholders',
                '89',
                Icons.business,
                Colors.orange,
                '+5%',
              ),
              _buildDashboardCard(
                'Agents',
                '45',
                Icons.support_agent,
                Colors.purple,
                '+15%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String count,
    IconData icon,
    Color color,
    String percentage,
  ) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          percentage,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        count,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: _getPageTitle()),
      drawer: SideBar(
        onItemSelected: (page) {
          setState(() {
            currentPage = page;
            _animationController.reset();
            _animationController.forward();
          });
          Navigator.pop(context);
        },
      ),
      body: _buildPageContent(),
    );
  }
}