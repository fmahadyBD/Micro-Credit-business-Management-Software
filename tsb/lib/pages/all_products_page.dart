import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'new_product_page.dart';
import '../services/product_service.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _filterCategory = 'সব';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadProducts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final products = await _productService.getAllProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = _searchQuery.isEmpty || 
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.description.toLowerCase().contains(_searchQuery.toLowerCase()));
        final matchesCategory = _filterCategory == 'সব' || product.category == _filterCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

void _showProductDetails(ProductModel product) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('পণ্যের তথ্য', [
                      _buildDetailRow('নাম', product.name),
                      _buildDetailRow('ধরন', product.category),
                      _buildDetailRow('বিবরণ', product.description ?? 'কোন বিবরণ নেই'),
                      _buildDetailRow('যোগ করার তারিখ', product.getFormattedDate()),
                      _buildDetailRow('ডেলিভারি প্রয়োজন', product.isDeliveryRequired ? 'হ্যাঁ' : 'না'),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('আর্থিক তথ্য', [
                      _buildDetailRow('ক্রয় মূল্য', product.getFormattedCostPrice()),
                      _buildDetailRow('বিক্রয় মূল্য', product.getFormattedPrice()),
                      _buildDetailRow('মোট মূল্য', product.getFormattedTotalPrice()),
                    ]),
                    const SizedBox(height: 16),
                    if (product.soldByAgentName != null)
                      _buildDetailSection('এজেন্ট তথ্য', [
                        _buildDetailRow('বিক্রয় করেছেন', product.soldByAgentName!),
                      ]),
                    if (product.whoRequestName != null)
                      _buildDetailSection('সদস্য তথ্য', [
                        _buildDetailRow('অনুরোধ করেছেন', product.whoRequestName!),
                        if (product.whoRequestPhone != null)
                          _buildDetailRow('ফোন', product.whoRequestPhone!),
                        if (product.whoRequestVillage != null)
                          _buildDetailRow('গ্রাম', product.whoRequestVillage!),
                        if (product.whoRequestZila != null)
                          _buildDetailRow('জেলা', product.whoRequestZila!),
                      ]),
                    if (product.imageFilePaths.isNotEmpty)
                      _buildDetailSection('ছবি', [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.imageFilePaths.map((path) {
                            final imageUrl = _productService.getImageUrl(path);
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditProduct(product);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('সম্পাদনা'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleDelete(product);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('ডিলিট'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewProductPage(product: product),
      ),
    ).then((_) => _loadProducts());
  }

  void _handleDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('ডিলিট নিশ্চিত করুন'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('আপনি কি এই পণ্যটি স্থায়ীভাবে ডিলিট করতে চান?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('ধরন: ${product.category}'),
                  Text('মূল্য: ${product.getFormattedPrice()}'),
                  Text('ক্রয় মূল্য: ${product.getFormattedCostPrice()}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '⚠️ এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ডিলিট'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await _productService.deleteProduct(id);
      _showSuccessSnackbar('পণ্য সফলভাবে ডিলিট করা হয়েছে');
      _loadProducts();
    } catch (e) {
      _showErrorSnackbar('পণ্য ডিলিট করতে ব্যর্থ: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_bag, color: Colors.blue.shade700, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'পণ্য ব্যবস্থাপনা',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: _loadProducts,
                        tooltip: 'রিফ্রেশ',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          _filterProducts();
                        },
                        decoration: InputDecoration(
                          hintText: 'নাম, ধরন, বা বিবরণ দিয়ে খুঁজুন...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _filterCategory,
                        decoration: InputDecoration(
                          labelText: 'ধরন',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          'সব',
                          ..._products.map((p) => p.category).toSet(),
                        ].map((category) {
                          return DropdownMenuItem(
                            value: category, 
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _filterCategory = value!);
                          _filterProducts();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Products Count and Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'মোট পণ্য: ${_filteredProducts.length}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_products.length} মোট • ${_products.map((p) => p.category).toSet().length} ধরন',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Products List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('লোড হচ্ছে...'),
                      ],
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'ত্রুটি: $_errorMessage', 
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadProducts,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('আবার চেষ্টা করুন'),
                            ),
                          ],
                        ),
                      )
                    : _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty ? 'কোন পণ্য পাওয়া যায়নি' : 'মিলছে এমন কোন পণ্য নেই',
                                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isEmpty 
                                    ? 'আপনার প্রথম পণ্য যোগ করে শুরু করুন'
                                    : 'আপনার অনুসন্ধানের শর্ত সামঞ্জস্য করুন',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 768) {
                                  return _buildMobileView();
                                } else {
                                  return _buildDesktopView();
                                }
                              },
                            ),
                          ),
          ),
        ],
      ),
      
      // Floating Action Button for New Product
      floatingActionButton: ScaleTransition(
        scale: _fadeAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewProductPage()),
            ).then((_) => _loadProducts());
          },
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('নতুন পণ্য'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMobileView() {
    return ListView.builder(
      itemCount: _filteredProducts.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Icon(
                Icons.shopping_bag_outlined,
                color: Colors.blue.shade700,
                size: 20,
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.getFormattedPrice()} • ${product.getFormattedDate()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.getFormattedTotalPrice(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () => _showProductDetails(product),
          ),
        );
      },
    );
  }

  Widget _buildDesktopView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            columns: const [
              DataColumn(label: Text('আইডি', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('নাম', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ধরন', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ক্রয় মূল্য', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('বিক্রয় মূল্য', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('মোট মূল্য', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('যোগ করার তারিখ', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ডেলিভারি', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('কর্ম', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _filteredProducts.map((product) {
              return DataRow(
                cells: [
                  DataCell(Text('#${product.id}')),
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          radius: 16,
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.blue.shade700,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(product.name),
                      ],
                    ),
                    onTap: () => _showProductDetails(product),
                  ),
                  DataCell(Text(product.category)),
                  DataCell(Text(product.getFormattedCostPrice())),
                  DataCell(Text(product.getFormattedPrice())),
                  DataCell(
                    Text(
                      product.getFormattedTotalPrice(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  DataCell(Text(product.getFormattedDate())),
                  DataCell(
                    Icon(
                      product.isDeliveryRequired ? Icons.check_circle : Icons.cancel,
                      color: product.isDeliveryRequired ? Colors.green : Colors.grey,
                      size: 18,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility_outlined, size: 18, color: Colors.blue.shade600),
                          onPressed: () => _showProductDetails(product),
                          tooltip: 'বিস্তারিত দেখুন',
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, size: 18, color: Colors.orange.shade600),
                          onPressed: () => _showEditProduct(product),
                          tooltip: 'সম্পাদনা',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade600),
                          onPressed: () => _handleDelete(product),
                          tooltip: 'ডিলিট',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}