import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/sidebar.dart';
import 'products_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String currentPage = 'dashboard';

  @override
  Widget build(BuildContext context) {
    Widget pageContent;
    switch (currentPage) {
      case 'all_products':
      case 'add_product':
        pageContent = const ProductsPage();
        break;
      default:
        pageContent = const Center(
          child: Text(
            'Welcome to Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentPage == 'dashboard'
              ? 'Dashboard'
              : currentPage == 'all_products'
                  ? 'All Products'
                  : 'Add Product',
        ),
      ),
      drawer: SideBar(
        onItemSelected: (page) {
          setState(() => currentPage = page);
          Navigator.pop(context);
        },
      ),
      body: pageContent,
    );
  }
}
