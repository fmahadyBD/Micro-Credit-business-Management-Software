import 'package:flutter/material.dart';
import 'package:mobile_app/pages/MonthlyInstallmentReturnsPage.dart';
import 'all_shareholders_page.dart';
import 'new_shareholder_page.dart';
import '../screens/installment/installment_add_screen.dart';
import '../screens/installment/installment_list_screen.dart';
import '../screens/payment/payment_record_screen.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import 'all_users_page.dart';
import 'all_agents_page.dart';
import 'all_members_page.dart';
import 'new_member_page.dart';
import 'all_products_page.dart';
import 'new_product_page.dart';
import 'profile_page.dart';
import 'dashboard_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  String currentPage = 'dashboard'; // Set default to dashboard
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

  // Add this method to handle profile navigation
  void _navigateToProfile() {
    print('🔵 AdminDashboard: Navigating to profile page');
    setState(() {
      currentPage = 'profile';
      _animationController.reset();
      _animationController.forward();
    });
  }

  String _getPageTitle() {
    final titles = {
      'dashboard': 'ড্যাশবোর্ড', // Dashboard
      'all_products': 'সমস্ত পণ্য', // All Products
      'add_product': 'নতুন পণ্য', // Add Product
      'all_users': 'সমস্ত ব্যবহারকারী', // All Users
      'all_members': 'সমস্ত সদস্য', // All Members
      'new_member': 'নতুন সদস্য', // New Member
      'all_shareholders': 'সমস্ত শেয়ারহোল্ডার', // All Shareholders
      'add_shareholder': 'নতুন শেয়ারহোল্ডার', // Add Shareholder
      'manage_installment': 'কিস্তি ব্যবস্থাপনা', // Manage Installment
      'add_installment': 'নতুন কিস্তি', // Add Installment
      'record_payment': 'পেমেন্ট রেকর্ড', // Record Payment
      'all_agents': 'সমস্ত এজেন্ট', // All Agents
      'new_agent': 'নতুন এজেন্ট', // New Agent
      'profile': 'আমার প্রোফাইল', // My Profile
      'monthly_installment_returns': 'এই মাসের কিস্তি ফেরত', // ⭐ ADD THIS LINE
    };
    return titles[currentPage] ?? 'ড্যাশবোর্ড'; // Default to Dashboard
  }

  Widget _buildPageContent() {
    Widget pageContent;

    switch (currentPage) {
      case 'dashboard': // Add dashboard case
        pageContent = const DashboardPage();
        break;
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
      case 'all_shareholders':
        pageContent = const AllShareholdersPage();
        break;
      case 'add_shareholder':
        pageContent = const NewShareholderPage();
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
      case 'profile':
        pageContent = const ProfilePage();
        break;
      case 'monthly_installment_returns': // ⭐ ADD THIS CASE
        pageContent = const MonthlyInstallmentReturnsPage();
        break;
      default:
        pageContent = const DashboardPage(); // Default to dashboard
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: pageContent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: _getPageTitle(),
        onProfileTap: _navigateToProfile,
      ),
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