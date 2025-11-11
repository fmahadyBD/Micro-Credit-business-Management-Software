import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final Function(String) onItemSelected; // Call to switch pages

  const SideBar({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text(
              'Admin Panel',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),


          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => onItemSelected('dashboard'),
          ),



          ExpansionTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Products'),
            
            children: [
              
              ListTile(
                title: const Text('All Products'),
                onTap: () => onItemSelected('all_products'),
              ),
              
              
              ListTile(
                title: const Text('Add Product'),
                onTap: () => onItemSelected('add_product'),
              )


            ],
          )
        ],
      ),
    );
  }
}
