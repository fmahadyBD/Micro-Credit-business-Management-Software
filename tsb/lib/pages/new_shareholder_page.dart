import 'package:flutter/material.dart';
import '../models/shareholder_model.dart';
import '../services/shareholder_service.dart';

class NewShareholderPage extends StatefulWidget {
  const NewShareholderPage({super.key});

  @override
  State<NewShareholderPage> createState() => _NewShareholderPageState();
}

class _NewShareholderPageState extends State<NewShareholderPage> with SingleTickerProviderStateMixin {
  final ShareholderService _shareholderService = ShareholderService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _nomineeController = TextEditingController();
  final TextEditingController _zilaController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _investmentController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  String _selectedStatus = 'Active';
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;
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
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _nidController.clear();
    _nomineeController.clear();
    _zilaController.clear();
    _houseController.clear();
    _investmentController.clear();
    _roleController.clear();
    
    setState(() {
      _selectedStatus = 'Active';
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _createShareholder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final shareholder = ShareholderModel(
        id: 0,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        nidCard: _nidController.text,
        nominee: _nomineeController.text,
        zila: _zilaController.text,
        house: _houseController.text,
        investment: double.tryParse(_investmentController.text) ?? 0.0,
        totalShare: 0,
        totalEarning: 0.0,
        currentBalance: double.tryParse(_investmentController.text) ?? 0.0,
        role: _roleController.text,
        status: _selectedStatus,
        joinDate: _selectedDate,
        roi: 0.0,
        totalValue: 0.0,
      );

      await _shareholderService.createShareholder(shareholder);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('শেয়ারহোল্ডার ${_nameController.text} সফলভাবে তৈরি হয়েছে')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'আরেকটি যোগ করুন',
            textColor: Colors.white,
            onPressed: () {
              // Optionally do something when they tap "Add Another"
            },
          ),
        ),
      );

      // Clear the form instead of navigating back
      _clearForm();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('শেয়ারহোল্ডার তৈরি করতে ব্যর্থ: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          validator: validator ?? (isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return 'দয়া করে $label লিখুন';
            }
            return null;
          } : null),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন শেয়ারহোল্ডার'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        actions: [
          // Optional: Add a clear form button in app bar
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearForm,
            tooltip: 'ফর্ম খালি করুন',
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                            child: Icon(Icons.person_add, color: Colors.blue.shade700, size: 28),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'শেয়ারহোল্ডার তথ্য',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'সিস্টেমে নতুন শেয়ারহোল্ডার যোগ করুন',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Personal Information Section
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'ব্যক্তিগত তথ্য',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _nameController,
                label: 'পুরো নাম *',
                icon: Icons.person_outline,
                isRequired: true,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: 'ইমেইল ঠিকানা *',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'দয়া করে ইমেইল ঠিকানা লিখুন';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'দয়া করে একটি বৈধ ইমেইল ঠিকানা লিখুন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _phoneController,
                label: 'ফোন নম্বর *',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isRequired: true,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _nidController,
                label: 'এনআইডি নম্বর',
                icon: Icons.credit_card_outlined,
              ),
              const SizedBox(height: 24),

              // Address Information Section
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'ঠিকানা তথ্য',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _zilaController,
                label: 'জেলা',
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _houseController,
                label: 'বাড়ির ঠিকানা',
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 24),

              // Financial Information Section
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'আর্থিক তথ্য',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _investmentController,
                label: 'বিনিয়োগের পরিমাণ',
                icon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _roleController,
                label: 'ভূমিকা',
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 16),

              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'স্ট্যাটাস',
                      prefixIcon: Icon(Icons.stairs_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: ['Active', 'Inactive'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status == 'Active' ? 'সক্রিয়' : 'নিষ্ক্রিয়'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'যোগদানের তারিখ',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nominee Information Section
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'নমিনি তথ্য',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _nomineeController,
                label: 'নমিনির নাম',
                icon: Icons.people_outline,
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
                      onPressed: _isLoading ? null : _createShareholder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add_alt_1, size: 20),
                                SizedBox(width: 12),
                                Text(
                                  'শেয়ারহোল্ডার তৈরি করুন',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
}