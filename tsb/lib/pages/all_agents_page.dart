// lib/pages/all_agents_page.dart
import 'package:flutter/material.dart';
import '../services/agent_service.dart';
import '../models/agent_model.dart';
import 'agent_details_page.dart';

class AllAgentsPage extends StatefulWidget {
  const AllAgentsPage({super.key});

  @override
  State<AllAgentsPage> createState() => _AllAgentsPageState();
}

class _AllAgentsPageState extends State<AllAgentsPage> with SingleTickerProviderStateMixin {
  final AgentService _agentService = AgentService();
  List<AgentModel> _agents = [];
  List<AgentModel> _filteredAgents = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterRole = 'ALL';
  String _filterStatus = 'ALL';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadAgents();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    setState(() => _isLoading = true);
    try {
      final agents = await _agentService.getAllAgents();
      setState(() {
        _agents = agents;
        _filteredAgents = agents;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackbar('এজেন্ট লোড করতে ব্যর্থ: $e');
      }
    }
  }

  void _filterAgents() {
    setState(() {
      _filteredAgents = _agents.where((agent) {
        final matchesSearch = agent.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            agent.phone.contains(_searchQuery) ||
            agent.email.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesRole = _filterRole == 'ALL' || agent.role == _filterRole;
        final matchesStatus = _filterStatus == 'ALL' || agent.status == _filterStatus;
        return matchesSearch && matchesRole && matchesStatus;
      }).toList();
    });
  }

  void _showAddAgentDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final zilaController = TextEditingController();
    final villageController = TextEditingController();
    final nidCardController = TextEditingController();
    final nomineeController = TextEditingController();
    String selectedRole = 'AGENT';
    String selectedStatus = 'ACTIVE';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_add, color: Colors.green),
              ),
              const SizedBox(width: 12),
              const Text('নতুন এজেন্ট যোগ করুন'),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'পুরো নাম *',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'ফোন নম্বর *',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'ইমেইল',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: zilaController,
                    decoration: InputDecoration(
                      labelText: 'জেলা *',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: villageController,
                    decoration: InputDecoration(
                      labelText: 'গ্রাম *',
                      prefixIcon: const Icon(Icons.home_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nidCardController,
                    decoration: InputDecoration(
                      labelText: 'এনআইডি নম্বর *',
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nomineeController,
                    decoration: InputDecoration(
                      labelText: 'মনোনীত ব্যক্তি',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'ভূমিকা',
                      prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['এজেন্ট', 'অ্যাডমিন'].map((role) {
                      return DropdownMenuItem(value: role == 'এজেন্ট' ? 'AGENT' : 'ADMIN', child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedRole = value!);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'স্ট্যাটাস',
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['সক্রিয়', 'নিষ্ক্রিয়', 'স্থগিত'].map((status) {
                      String value = '';
                      switch (status) {
                        case 'সক্রিয়': value = 'ACTIVE'; break;
                        case 'নিষ্ক্রিয়': value = 'INACTIVE'; break;
                        case 'স্থগিত': value = 'SUSPENDED'; break;
                      }
                      return DropdownMenuItem(value: value, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedStatus = value!);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || 
                    phoneController.text.isEmpty || 
                    zilaController.text.isEmpty || 
                    villageController.text.isEmpty || 
                    nidCardController.text.isEmpty) {
                  _showErrorSnackbar('দয়া করে সকল প্রয়োজনীয় ফিল্ড পূরণ করুন (*)');
                  return;
                }

                Navigator.pop(context);
                await _createAgent(
                  nameController.text,
                  phoneController.text,
                  emailController.text,
                  zilaController.text,
                  villageController.text,
                  nidCardController.text,
                  nomineeController.text,
                  selectedRole,
                  selectedStatus,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('এজেন্ট তৈরি করুন'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(AgentModel agent) {
    final nameController = TextEditingController(text: agent.name);
    final phoneController = TextEditingController(text: agent.phone);
    final emailController = TextEditingController(text: agent.email);
    final zilaController = TextEditingController(text: agent.zila);
    final villageController = TextEditingController(text: agent.village);
    final nidCardController = TextEditingController(text: agent.nidCard);
    final nomineeController = TextEditingController(text: agent.nominee ?? '');
    String selectedRole = agent.role;
    String selectedStatus = agent.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              const Text('এজেন্ট সম্পাদনা করুন'),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'পুরো নাম *',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'ফোন নম্বর *',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'ইমেইল',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: zilaController,
                    decoration: InputDecoration(
                      labelText: 'জেলা *',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: villageController,
                    decoration: InputDecoration(
                      labelText: 'গ্রাম *',
                      prefixIcon: const Icon(Icons.home_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nidCardController,
                    decoration: InputDecoration(
                      labelText: 'এনআইডি নম্বর *',
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nomineeController,
                    decoration: InputDecoration(
                      labelText: 'মনোনীত ব্যক্তি',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'ভূমিকা',
                      prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['এজেন্ট', 'অ্যাডমিন'].map((role) {
                      return DropdownMenuItem(value: role == 'এজেন্ট' ? 'AGENT' : 'ADMIN', child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedRole = value!);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'স্ট্যাটাস',
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['সক্রিয়', 'নিষ্ক্রিয়', 'স্থগিত'].map((status) {
                      String value = '';
                      switch (status) {
                        case 'সক্রিয়': value = 'ACTIVE'; break;
                        case 'নিষ্ক্রিয়': value = 'INACTIVE'; break;
                        case 'স্থগিত': value = 'SUSPENDED'; break;
                      }
                      return DropdownMenuItem(value: value, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedStatus = value!);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || 
                    phoneController.text.isEmpty || 
                    zilaController.text.isEmpty || 
                    villageController.text.isEmpty || 
                    nidCardController.text.isEmpty) {
                  _showErrorSnackbar('দয়া করে সকল প্রয়োজনীয় ফিল্ড পূরণ করুন (*)');
                  return;
                }

                Navigator.pop(context);
                await _updateAgent(
                  agent,
                  nameController.text,
                  phoneController.text,
                  emailController.text,
                  zilaController.text,
                  villageController.text,
                  nidCardController.text,
                  nomineeController.text,
                  selectedRole,
                  selectedStatus,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('আপডেট করুন'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(AgentModel agent) {
    if (agent.status != 'INACTIVE') {
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
            'এজেন্ট "${agent.name}" ডিলিট করার আগে নিষ্ক্রিয় করতে হবে।\n\nবর্তমান স্ট্যাটাস: ${_getBanglaStatus(agent.status)}',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ঠিক আছে'),
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
            const Text(
              'আপনি কি এই এজেন্টকে স্থায়ীভাবে ডিলিট করতে চান?',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('ফোন: ${agent.phone}'),
                  if (agent.email.isNotEmpty) Text('ইমেইল: ${agent.email}'),
                  Text('জেলা: ${agent.zila}'),
                  Text('গ্রাম: ${agent.village}'),
                  Text('ভূমিকা: ${_getBanglaRole(agent.role)}'),
                  Text('স্ট্যাটাস: ${_getBanglaStatus(agent.status)}'),
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
              await _deleteAgent(agent.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ডিলিট'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAgent(
    String name,
    String phone,
    String email,
    String zila,
    String village,
    String nidCard,
    String nominee,
    String role,
    String status,
  ) async {
    try {
      final newAgent = AgentModel(
        id: 0,
        name: name,
        phone: phone,
        email: email,
        zila: zila,
        village: village,
        nidCard: nidCard,
        nominee: nominee.isNotEmpty ? nominee : null,
        role: role,
        status: status,
        joinDate: DateTime.now(),
      );

      await _agentService.createAgent(newAgent);
      _showSuccessSnackbar('এজেন্ট সফলভাবে তৈরি করা হয়েছে');
      _loadAgents();
    } catch (e) {
      _showErrorSnackbar('এজেন্ট তৈরি করতে ব্যর্থ: $e');
    }
  }

  Future<void> _updateAgent(
    AgentModel agent,
    String name,
    String phone,
    String email,
    String zila,
    String village,
    String nidCard,
    String nominee,
    String role,
    String status,
  ) async {
    try {
      final updatedAgent = AgentModel(
        id: agent.id,
        name: name,
        phone: phone,
        email: email,
        zila: zila,
        village: village,
        nidCard: nidCard,
        nominee: nominee.isNotEmpty ? nominee : null,
        role: role,
        status: status,
        joinDate: agent.joinDate,
        photo: agent.photo,
      );

      await _agentService.updateAgent(updatedAgent);
      _showSuccessSnackbar('এজেন্ট সফলভাবে আপডেট করা হয়েছে');
      _loadAgents();
    } catch (e) {
      _showErrorSnackbar('এজেন্ট আপডেট করতে ব্যর্থ: $e');
    }
  }

  Future<void> _deleteAgent(int id) async {
    try {
      await _agentService.deleteAgent(id);
      _showSuccessSnackbar('এজেন্ট সফলভাবে ডিলিট করা হয়েছে');
      _loadAgents();
    } catch (e) {
      _showErrorSnackbar('এজেন্ট ডিলিট করতে ব্যর্থ: $e');
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
        margin: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.all(16),
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
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.purple;
      case 'AGENT':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getBanglaStatus(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'সক্রিয়';
      case 'INACTIVE':
        return 'নিষ্ক্রিয়';
      case 'SUSPENDED':
        return 'স্থগিত';
      default:
        return status;
    }
  }

  String _getBanglaRole(String role) {
    switch (role) {
      case 'ADMIN':
        return 'অ্যাডমিন';
      case 'AGENT':
        return 'এজেন্ট';
      default:
        return role;
    }
  }

  Widget _buildMobileCard(AgentModel agent) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewAgentDetails(agent),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      agent.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(agent.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getBanglaStatus(agent.status),
                      style: TextStyle(
                        color: _getStatusColor(agent.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('ফোন: ${agent.phone}'),
              if (agent.email.isNotEmpty) Text('ইমেইল: ${agent.email}'),
              Text('জেলা: ${agent.zila}'),
              Text('গ্রাম: ${agent.village}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(agent.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getBanglaRole(agent.role),
                      style: TextStyle(
                        color: _getRoleColor(agent.role),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.green, size: 20),
                        onPressed: () => _viewAgentDetails(agent),
                        tooltip: 'বিস্তারিত দেখুন',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        onPressed: () => _showEditDialog(agent),
                        tooltip: 'সম্পাদনা',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _showDeleteDialog(agent),
                        tooltip: 'ডিলিট',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTable() {
    return FadeTransition(
      opacity: _animationController,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
            columns: const [
              DataColumn(label: Text('আইডি', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('নাম', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ফোন', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('স্ট্যাটাস', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('কর্ম', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _filteredAgents.map((agent) {
              return DataRow(
                cells: [
                  DataCell(Text('#${agent.id}')),
                  DataCell(
                    InkWell(
                      onTap: () => _viewAgentDetails(agent),
                      child: Text(
                        agent.name,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(agent.phone)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(agent.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getBanglaStatus(agent.status),
                        style: TextStyle(
                          color: _getStatusColor(agent.status),
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
                          icon: const Icon(Icons.visibility, color: Colors.green, size: 20),
                          onPressed: () => _viewAgentDetails(agent),
                          tooltip: 'বিস্তারিত দেখুন',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          onPressed: () => _showEditDialog(agent),
                          tooltip: 'সম্পাদনা',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _showDeleteDialog(agent),
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAgentDialog,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          // Filter Section
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
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _filterAgents();
                  },
                  decoration: InputDecoration(
                    hintText: 'নাম, ফোন বা ইমেইল দিয়ে খুঁজুন...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 12),
                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _filterRole,
                        decoration: InputDecoration(
                          labelText: 'ভূমিকা',
                          prefixIcon: const Icon(Icons.filter_list),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['সব', 'অ্যাডমিন', 'এজেন্ট'].map((role) {
                          String value = '';
                          switch (role) {
                            case 'সব': value = 'ALL'; break;
                            case 'অ্যাডমিন': value = 'ADMIN'; break;
                            case 'এজেন্ট': value = 'AGENT'; break;
                          }
                          return DropdownMenuItem(value: value, child: Text(role));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _filterRole = value!);
                          _filterAgents();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _filterStatus,
                        decoration: InputDecoration(
                          labelText: 'স্ট্যাটাস',
                          prefixIcon: const Icon(Icons.info_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['সব', 'সক্রিয়', 'নিষ্ক্রিয়', 'স্থগিত'].map((status) {
                          String value = '';
                          switch (status) {
                            case 'সব': value = 'ALL'; break;
                            case 'সক্রিয়': value = 'ACTIVE'; break;
                            case 'নিষ্ক্রিয়': value = 'INACTIVE'; break;
                            case 'স্থগিত': value = 'SUSPENDED'; break;
                          }
                          return DropdownMenuItem(value: value, child: Text(status));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _filterStatus = value!);
                          _filterAgents();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Agents Count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'মোট এজেন্ট: ${_filteredAgents.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadAgents,
                  tooltip: 'রিফ্রেশ',
                ),
              ],
            ),
          ),

          // Data Table/Cards
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
                : _filteredAgents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'কোন এজেন্ট পাওয়া যায়নি',
                              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'নতুন এজেন্ট যোগ করতে + বাটনে ট্যাপ করুন',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : isMobile
                        ? ListView.builder(
                            itemCount: _filteredAgents.length,
                            itemBuilder: (context, index) {
                              return _buildMobileCard(_filteredAgents[index]);
                            },
                          )
                        : _buildDesktopTable(),
          ),
        ],
      ),
    );
  }

  void _viewAgentDetails(AgentModel agent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentDetailsPage(agentId: agent.id),
      ),
    );
  }
}