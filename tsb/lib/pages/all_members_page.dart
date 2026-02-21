// lib/pages/all_members_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/member_model.dart';
import '../services/member_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AllMembersPage extends StatefulWidget {
  const AllMembersPage({super.key});

  @override
  State<AllMembersPage> createState() => _AllMembersPageState();
}

class _AllMembersPageState extends State<AllMembersPage> with SingleTickerProviderStateMixin {
  final MemberService _memberService = MemberService();
  final AuthService _authService = AuthService();
  List<MemberModel> _members = [];
  List<MemberModel> _filteredMembers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _filterStatus = 'সব';
  String? _currentUserRole;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadMembers();
    _loadUserRole();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    setState(() {
      _currentUserRole = 'ADMIN'; // Replace with actual role from auth service
    });
  }

  Future<void> _loadMembers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final members = await _memberService.getAllMembers();
      setState(() {
        _members = members;
        _filteredMembers = members;
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

  void _filterMembers() {
    setState(() {
      _filteredMembers = _members.where((member) {
        final matchesSearch = member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            member.phone.contains(_searchQuery) ||
            member.nidCardNumber.contains(_searchQuery);
        final matchesStatus = _filterStatus == 'সব' || _getEnglishStatus(_filterStatus) == member.status;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _showMemberDetails(MemberModel member) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        member.name,
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
                      _buildDetailSection('ব্যক্তিগত তথ্য', [
                        _buildDetailRow('নাম', member.name),
                        _buildDetailRow('ফোন', member.phone),
                        _buildDetailRow('জেলা', member.zila),
                        _buildDetailRow('গ্রাম', member.village),
                        _buildDetailRow('এনআইডি', member.nidCardNumber),
                        _buildDetailRow('যোগদান তারিখ', member.getFormattedJoinDate()),
                        _buildDetailRow('স্ট্যাটাস', _getBanglaStatus(member.status)),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('মনোনীত ব্যক্তির তথ্য', [
                        _buildDetailRow('নাম', member.nomineeName),
                        _buildDetailRow('ফোন', member.nomineePhone),
                        _buildDetailRow('এনআইডি', member.nomineeNidCardNumber),
                      ]),
                      const SizedBox(height: 16),
                      const Text('ছবি', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (member.photoPath != null) _buildImagePreview('প্রোফাইল ছবি', member.photoPath!),
                      if (member.nidCardImagePath != null) _buildImagePreview('এনআইডি কার্ড ছবি', member.nidCardImagePath!),
                      if (member.nomineeNidCardImagePath != null) _buildImagePreview('মনোনীত ব্যক্তির এনআইডি', member.nomineeNidCardImagePath!),
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
                          _showEditDialog(member);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('সম্পাদনা'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_currentUserRole == 'ADMIN')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleDelete(member);
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
            width: 100,
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

  Widget _buildImagePreview(String title, String imagePath) {
    final imageUrl = _memberService.getImageUrl(imagePath);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        
        FutureBuilder<bool>(
          future: _memberService.testImageUrl(imagePath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            
            final isAccessible = snapshot.data ?? false;
            
            if (!isAccessible) {
              return Column(
                children: [
                  Container(
                    height: 150,
                    color: Colors.orange.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber, size: 40, color: Colors.orange),
                        const SizedBox(height: 8),
                        const Text(
                          'ছবি অ্যাক্সেস করা যাচ্ছে না',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'URL: ${imageUrl.length > 50 ? '${imageUrl.substring(0, 50)}...' : imageUrl}',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ডিবাগ তথ্যের জন্য কনসোল চেক করুন',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              );
            }
            
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Image load error for $imageUrl: $error');
                  return Container(
                    height: 150,
                    color: Colors.red.shade100,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 40, color: Colors.red),
                          SizedBox(height: 8),
                          Text('ছবি লোড করতে ব্যর্থ'),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 8),
                          Text(
                            'লোড হচ্ছে... ${((loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)) * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showEditDialog(MemberModel member) {
    final nameController = TextEditingController(text: member.name);
    final phoneController = TextEditingController(text: member.phone);
    final zilaController = TextEditingController(text: member.zila);
    final villageController = TextEditingController(text: member.village);
    final nidController = TextEditingController(text: member.nidCardNumber);
    final nomineeNameController = TextEditingController(text: member.nomineeName);
    final nomineePhoneController = TextEditingController(text: member.nomineePhone);
    final nomineeNidController = TextEditingController(text: member.nomineeNidCardNumber);
    String selectedStatus = _getBanglaStatus(member.status);

    XFile? newNidCardImage;
    XFile? newPhoto;
    XFile? newNomineeNidImage;

    bool nidImageChanged = false;
    bool photoChanged = false;
    bool nomineeNidImageChanged = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Text('সদস্য সম্পাদনা করুন', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
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
                      children: [
                        const Text('ব্যক্তিগত তথ্য', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'পুরো নাম',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'ফোন',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: zilaController,
                          decoration: const InputDecoration(
                            labelText: 'জেলা',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: villageController,
                          decoration: const InputDecoration(
                            labelText: 'গ্রাম',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nidController,
                          decoration: const InputDecoration(
                            labelText: 'এনআইডি নম্বর',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'স্ট্যাটাস',
                            border: OutlineInputBorder(),
                          ),
                          items: ['সক্রিয়', 'নিষ্ক্রিয়', 'স্থগিত'].map((status) {
                            return DropdownMenuItem(value: status, child: Text(status));
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedStatus = value!);
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        const Text('ছবি আপডেট করুন (ঐচ্ছিক)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        
                        _buildImageUploadSection(
                          context: context,
                          title: 'প্রোফাইল ছবি',
                          currentImagePath: member.photoPath,
                          isChanged: photoChanged,
                          onImageSelected: (XFile? image) {
                            setDialogState(() {
                              newPhoto = image;
                              photoChanged = image != null;
                            });
                          },
                          setDialogState: setDialogState,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildImageUploadSection(
                          context: context,
                          title: 'এনআইডি কার্ড ছবি',
                          currentImagePath: member.nidCardImagePath,
                          isChanged: nidImageChanged,
                          onImageSelected: (XFile? image) {
                            setDialogState(() {
                              newNidCardImage = image;
                              nidImageChanged = image != null;
                            });
                          },
                          setDialogState: setDialogState,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildImageUploadSection(
                          context: context,
                          title: 'মনোনীত ব্যক্তির এনআইডি ছবি',
                          currentImagePath: member.nomineeNidCardImagePath,
                          isChanged: nomineeNidImageChanged,
                          onImageSelected: (XFile? image) {
                            setDialogState(() {
                              newNomineeNidImage = image;
                              nomineeNidImageChanged = image != null;
                            });
                          },
                          setDialogState: setDialogState,
                        ),
                        
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        const Text('মনোনীত ব্যক্তির তথ্য', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nomineeNameController,
                          decoration: const InputDecoration(
                            labelText: 'মনোনীত ব্যক্তির নাম',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nomineePhoneController,
                          decoration: const InputDecoration(
                            labelText: 'মনোনীত ব্যক্তির ফোন',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nomineeNidController,
                          decoration: const InputDecoration(
                            labelText: 'মনোনীত ব্যক্তির এনআইডি',
                            border: OutlineInputBorder(),
                          ),
                        ),
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
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('বাতিল'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _updateMember(
                              member.id,
                              nameController.text,
                              phoneController.text,
                              zilaController.text,
                              villageController.text,
                              nidController.text,
                              nomineeNameController.text,
                              nomineePhoneController.text,
                              nomineeNidController.text,
                              selectedStatus,
                              newNidCardImage,
                              newPhoto,
                              newNomineeNidImage,
                            );
                          },
                          child: const Text('সদস্য আপডেট করুন'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection({
    required BuildContext context,
    required String title,
    required String? currentImagePath,
    required bool isChanged,
    required Function(XFile?) onImageSelected,
    required Function(void Function()) setDialogState,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        if (currentImagePath != null) ...[
          Text('বর্তমান ছবি:', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _memberService.getImageUrl(currentImagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('লোড করতে ব্যর্থ', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isChanged ? Colors.green.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isChanged ? Colors.green : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChanged ? 'নতুন ছবি নির্বাচিত হয়েছে' : 'নতুন ছবি নির্বাচন করুন',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isChanged ? Colors.green : Colors.grey.shade700,
                      ),
                    ),
                    if (!isChanged) ...[
                      const SizedBox(height: 4),
                      Text(
                        'বর্তমান ছবি রাখতে খালি রাখুন',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                    maxWidth: 1024,
                  );
                  
                  if (image != null) {
                    final file = File(image.path);
                    final fileSize = await file.length();
                    
                    if (!MemberService.validateImageSize(fileSize)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ছবির সাইজ ৫MB এর কম হতে হবে। বর্তমান সাইজ: ${MemberService.getFileSize(fileSize)}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }
                    
                    onImageSelected(image);
                  }
                },
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('নির্বাচন করুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChanged ? Colors.green : null,
                  foregroundColor: isChanged ? Colors.white : null,
                ),
              ),
              if (isChanged) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    setDialogState(() {
                      onImageSelected(null);
                    });
                  },
                  tooltip: 'সিলেকশন ক্লিয়ার করুন',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateMember(
    int id,
    String name,
    String phone,
    String zila,
    String village,
    String nid,
    String nomineeName,
    String nomineePhone,
    String nomineeNid,
    String status,
    XFile? nidImage,
    XFile? photo,
    XFile? nomineeNidImage,
  ) async {
    try {
      final member = _members.firstWhere((m) => m.id == id);
      final updatedMember = member.copyWith(
        name: name,
        phone: phone,
        zila: zila,
        village: village,
        nidCardNumber: nid,
        nomineeName: nomineeName,
        nomineePhone: nomineePhone,
        nomineeNidCardNumber: nomineeNid,
        status: _getEnglishStatus(status),
      );

      await _memberService.updateMemberWithImages(
        id: id,
        member: updatedMember,
        nidCardImage: nidImage != null
            ? await MemberService.createMultipartFile(
                'nidCardImage',
                await nidImage.readAsBytes(),
                nidImage.name,
              )
            : null,
        photo: photo != null
            ? await MemberService.createMultipartFile(
                'photo',
                await photo.readAsBytes(),
                photo.name,
              )
            : null,
        nomineeNidCardImage: nomineeNidImage != null
            ? await MemberService.createMultipartFile(
                'nomineeNidCardImage',
                await nomineeNidImage.readAsBytes(),
                nomineeNidImage.name,
              )
            : null,
      );

      _showSuccessSnackbar('সদস্য সফলভাবে আপডেট করা হয়েছে');
      _loadMembers();
    } catch (e) {
      _showErrorSnackbar('সদস্য আপডেট করতে ব্যর্থ: $e');
    }
  }

  void _handleDelete(MemberModel member) {
    if (member.status != 'INACTIVE') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('ডিলিট করা যাবে না'),
            ],
          ),
          content: Text(
            'সদস্য "${member.name}" ডিলিট করার আগে নিষ্ক্রিয় করতে হবে।\n\nবর্তমান স্ট্যাটাস: ${_getBanglaStatus(member.status)}\n\nদয়া করে সদস্য সম্পাদনা করে প্রথমে স্ট্যাটাস নিষ্ক্রিয় করুন।',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditDialog(member);
              },
              child: const Text('সদস্য সম্পাদনা'),
            ),
          ],
        ),
      );
      return;
    }

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
            const Text('আপনি কি এই সদস্যকে স্থায়ীভাবে ডিলিট করতে চান?'),
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
                  Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('ফোন: ${member.phone}'),
                  Text('এনআইডি: ${member.nidCardNumber}'),
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
              await _deleteMember(member.id);
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

  Future<void> _deleteMember(int id) async {
    try {
      await _memberService.deleteMember(id);
      _showSuccessSnackbar('সদস্য সফলভাবে ডিলিট করা হয়েছে');
      _loadMembers();
    } catch (e) {
      _showErrorSnackbar('সদস্য ডিলিট করতে ব্যর্থ: $e');
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.grey;
      case 'SUSPENDED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getBanglaStatus(String englishStatus) {
    switch (englishStatus) {
      case 'ACTIVE':
        return 'সক্রিয়';
      case 'INACTIVE':
        return 'নিষ্ক্রিয়';
      case 'SUSPENDED':
        return 'স্থগিত';
      default:
        return englishStatus;
    }
  }

  String _getEnglishStatus(String banglaStatus) {
    switch (banglaStatus) {
      case 'সক্রিয়':
        return 'ACTIVE';
      case 'নিষ্ক্রিয়':
        return 'INACTIVE';
      case 'স্থগিত':
        return 'SUSPENDED';
      case 'সব':
        return 'ALL';
      default:
        return banglaStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
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
              TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _filterMembers();
                },
                decoration: InputDecoration(
                  hintText: 'নাম, ফোন, বা এনআইডি দিয়ে খুঁজুন...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _filterStatus,
                      decoration: InputDecoration(
                        labelText: 'স্ট্যাটাস',
                        prefixIcon: const Icon(Icons.filter_list),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['সব', 'সক্রিয়', 'নিষ্ক্রিয়', 'স্থগিত'].map((status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _filterStatus = value!);
                        _filterMembers();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadMembers,
                    tooltip: 'রিফ্রেশ',
                  ),
                ],
              ),
            ],
          ),
        ),
        // Members Count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'মোট সদস্য: ${_filteredMembers.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        // Members List
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
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('ত্রুটি: $_errorMessage'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadMembers,
                            child: const Text('আবার চেষ্টা করুন'),
                          ),
                        ],
                      ),
                    )
                  : _filteredMembers.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('কোন সদস্য পাওয়া যায়নি', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        )
                      : FadeTransition(
                          opacity: _animationController,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 600) {
                                return _buildMobileView();
                              } else {
                                return _buildDesktopView();
                              }
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildMobileView() {
    return ListView.builder(
      itemCount: _filteredMembers.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final member = _filteredMembers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(member.status).withOpacity(0.2),
              child: Text(
                member.name[0].toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(member.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.phone),
                Text('${member.zila}, ${member.village}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(member.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getBanglaStatus(member.status),
                style: TextStyle(
                  color: _getStatusColor(member.status),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => _showMemberDetails(member),
          ),
        );
      },
    );
  }

  Widget _buildDesktopView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('আইডি', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('নাম', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ফোন', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ঠিকানা', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('এনআইডি', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('যোগদান তারিখ', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('স্ট্যাটাস', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('কর্ম', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _filteredMembers.map((member) {
            return DataRow(
              cells: [
                DataCell(Text('#${member.id}')),
                DataCell(
                  Text(member.name),
                  onTap: () => _showMemberDetails(member),
                ),
                DataCell(Text(member.phone)),
                DataCell(Text('${member.zila}, ${member.village}')),
                DataCell(Text(member.nidCardNumber)),
                DataCell(Text(member.getFormattedJoinDate())),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(member.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getBanglaStatus(member.status),
                      style: TextStyle(
                        color: _getStatusColor(member.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 18),
                        onPressed: () => _showMemberDetails(member),
                        tooltip: 'দেখুন',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                        onPressed: () => _showEditDialog(member),
                        tooltip: 'সম্পাদনা',
                      ),
                      if (_currentUserRole == 'ADMIN')
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: member.status == 'INACTIVE' ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                          onPressed: () => _handleDelete(member),
                          tooltip: member.status == 'INACTIVE' ? 'ডিলিট' : 'প্রথমে নিষ্ক্রিয় করুন',
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}