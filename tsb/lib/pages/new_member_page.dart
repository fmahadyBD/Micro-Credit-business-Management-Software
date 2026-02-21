// lib/pages/new_member_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/member_model.dart';
import '../services/member_service.dart';

class NewMemberPage extends StatefulWidget {
  const NewMemberPage({super.key});

  @override
  State<NewMemberPage> createState() => _NewMemberPageState();
}

class _NewMemberPageState extends State<NewMemberPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final MemberService _memberService = MemberService();
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _animationController;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _zilaController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _nidCardNumberController = TextEditingController();
  final TextEditingController _nomineeNameController = TextEditingController();
  final TextEditingController _nomineePhoneController = TextEditingController();
  final TextEditingController _nomineeNidCardNumberController = TextEditingController();

  // Image files
  XFile? _nidCardImage;
  XFile? _photo;
  XFile? _nomineeNidCardImage;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _zilaController.dispose();
    _villageController.dispose();
    _nidCardNumberController.dispose();
    _nomineeNameController.dispose();
    _nomineePhoneController.dispose();
    _nomineeNidCardNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, Function(XFile?) onImagePicked) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      
      if (image != null) {
        // Check file size (5MB limit)
        final fileSize = await image.length();
        if (fileSize > 5 * 1024 * 1024) {
          _showErrorSnackbar('ছবির সাইজ ৫MB এর কম হতে হবে');
          return;
        }
        setState(() => onImagePicked(image));
      }
    } catch (e) {
      _showErrorSnackbar('ছবি নির্বাচন ব্যর্থ: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_nidCardImage == null || _photo == null || _nomineeNidCardImage == null) {
      _showErrorSnackbar('সবগুলো ছবি আবশ্যক');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final member = MemberModel(
        id: 0,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        zila: _zilaController.text.trim(),
        village: _villageController.text.trim(),
        nidCardNumber: _nidCardNumberController.text.trim(),
        nidCardImagePath: null,
        photoPath: null,
        nomineeName: _nomineeNameController.text.trim(),
        nomineePhone: _nomineePhoneController.text.trim(),
        nomineeNidCardNumber: _nomineeNidCardNumberController.text.trim(),
        nomineeNidCardImagePath: null,
        joinDate: DateTime.now(),
        status: 'ACTIVE',
        agents: [],
        installments: [],
      );

      final nidCardFile = await _nidCardImage!.readAsBytes();
      final photoFile = await _photo!.readAsBytes();
      final nomineeNidCardFile = await _nomineeNidCardImage!.readAsBytes();

      final nidCardMultipart = await MemberService.createMultipartFile(
        'nidCardImage',
        nidCardFile,
        _nidCardImage!.name,
      );

      final photoMultipart = await MemberService.createMultipartFile(
        'photo',
        photoFile,
        _photo!.name,
      );

      final nomineeNidCardMultipart = await MemberService.createMultipartFile(
        'nomineeNidCardImage',
        nomineeNidCardFile,
        _nomineeNidCardImage!.name,
      );

      final result = await _memberService.createMemberWithImages(
        member: member,
        nidCardImage: nidCardMultipart,
        photo: photoMultipart,
        nomineeNidCardImage: nomineeNidCardMultipart,
      );

      if (result['success'] == true) {
        _showSuccessSnackbar('সদস্য সফলভাবে তৈরি হয়েছে!');
        _clearForm();
      } else {
        throw Exception(result['message'] ?? 'সদস্য তৈরি করতে ব্যর্থ');
      }
    } catch (e) {
      _showErrorSnackbar('ত্রুটি: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _phoneController.clear();
    _zilaController.clear();
    _villageController.clear();
    _nidCardNumberController.clear();
    _nomineeNameController.clear();
    _nomineePhoneController.clear();
    _nomineeNidCardNumberController.clear();
    setState(() {
      _nidCardImage = null;
      _photo = null;
      _nomineeNidCardImage = null;
    });
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
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

  Widget _buildImagePicker(String title, XFile? image, Function(XFile?) onImagePicked) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (image != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text('নির্বাচিত', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(image.path),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery, onImagePicked),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('পরিবর্তন'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => onImagePicked(null)),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('মুছুন'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery, onImagePicked),
                icon: const Icon(Icons.add_photo_alternate),
                label: Text('$title নির্বাচন করুন'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
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
        title: const Text('নতুন সদস্য যোগ করুন'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearForm,
            tooltip: 'ফর্ম খালি করুন',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: isWide
                    ? _buildWideLayout()
                    : _buildNarrowLayout(),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('সদস্য তৈরি করুন', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersonalInfoSection(),
        const SizedBox(height: 24),
        _buildNomineeSection(),
        const SizedBox(height: 24),
        _buildImagesSection(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildNomineeSection(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(child: _buildImagesSection()),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ব্যক্তিগত তথ্য', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'পুরো নাম *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'আবশ্যক' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'ফোন নম্বর *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? 'আবশ্যক' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _zilaController,
              decoration: const InputDecoration(
                labelText: 'জেলা *',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'আবশ্যক' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _villageController,
              decoration: const InputDecoration(
                labelText: 'গ্রাম *',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'আবশ্যক' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nidCardNumberController,
              decoration: const InputDecoration(
                labelText: 'এনআইডি নম্বর *',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'আবশ্যক' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNomineeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('নমিনির তথ্য', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            TextFormField(
              controller: _nomineeNameController,
              decoration: const InputDecoration(
                labelText: 'নমিনির নাম *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'আবশ্যক' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomineePhoneController,
              decoration: const InputDecoration(
                labelText: 'নমিনির ফোন *',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? 'আবশ্যক' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomineeNidCardNumberController,
              decoration: const InputDecoration(
                labelText: 'নমিনির এনআইডি *',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'আবশ্যক' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('প্রয়োজনীয় ছবিসমূহ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildImagePicker('এনআইডি কার্ডের ছবি', _nidCardImage, (img) => _nidCardImage = img),
        const SizedBox(height: 12),
        _buildImagePicker('ফটো', _photo, (img) => _photo = img),
        const SizedBox(height: 12),
        _buildImagePicker('নমিনির এনআইডি ছবি', _nomineeNidCardImage, (img) => _nomineeNidCardImage = img),
      ],
    );
  }
}