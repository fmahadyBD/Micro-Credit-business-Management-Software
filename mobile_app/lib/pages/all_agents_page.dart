// lib/pages/all_agents_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/services/agent_service.dart';
import 'package:mobile_app/models/agent_model.dart';
import 'package:mobile_app/pages/agent_details_page.dart';

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
        _showErrorSnackbar('Failed to load agents: $e');
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
              const Text('Add New Agent'),
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
                      labelText: 'Full Name *',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: zilaController,
                    decoration: InputDecoration(
                      labelText: 'Zila/District *',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: villageController,
                    decoration: InputDecoration(
                      labelText: 'Village *',
                      prefixIcon: const Icon(Icons.home_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nidCardController,
                    decoration: InputDecoration(
                      labelText: 'NID Card Number *',
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nomineeController,
                    decoration: InputDecoration(
                      labelText: 'Nominee',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['AGENT', 'ADMIN'].map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedRole = value!);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['ACTIVE', 'INACTIVE', 'SUSPENDED'].map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || 
                    phoneController.text.isEmpty || 
                    zilaController.text.isEmpty || 
                    villageController.text.isEmpty || 
                    nidCardController.text.isEmpty) {
                  _showErrorSnackbar('Please fill all required fields (*)');
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
              child: const Text('Create Agent'),
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
              const Text('Edit Agent'),
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
                      labelText: 'Full Name *',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: zilaController,
                    decoration: InputDecoration(
                      labelText: 'Zila/District *',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: villageController,
                    decoration: InputDecoration(
                      labelText: 'Village *',
                      prefixIcon: const Icon(Icons.home_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nidCardController,
                    decoration: InputDecoration(
                      labelText: 'NID Card Number *',
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nomineeController,
                    decoration: InputDecoration(
                      labelText: 'Nominee',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['AGENT', 'ADMIN'].map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedRole = value!);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['ACTIVE', 'INACTIVE', 'SUSPENDED'].map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || 
                    phoneController.text.isEmpty || 
                    zilaController.text.isEmpty || 
                    villageController.text.isEmpty || 
                    nidCardController.text.isEmpty) {
                  _showErrorSnackbar('Please fill all required fields (*)');
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
              child: const Text('Update'),
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
              Text('Cannot Delete'),
            ],
          ),
          content: Text(
            'Agent "${agent.name}" must be INACTIVE before deletion.\n\nCurrent status: ${agent.status}',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
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
            Text('Confirm Deletion'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to permanently delete this agent?',
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
                  Text('Phone: ${agent.phone}'),
                  if (agent.email.isNotEmpty) Text('Email: ${agent.email}'),
                  Text('Zila: ${agent.zila}'),
                  Text('Village: ${agent.village}'),
                  Text('Role: ${agent.role}'),
                  Text('Status: ${agent.status}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '⚠️ This action cannot be undone!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Delete'),
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
      _showSuccessSnackbar('Agent created successfully');
      _loadAgents();
    } catch (e) {
      _showErrorSnackbar('Failed to create agent: $e');
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
      _showSuccessSnackbar('Agent updated successfully');
      _loadAgents();
    } catch (e) {
      _showErrorSnackbar('Failed to update agent: $e');
    }
  }

  Future<void> _deleteAgent(int id) async {
    try {
      await _agentService.deleteAgent(id);
      _showSuccessSnackbar('Agent deleted successfully');
      _loadAgents();
    } catch (e) {
      _showErrorSnackbar('Failed to delete agent: $e');
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



  // Widget _buildMobileCard(AgentModel agent) {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Expanded(
  //                 child: Text(
  //                   agent.name,
  //                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                 decoration: BoxDecoration(
  //                   color: _getStatusColor(agent.status).withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Text(
  //                   agent.status,
  //                   style: TextStyle(
  //                     color: _getStatusColor(agent.status),
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 8),
  //           Text('Phone: ${agent.phone}'),
  //           if (agent.email.isNotEmpty) Text('Email: ${agent.email}'),
  //           Text('Zila: ${agent.zila}'),
  //           Text('Village: ${agent.village}'),
  //           const SizedBox(height: 8),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                 decoration: BoxDecoration(
  //                   color: _getRoleColor(agent.role).withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Text(
  //                   agent.role,
  //                   style: TextStyle(
  //                     color: _getRoleColor(agent.role),
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ),
  //               Row(
  //                 children: [
  //                   IconButton(
  //                     icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
  //                     onPressed: () => _showEditDialog(agent),
  //                     tooltip: 'Edit',
  //                   ),
  //                   IconButton(
  //                     icon: const Icon(Icons.delete, color: Colors.red, size: 20),
  //                     onPressed: () => _showDeleteDialog(agent),
  //                     tooltip: 'Delete',
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



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
                    agent.status,
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
            Text('Phone: ${agent.phone}'),
            if (agent.email.isNotEmpty) Text('Email: ${agent.email}'),
            Text('Zila: ${agent.zila}'),
            Text('Village: ${agent.village}'),
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
                    agent.role,
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
                      tooltip: 'View Details',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () => _showEditDialog(agent),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _showDeleteDialog(agent),
                      tooltip: 'Delete',
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


  // Widget _buildDesktopTable() {
  //   return FadeTransition(
  //     opacity: _animationController,
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: SingleChildScrollView(
  //         child: DataTable(
  //           headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
  //           columns: const [
  //             DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
  //             DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
  //             DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
  //             DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
  //             DataColumn(label: Text('Zila', style: TextStyle(fontWeight: FontWeight.bold))),
  //             DataColumn(label: Text('Village', style: TextStyle(fontWeight: FontWeight.bold))),
  //             DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
  //             DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
  //             DataColumn(label: Text('Join Date', style: TextStyle(fontWeight: FontWeight.bold))),
  //             DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
  //           ],
  //           rows: _filteredAgents.map((agent) {
  //             return DataRow(
  //               cells: [
  //                 DataCell(Text('#${agent.id}')),
  //                 DataCell(Text(agent.name)),
  //                 DataCell(Text(agent.phone)),
  //                 DataCell(Text(agent.email)),
  //                 DataCell(Text(agent.zila)),
  //                 DataCell(Text(agent.village)),
  //                 DataCell(
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       color: _getRoleColor(agent.role).withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: Text(
  //                       agent.role,
  //                       style: TextStyle(
  //                         color: _getRoleColor(agent.role),
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 DataCell(
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       color: _getStatusColor(agent.status).withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: Text(
  //                       agent.status,
  //                       style: TextStyle(
  //                         color: _getStatusColor(agent.status),
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 DataCell(Text(agent.joinDate.toString().split(' ')[0])),
  //                 DataCell(
  //                   Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       IconButton(
  //                         icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
  //                         onPressed: () => _showEditDialog(agent),
  //                         tooltip: 'Edit',
  //                       ),
  //                       IconButton(
  //                         icon: const Icon(Icons.delete, color: Colors.red, size: 20),
  //                         onPressed: () => _showDeleteDialog(agent),
  //                         tooltip: 'Delete',
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             );
  //           }).toList(),
  //         ),
  //       ),
  //     ),
  //   );
  // }



Widget _buildDesktopTable() {
  return FadeTransition(
    opacity: _animationController,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
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
                      agent.status,
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
                        tooltip: 'View Details',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        onPressed: () => _showEditDialog(agent),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _showDeleteDialog(agent),
                        tooltip: 'Delete',
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
                    hintText: 'Search by name, phone or email...',
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
                        value: _filterRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          prefixIcon: const Icon(Icons.filter_list),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['ALL', 'ADMIN', 'AGENT'].map((role) {
                          return DropdownMenuItem(value: role, child: Text(role));
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
                        value: _filterStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          prefixIcon: const Icon(Icons.info_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['ALL', 'ACTIVE', 'INACTIVE', 'SUSPENDED'].map((status) {
                          return DropdownMenuItem(value: status, child: Text(status));
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
                  'Total Agents: ${_filteredAgents.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadAgents,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // Data Table/Cards
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAgents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No agents found',
                              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add a new agent',
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