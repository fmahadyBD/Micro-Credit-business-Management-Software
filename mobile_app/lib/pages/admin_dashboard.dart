// lib/pages/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/sidebar.dart';
import 'package:mobile_app/widgets/topbar.dart';
import 'package:mobile_app/pages/all_users_page.dart';
import 'package:mobile_app/pages/products_page.dart';
import 'package:mobile_app/pages/all_agents_page.dart';
import 'package:mobile_app/pages/all_members_page.dart';
import 'package:mobile_app/pages/new_member_page.dart';

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
      
      case 'all_agents':
        pageContent = const AllAgentsPage();
        break;
      
      case 'all_members':
        pageContent = const AllMembersPage();
        break;
      
      case 'new_member':
        pageContent = const NewMemberPage();
        break;
      
      default:
        pageContent = _buildBlankDashboard();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: pageContent,
      ),
    );
  }

  /// Blank placeholder for now
  Widget _buildBlankDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Dashboard is currently empty',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select an item from the sidebar to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
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
          Navigator.pop(context); // Close drawer
        },
      ),
      body: _buildPageContent(),
    );
  }
}