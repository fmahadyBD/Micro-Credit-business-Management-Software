import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SideBar extends StatefulWidget {
  final Function(String) onItemSelected;

  const SideBar({super.key, required this.onItemSelected});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedItem = 'dashboard';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectItem(String page) {
    setState(() => _selectedItem = page);
    widget.onItemSelected(page);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      child: Column(
        children: [
          // Animated Header with Custom Icon
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            )),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade500,
                    Colors.deepPurple.shade400,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ UPDATED: Custom App Icon
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'assets/icon/app_icon.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback to default icon if image fails to load
                                      return const Icon(
                                        Icons.admin_panel_settings,
                                        size: 36,
                                        color: Colors.deepPurple,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'তেজপাতা শেয়ার বিজনেস',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'এডমিন প্যানেল',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: FadeTransition(
              opacity: _animationController,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Dashboard
                  _buildMenuItem(
                    icon: Icons.dashboard_rounded,
                    title: 'ড্যাশবোর্ড',
                    page: 'dashboard',
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),
                  const SizedBox(height: 8),

                  // Products Section
                  _buildExpansionTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'পণ্য',
                    children: [
                      _buildSubMenuItem(
                          'সকল পণ্য', 'all_products', Icons.list_alt),
                      _buildSubMenuItem(
                          'নতুন পণ্য', 'add_product', Icons.add_box),
                    ],
                  ),

                  // Users Section
                  _buildExpansionTile(
                    icon: Icons.people_outline,
                    title: 'ব্যবহারকারী',
                    children: [
                      _buildSubMenuItem(
                          'সকল ব্যবহারকারী', 'all_users', Icons.people_alt_outlined),
                    ],
                  ),

                  // Members Section
                  _buildExpansionTile(
                    icon: Icons.card_membership_outlined,
                    title: 'সদস্য',
                    children: [
                      _buildSubMenuItem(
                          'সকল সদস্য', 'all_members', Icons.group),
                      _buildSubMenuItem(
                          'নতুন সদস্য', 'new_member', Icons.person_add_alt),
                    ],
                  ),

                  // Shareholders Section
                  _buildExpansionTile(
                    icon: Icons.business_center_outlined,
                    title: 'শেয়ারহোল্ডার',
                    children: [
                      _buildSubMenuItem('সকল শেয়ারহোল্ডার', 'all_shareholders',
                          Icons.business),
                      _buildSubMenuItem('নতুন শেয়ারহোল্ডার', 'add_shareholder',
                          Icons.add_business),
                    ],
                  ),

                  // Installment Section
                  _buildExpansionTile(
                    icon: Icons.payment_outlined,
                    title: 'কিস্তি',
                    children: [
                      _buildSubMenuItem(
                          'কিস্তি ব্যবস্থাপনা',
                          'manage_installment',
                          Icons.account_balance_wallet_outlined),
                      _buildSubMenuItem(
                          'নতুন কিস্তি', 'add_installment', Icons.add_card),
                    ],
                  ),

                  // Payment Section
                  _buildMenuItem(
                    icon: Icons.receipt_long,
                    title: 'পেমেন্ট রেকর্ড',
                    page: 'record_payment',
                  ),

                  // Agent Section
                  _buildExpansionTile(
                    icon: Icons.support_agent_outlined,
                    title: 'এজেন্ট',
                    children: [
                      _buildSubMenuItem(
                          'সকল এজেন্ট', 'all_agents', Icons.people_alt),
                      _buildSubMenuItem(
                          'নতুন এজেন্ট', 'new_agent', Icons.person_add_alt_1),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Theme Toggle at Bottom
          const Divider(height: 1),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade800.withOpacity(0.3)
                  : Colors.grey.shade100,
            ),
            child: ListTile(
              leading: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                color: Colors.deepPurple,
              ),
              title: Text(
                isDark ? 'লাইট মোড' : 'ডার্ক মোড',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: Switch(
                value: isDark,
                onChanged: (value) => themeProvider.toggleTheme(),
                activeThumbColor: Colors.deepPurple,
              ),
              onTap: () => themeProvider.toggleTheme(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String page,
  }) {
    final isSelected = _selectedItem == page;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.deepPurple.withOpacity(0.15),
                        Colors.deepPurple.withOpacity(0.05),
                      ],
                    )
                  : null,
              border: isSelected
                  ? Border.all(
                      color: Colors.deepPurple.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: ListTile(
              leading: Icon(
                icon,
                color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
                size: 24,
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.deepPurple : null,
                  fontSize: 15,
                ),
              ),
              onTap: () => _selectItem(page),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpansionTile({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ExpansionTile(
          leading: Icon(icon, size: 24, color: Colors.grey.shade700),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(left: 8, bottom: 8),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(String title, String page, IconData icon) {
    final isSelected = _selectedItem == page;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected
            ? Colors.deepPurple.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.deepPurple : null,
          ),
        ),
        onTap: () => _selectItem(page),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}