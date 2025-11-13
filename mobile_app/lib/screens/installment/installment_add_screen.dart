// lib/screens/installment/installment_add_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/models/product_model.dart';
import 'package:mobile_app/models/member_model.dart';
import 'package:mobile_app/models/agent_model.dart';
import 'package:mobile_app/screens/installment/installment_model.dart';
import 'package:mobile_app/screens/installment/installment_service.dart';
import 'package:mobile_app/services/product_service.dart';
import 'package:mobile_app/services/member_service.dart';
import 'package:mobile_app/services/agent_service.dart';
import 'package:http/http.dart' as http;

class InstallmentAddScreen extends StatefulWidget {
  const InstallmentAddScreen({Key? key}) : super(key: key);

  @override
  State<InstallmentAddScreen> createState() => _InstallmentAddScreenState();
}

class _InstallmentAddScreenState extends State<InstallmentAddScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final InstallmentService _installmentService = InstallmentService();
  final ProductService _productService = ProductService();
  final MemberService _memberService = MemberService();
  final AgentService _agentService = AgentService();
  
  // Controllers
  final _searchProductController = TextEditingController();
  final _searchMemberController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _otherCostController = TextEditingController();
  final _advancedPaidController = TextEditingController();
  final _installmentMonthsController = TextEditingController();
  final _interestRateController = TextEditingController();
  
  // Selected data
  ProductModel? _selectedProduct;
  MemberModel? _selectedMember;
  AgentModel? _selectedAgent;
  String _selectedStatus = 'ACTIVE';
  
  // Dropdown data
  List<ProductModel> _products = [];
  List<MemberModel> _members = [];
  List<AgentModel> _agents = [];
  
  // Images
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isLoading = false;
  bool _loadingProducts = false;
  bool _loadingMembers = false;
  bool _keepDataForNext = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    try {
      final agents = await _agentService.getAllAgents();
      setState(() {
        _agents = agents;
        if (_agents.isNotEmpty && _selectedAgent == null) {
          _selectedAgent = _agents.first;
        }
      });
    } catch (e) {
      _showErrorSnackBar('Error loading agents: $e');
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() => _products.clear());
      return;
    }
    
    setState(() => _loadingProducts = true);
    
    try {
      final allProducts = await _productService.getAllProducts();
      setState(() {
        _products = allProducts.where((p) {
          return p.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
        _loadingProducts = false;
      });
    } catch (e) {
      setState(() => _loadingProducts = false);
      _showErrorSnackBar('Error searching products: $e');
    }
  }

  Future<void> _searchMembers(String query) async {
    if (query.isEmpty) {
      setState(() => _members.clear());
      return;
    }
    
    setState(() => _loadingMembers = true);
    
    try {
      final allMembers = await _memberService.getAllMembers();
      setState(() {
        _members = allMembers.where((m) {
          return m.name!.toLowerCase().contains(query.toLowerCase()) ||
                 (m.phone?.contains(query) ?? false);
        }).toList();
        _loadingMembers = false;
      });
    } catch (e) {
      setState(() => _loadingMembers = false);
      _showErrorSnackBar('Error searching members: $e');
    }
  }

  void _selectProduct(ProductModel product) async {
    setState(() {
      _selectedProduct = product;
      _searchProductController.text = product.name;
      _totalAmountController.text = product.price.toString();
      _products.clear();
    });
    
    // Auto-populate agent if product has agent data
    if (product.soldByAgentId != null) {
      try {
        final agent = _agents.firstWhere(
          (a) => a.id == product.soldByAgentId,
        );
        setState(() => _selectedAgent = agent);
        _showSuccessSnackBar('Agent auto-selected from product');
      } catch (e) {
        // If agent not found, keep the first agent or current selection
        print('Agent with ID ${product.soldByAgentId} not found');
      }
    }
    
    // Auto-populate member if product has whoRequest data
    if (product.whoRequestId != null) {
      try {
        final member = await _memberService.getMemberById(product.whoRequestId!);
        setState(() {
          _selectedMember = member;
          _searchMemberController.text = '${member.name} (${member.phone})';
        });
        _showSuccessSnackBar('Member auto-selected from product');
      } catch (e) {
        print('Error auto-selecting member: $e');
        // You might want to show a snackbar here
        _showErrorSnackBar('Member not found for this product');
      }
    }
    
    // Trigger animation for selected product
    _animationController.forward(from: 0.5);
  }

  void _selectMember(MemberModel member) {
    setState(() {
      _selectedMember = member;
      _searchMemberController.text = '${member.name} (${member.phone})';
      _members.clear();
    });
    
    // Trigger animation for selected member
    _animationController.forward(from: 0.5);
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedProduct = null;
      _selectedMember = null;
      _selectedImages.clear();
      _searchProductController.clear();
      _searchMemberController.clear();
      _totalAmountController.clear();
      _otherCostController.clear();
      _advancedPaidController.clear();
      _installmentMonthsController.clear();
      _interestRateController.clear();
      _selectedStatus = 'ACTIVE';
    });
  }

  Future<void> _saveInstallment() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedProduct == null) {
      _showErrorSnackBar('Please select a product');
      return;
    }
    
    if (_selectedMember == null) {
      _showErrorSnackBar('Please select a member');
      return;
    }
    
    if (_selectedAgent == null) {
      _showErrorSnackBar('Please select an agent');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final installment = InstallmentModel(
        productId: _selectedProduct!.id,
        memberId: _selectedMember!.id,
        totalAmountOfProduct: double.parse(_totalAmountController.text),
        otherCost: double.tryParse(_otherCostController.text) ?? 0.0,
        advancedPaid: double.parse(_advancedPaidController.text),
        installmentMonths: int.parse(_installmentMonthsController.text),
        interestRate: double.parse(_interestRateController.text),
        status: _selectedStatus,
        agentId: _selectedAgent!.id,
      );

      if (_selectedImages.isEmpty) {
        await _installmentService.createInstallment(installment);
      } else {
        final imageFiles = await Future.wait(
          _selectedImages.map((file) async {
            final bytes = await file.readAsBytes();
            return http.MultipartFile.fromBytes(
              'images',
              bytes,
              filename: file.path.split('/').last,
            );
          }),
        );
        
        await _installmentService.createInstallmentWithImages(
          installment: installment,
          images: imageFiles,
        );
      }

      _showSuccessSnackBar('Installment created successfully');
      
      if (_keepDataForNext) {
        _formKey.currentState?.reset();
        setState(() {
          _selectedProduct = null;
          _selectedImages.clear();
          _searchProductController.clear();
          _totalAmountController.clear();
          _otherCostController.clear();
          _advancedPaidController.clear();
          _installmentMonthsController.clear();
          _interestRateController.clear();
          _selectedStatus = 'ACTIVE';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Installment created! Member and agent data preserved.')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAnimatedFormField(Widget child, {int index = 0}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildProductSearchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search Product *', style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.grey[800],
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: _searchProductController,
          decoration: InputDecoration(
            hintText: 'Search product by name...',
            prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
            suffixIcon: _loadingProducts 
                ? Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: _searchProducts,
        ),
        if (_products.isNotEmpty) ...[
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            constraints: BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue[100]!),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return InkWell(
                    onTap: () => _selectProduct(product),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index < _products.length - 1 
                                ? Colors.grey[200]! 
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (product.imageFilePaths.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageFilePaths.first,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                  Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image, color: Colors.grey[400]),
                                  ),
                              ),
                            )
                          else
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.shopping_bag, color: Colors.grey[400]),
                            ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  product.category,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '৳${product.price}',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (product.whoRequestName != null) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.person, size: 12, color: Colors.blue[700]),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          product.whoRequestName!,
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMemberSearchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search Member *', style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.grey[800],
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: _searchMemberController,
          decoration: InputDecoration(
            hintText: 'Search member by name or phone...',
            prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
            suffixIcon: _loadingMembers 
                ? Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: _searchMembers,
        ),
        if (_members.isNotEmpty) ...[
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            constraints: BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue[100]!),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];
                  return InkWell(
                    onTap: () => _selectMember(member),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index < _members.length - 1 
                                ? Colors.grey[200]! 
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              (member.name ?? 'N/A').substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name ?? 'N/A',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  member.phone ?? 'N/A',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedProductCard() {
    if (_selectedProduct == null) return SizedBox.shrink();
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.white, Colors.purple[50]!],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.check_circle, color: Colors.green[700], size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Product',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Product details',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 24),
              
              if (_selectedProduct!.imageFilePaths.isNotEmpty)
                Container(
                  height: 150,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _selectedProduct!.imageFilePaths.first,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                        Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                        ),
                    ),
                  ),
                ),
              
              Text(
                _selectedProduct!.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDetailChip(
                    icon: Icons.attach_money,
                    label: 'Price',
                    value: '৳${_selectedProduct!.price}',
                    color: Colors.green,
                  ),
                  _buildDetailChip(
                    icon: Icons.category,
                    label: 'Category',
                    value: _selectedProduct!.category,
                    color: Colors.blue,
                  ),
                  if (_selectedProduct!.soldByAgentName != null)
                    _buildDetailChip(
                      icon: Icons.person_outline,
                      label: 'Agent',
                      value: _selectedProduct!.soldByAgentName!,
                      color: Colors.purple,
                    ),
                  if (_selectedProduct!.whoRequestName != null)
                    _buildDetailChip(
                      icon: Icons.person,
                      label: 'Requester',
                      value: _selectedProduct!.whoRequestName!,
                      color: Colors.orange,
                    ),
                ],
              ),
              
              if (_selectedProduct!.whoRequestPhone != null ||
                  _selectedProduct!.whoRequestVillage != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedProduct!.whoRequestPhone != null)
                        Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              _selectedProduct!.whoRequestPhone!,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      if (_selectedProduct!.whoRequestVillage != null &&
                          _selectedProduct!.whoRequestPhone != null)
                        SizedBox(height: 8),
                      if (_selectedProduct!.whoRequestVillage != null)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_selectedProduct!.whoRequestVillage}, ${_selectedProduct!.whoRequestZila ?? ''}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Installment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAnimatedFormField(_buildProductSearchDropdown()),
              
              if (_selectedProduct != null) ...[
                const SizedBox(height: 16),
                _buildAnimatedFormField(_buildSelectedProductCard()),
              ],
              const SizedBox(height: 24),
              
              _buildAnimatedFormField(_buildMemberSearchDropdown()),
              const SizedBox(height: 24),
              
              // Form Fields with beautiful styling
              _buildAnimatedFormField(
                _buildStyledTextFormField(
                  controller: _totalAmountController,
                  label: 'Total Amount *',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildAnimatedFormField(
                _buildStyledTextFormField(
                  controller: _otherCostController,
                  label: 'Other Cost',
                  icon: Icons.money_off,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildAnimatedFormField(
                _buildStyledTextFormField(
                  controller: _advancedPaidController,
                  label: 'Advanced Payment *',
                  icon: Icons.payment,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildAnimatedFormField(
                _buildStyledTextFormField(
                  controller: _installmentMonthsController,
                  label: 'Installment Months (1-60) *',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final months = int.tryParse(value!);
                    if (months == null || months < 1 || months > 60) {
                      return 'Must be between 1 and 60';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              _buildAnimatedFormField(
                _buildStyledTextFormField(
                  controller: _interestRateController,
                  label: 'Interest Rate (%) *',
                  icon: Icons.trending_up,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildAnimatedFormField(
                _buildStyledDropdown<AgentModel>(
                  value: _selectedAgent,
                  label: 'Agent *',
                  icon: Icons.person,
                  items: _agents,
                  itemBuilder: (agent) => Text(agent.name),
                  onChanged: (value) => setState(() => _selectedAgent = value),
                  validator: (value) => value == null ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildAnimatedFormField(
                _buildStyledDropdown<String>(
                  value: _selectedStatus,
                  label: 'Status',
                  icon: Icons.stairs,
                  items: ['ACTIVE', 'PENDING', 'COMPLETED', 'OVERDUE'],
                  itemBuilder: (status) => Text(status),
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
              ),
              const SizedBox(height: 24),
              
              // Keep data for next installment option
              _buildAnimatedFormField(
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.settings_backup_restore, color: Colors.blue[700]),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Keep for next installment',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Preserve member and agent data',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _keepDataForNext,
                          onChanged: (value) => setState(() => _keepDataForNext = value),
                          activeColor: Colors.blue[700],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Images Section
              _buildAnimatedFormField(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.blue[700]),
                        SizedBox(width: 8),
                        Text(
                          'Document Images',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: Icon(Icons.add_photo_alternate),
                      label: Text('Add Images'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAnimatedFormField(
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return _buildImageCard(_selectedImages[index], index);
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              
              // Action Buttons
              _buildAnimatedFormField(
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveInstallment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save),
                                  SizedBox(width: 8),
                                  Text('Create Installment', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _resetForm,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text('Reset', style: TextStyle(color: Colors.grey[600])),
                          ],
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

  Widget _buildStyledTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildStyledDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: itemBuilder(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildImageCard(File image, int index) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 120,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                image,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchProductController.dispose();
    _searchMemberController.dispose();
    _totalAmountController.dispose();
    _otherCostController.dispose();
    _advancedPaidController.dispose();
    _installmentMonthsController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }
}