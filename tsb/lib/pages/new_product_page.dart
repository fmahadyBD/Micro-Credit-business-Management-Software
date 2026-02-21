import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../models/agent_model.dart';
import '../models/member_model.dart';
import '../services/product_service.dart';
import '../services/agent_service.dart';
import '../services/member_service.dart';

class NewProductPage extends StatefulWidget {
  final ProductModel? product;

  const NewProductPage({super.key, this.product});

  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final AgentService _agentService = AgentService();
  final MemberService _memberService = MemberService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _agentSearchController = TextEditingController();
  final TextEditingController _memberSearchController = TextEditingController();

  List<AgentModel> _agents = [];
  List<AgentModel> _filteredAgents = [];
  List<MemberModel> _members = [];
  List<MemberModel> _filteredMembers = [];
  final List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  final List<String> _imagesToDelete = [];

  AgentModel? _selectedAgent;
  MemberModel? _selectedMember;
  bool _isDeliveryRequired = false;
  bool _isLoading = false;
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _loadData();
    _initializeForm();

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _agentSearchController.dispose();
    _memberSearchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.product != null) {
      final product = widget.product!;
      _nameController.text = product.name;
      _categoryController.text = product.category;
      _descriptionController.text = product.description ?? '';
      _priceController.text = product.price.toString();
      _costPriceController.text = product.costPrice.toString();
      _isDeliveryRequired = product.isDeliveryRequired;
      
      // Load existing images
      _existingImageUrls = product.imageFilePaths ?? [];
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();

    _nameController.clear();
    _categoryController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _costPriceController.clear();
    _agentSearchController.clear();
    _memberSearchController.clear();

    setState(() {
      _selectedImages.clear();
      _existingImageUrls.clear();
      _imagesToDelete.clear();
      _selectedAgent = null;
      _selectedMember = null;
      _isDeliveryRequired = false;
      _filteredAgents = List.from(_agents);
      _filteredMembers = List.from(_members);
    });

    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final agents = await _agentService.getAllAgents();
      final members = await _memberService.getAllMembers();

      setState(() {
        _agents = agents;
        _filteredAgents = agents;
        _members = members;
        _filteredMembers = members;

        if (widget.product != null) {
          final product = widget.product!;

          // Set agent
          if (product.soldByAgentId != null) {
            try {
              _selectedAgent = _agents.firstWhere(
                (agent) => agent.id == product.soldByAgentId,
              );
              _agentSearchController.text = _selectedAgent?.name ?? '';
            } catch (e) {
              print('Agent not found with ID: ${product.soldByAgentId}');
            }
          }

          // Set member
          if (product.whoRequestId != null) {
            try {
              _selectedMember = _members.firstWhere(
                (member) => member.id == product.whoRequestId,
              );
              _memberSearchController.text = _selectedMember?.name ?? '';
            } catch (e) {
              print('Member not found with ID: ${product.whoRequestId}');
            }
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('ডেটা লোড করতে ব্যর্থ: $e');
    }
  }

  void _filterAgents(String query) {
    setState(() {
      _filteredAgents = _agents.where((agent) {
        return agent.name.toLowerCase().contains(query.toLowerCase()) ||
            (agent.phone.contains(query)) ||
            (agent.email.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
  }

  void _filterMembers(String query) {
    setState(() {
      _filteredMembers = _members.where((member) {
        return member.name.toLowerCase().contains(query.toLowerCase()) ||
            (member.phone.contains(query)) ||
            (member.nidCardNumber.contains(query));
      }).toList();
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        for (var pickedFile in pickedFiles) {
          final file = File(pickedFile.path);
          final fileSize = await file.length();

          if (!ProductService.validateImageSize(fileSize)) {
            _showErrorSnackbar(
                'ছবি ${pickedFile.name} এর সাইজ খুব বড়। সর্বোচ্চ সাইজ ৫MB।');
            continue;
          }

          setState(() {
            _selectedImages.add(file);
          });
        }
      }
    } catch (e) {
      _showErrorSnackbar('ছবি নির্বাচন করতে ব্যর্থ: $e');
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      final removedImage = _existingImageUrls.removeAt(index);
      _imagesToDelete.add(removedImage);
    });
    _showSuccessSnackbar('ছবি মুছে ফেলার জন্য চিহ্নিত করা হয়েছে');
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

Future<void> _createProduct() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedAgent == null) {
    _showErrorSnackbar('দয়া করে একজন এজেন্ট নির্বাচন করুন');
    return;
  }

  if (_selectedMember == null) {
    _showErrorSnackbar('দয়া করে একজন সদস্য নির্বাচন করুন');
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  try {
    final product = ProductModel(
      id: widget.product?.id ?? 0,
      name: _nameController.text,
      category: _categoryController.text,
      description: _descriptionController.text.isEmpty 
          ? '' // Use empty string instead of null
          : _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
      totalPrice: (double.tryParse(_priceController.text) ?? 0.0) +
          (double.tryParse(_costPriceController.text) ?? 0.0),
      isDeliveryRequired: _isDeliveryRequired,
      dateAdded: widget.product?.dateAdded ?? DateTime.now(),
      imageFilePaths: widget.product?.imageFilePaths ?? [],
      soldByAgentId: _selectedAgent!.id,
      whoRequestId: _selectedMember!.id,
      soldByAgentName: _selectedAgent!.name,
      whoRequestName: _selectedMember!.name,
    );

    ProductModel savedProduct;

    if (widget.product != null) {
      // UPDATE existing product with image management
      savedProduct = await _productService.updateProduct(product);
      
      // Handle image deletions
      for (String imagePath in _imagesToDelete) {
        try {
          await _productService.deleteProductImage(product.id, imagePath);
        } catch (e) {
          print('Failed to delete image: $e');
        }
      }
      
      // Handle new image uploads
      if (_selectedImages.isNotEmpty) {
        final imageFiles = await Future.wait(
          _selectedImages.map((file) async {
            final fileBytes = await file.readAsBytes();
            return ProductService.createMultipartFile(
              fileBytes,
              'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
          }),
        );
        
        await _productService.uploadProductImages(product.id, imageFiles);
      }
      
    } else {
      // CREATE new product
      if (_selectedImages.isNotEmpty) {
        final imageFiles = await Future.wait(
          _selectedImages.map((file) async {
            final fileBytes = await file.readAsBytes();
            return ProductService.createMultipartFile(
              fileBytes,
              'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
          }),
        );

        savedProduct = await _productService.createProductWithImages(
          product: product,
          images: imageFiles,
        );
      } else {
        savedProduct = await _productService.createProduct(product);
      }
    }

    if (mounted) {
      _showSuccessSnackbar(
        widget.product != null
            ? 'পণ্য সফলভাবে আপডেট হয়েছে!'
            : 'পণ্য সফলভাবে তৈরি হয়েছে!',
      );

      if (widget.product == null) {
        await Future.delayed(const Duration(milliseconds: 1500));
        _resetForm();
        _showInfoSnackbar('ফর্ম রিসেট করা হয়েছে। আরেকটি পণ্য যোগ করার জন্য প্রস্তুত।');
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pop(context);
      }
    }
  } catch (e) {
    _showErrorSnackbar('পণ্য সংরক্ষণ করতে ব্যর্থ: $e');
  } finally {
    setState(() {
      _isSubmitting = false;
    });
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
        duration: const Duration(seconds: 3),
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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfoSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildImageSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'পণ্যের ছবিসমূহ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Existing Images
            if (_existingImageUrls.isNotEmpty) ...[
              Text(
                'বর্তমান ছবি (${_existingImageUrls.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _existingImageUrls.asMap().entries.map((entry) {
                  final index = entry.key;
                  final imageUrl = entry.value;
                  final fullImageUrl = _productService.getImageUrl(imageUrl);
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, size: 24, color: Colors.grey),
                                      SizedBox(height: 4),
                                      Text('ব্যর্থ', style: TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ),
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
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeExistingImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // New Images Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product != null ? 'নতুন ছবি যোগ করুন' : 'ছবি নির্বাচন করুন',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(_selectedImages.isEmpty ? 'ছবি যোগ করুন' : 'আরও ছবি যোগ করুন'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            
            // New Images Preview
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'নতুন ছবি (${_selectedImages.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeNewImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
            
            // Summary
            if (_existingImageUrls.isNotEmpty || _selectedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.product != null 
                          ? '${_existingImageUrls.length} টি বর্তমান ছবি • ${_selectedImages.length} টি নতুন ছবি • ${_imagesToDelete.length} টি মুছে ফেলার জন্য চিহ্নিত'
                          : '${_selectedImages.length} টি ছবি আপলোডের জন্য নির্বাচিত',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'পণ্য সম্পাদনা করুন' : 'নতুন পণ্য'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        actions: [
          if (widget.product == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetForm,
              tooltip: 'ফর্ম রিসেট করুন',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag,
                                    color: Colors.blue.shade700,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.product != null
                                        ? 'পণ্য সম্পাদনা করুন'
                                        : 'নতুন পণ্য যোগ করুন',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.product != null
                                  ? 'পণ্যের বিবরণ এবং ছবি আপডেট করুন'
                                  : 'নতুন পণ্য যোগ করতে নিচের ফর্মটি পূরণ করুন',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Basic Information Section
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'মৌলিক তথ্য',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _nameController,
                      label: 'পণ্যের নাম *',
                      icon: Icons.shopping_bag_outlined,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _categoryController,
                      label: 'ক্যাটাগরি *',
                      icon: Icons.category_outlined,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _descriptionController,
                      label: 'বিবরণ',
                      icon: Icons.description_outlined,
                      isRequired: false,
                    ),
                    const SizedBox(height: 24),

                    // Financial Information Section
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'আর্থিক তথ্য',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'বিক্রয় মূল্য *',
                            icon: Icons.attach_money_outlined,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'দয়া করে বিক্রয় মূল্য লিখুন';
                              }
                              if (double.tryParse(value) == null) {
                                return 'দয়া করে একটি বৈধ মূল্য লিখুন';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _costPriceController,
                            label: 'ক্রয় মূল্য *',
                            icon: Icons.money_off_outlined,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'দয়া করে ক্রয় মূল্য লিখুন';
                              }
                              if (double.tryParse(value) == null) {
                                return 'দয়া করে একটি বৈধ মূল্য লিখুন';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Images Section
                    _buildImageSection(),
                    const SizedBox(height: 24),

                    // Relationships Section
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'সম্পর্ক',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSearchableDropdown<AgentModel>(
                      label: 'বিক্রয়কারী এজেন্ট *',
                      icon: Icons.person_outline,
                      searchController: _agentSearchController,
                      items: _filteredAgents,
                      displayString: (agent) {
                        final phone = agent.phone ?? 'ফোন নেই';
                        return '${agent.name} - $phone';
                      },
                      selectedItem: _selectedAgent,
                      onSelected: (agent) {
                        setState(() {
                          _selectedAgent = agent;
                        });
                      },
                      onSearchChanged: _filterAgents,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    _buildSearchableDropdown<MemberModel>(
                      label: 'অনুরোধকারী সদস্য *',
                      icon: Icons.people_outline,
                      searchController: _memberSearchController,
                      items: _filteredMembers,
                      displayString: (member) {
                        final phone = member.phone ?? 'ফোন নেই';
                        return '${member.name} - $phone';
                      },
                      selectedItem: _selectedMember,
                      onSelected: (member) {
                        setState(() {
                          _selectedMember = member;
                        });
                      },
                      onSearchChanged: _filterMembers,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    // Delivery Option
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SwitchListTile(
                          title: const Text('ডেলিভারি প্রয়োজন'),
                          subtitle:
                              const Text('সক্ষম করুন যদি পণ্যটির ডেলিভারি প্রয়োজন হয়'),
                          secondary: Icon(
                            Icons.local_shipping_outlined,
                            color: Colors.blue.shade700,
                          ),
                          value: _isDeliveryRequired,
                          onChanged: (value) {
                            setState(() {
                              _isDeliveryRequired = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _createProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        widget.product != null
                                            ? Icons.update
                                            : Icons.add,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        widget.product != null
                                            ? 'পণ্য আপডেট করুন'
                                            : 'পণ্য তৈরি করুন',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.blue.shade700),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            floatingLabelStyle: TextStyle(color: Colors.blue.shade700),
          ),
          keyboardType: keyboardType,
          validator: validator ??
              (isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'দয়া করে ${label.replaceAll(' *', '')} লিখুন';
                      }
                      return null;
                    }
                  : null),
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown<T>({
    required String label,
    required IconData icon,
    required TextEditingController searchController,
    required List<T> items,
    required String Function(T) displayString,
    required T? selectedItem,
    required Function(T?) onSelected,
    required Function(String) onSearchChanged,
    bool isRequired = false,
  }) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.blue.shade700),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
                floatingLabelStyle: TextStyle(color: Colors.blue.shade700),
              ),
              onChanged: onSearchChanged,
              validator: isRequired
                  ? (value) {
                      if (selectedItem == null) {
                        return 'দয়া করে ${label.replaceAll(' *', '')} নির্বাচন করুন';
                      }
                      return null;
                    }
                  : null,
            ),
            if (searchController.text.isNotEmpty && items.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(
                          icon,
                          color: Colors.blue.shade700,
                          size: 16,
                        ),
                      ),
                      title: Text(displayString(item)),
                      onTap: () {
                        onSelected(item);
                        searchController.text = displayString(item);
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
              ),
            if (selectedItem != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.blue.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(displayString(selectedItem))),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        onSelected(null);
                        searchController.clear();
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}