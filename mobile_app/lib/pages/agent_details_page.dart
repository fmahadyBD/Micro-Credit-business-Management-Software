// lib/pages/agent_details_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/agent_model.dart';
import 'package:mobile_app/services/agent_service.dart';

class AgentDetailsPage extends StatefulWidget {
  final int agentId;

  const AgentDetailsPage({super.key, required this.agentId});

  @override
  State<AgentDetailsPage> createState() => _AgentDetailsPageState();
}

class _AgentDetailsPageState extends State<AgentDetailsPage> {
  final AgentService _agentService = AgentService();
  AgentModel? _agent;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadAgentDetails();
  }

  Future<void> _loadAgentDetails() async {
    setState(() => _isLoading = true);
    try {
      final agent = await _agentService.getAgentById(widget.agentId);
      setState(() {
        _agent = agent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load agent details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleEditMode() {
    setState(() => _isEditing = !_isEditing);
  }

  void _saveChanges() {
    // Implement save functionality
    _toggleEditMode();
    _loadAgentDetails(); // Reload to show updated data
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Agent' : 'Agent Details'),
        actions: [
          if (!_isLoading && _agent != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: _isEditing ? 'Cancel' : 'Edit',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
              tooltip: 'Save',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _agent == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Agent not found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadAgentDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card with Basic Info
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Profile Icon and Name
                              Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _agent!.name,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'ID: #${_agent!.id}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getRoleColor(_agent!.role)
                                                    .withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: _getRoleColor(_agent!.role)
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                _agent!.role,
                                                style: TextStyle(
                                                  color: _getRoleColor(_agent!.role),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(_agent!.status)
                                                    .withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: _getStatusColor(_agent!.status)
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                _agent!.status,
                                                style: TextStyle(
                                                  color: _getStatusColor(_agent!.status),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              // Quick Stats Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem('Joined', _agent!.joinDate
                                      .toString()
                                      .split(' ')[0]),
                                  _buildStatItem('Phone', _agent!.phone),
                                  _buildStatItem('Email', _agent!.email.isNotEmpty 
                                      ? _agent!.email 
                                      : 'Not provided'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Personal Information Section
                      _buildSection(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        children: [
                          _buildDetailRow('Full Name', _agent!.name),
                          _buildDetailRow('Phone Number', _agent!.phone),
                          _buildDetailRow('Email', 
                              _agent!.email.isNotEmpty ? _agent!.email : 'Not provided'),
                          _buildDetailRow('NID Card', _agent!.nidCard),
                          if (_agent!.nominee != null && _agent!.nominee!.isNotEmpty)
                            _buildDetailRow('Nominee', _agent!.nominee!),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Address Information Section
                      _buildSection(
                        title: 'Address Information',
                        icon: Icons.location_on_outlined,
                        children: [
                          _buildDetailRow('Zila/District', _agent!.zila),
                          _buildDetailRow('Village', _agent!.village),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Account Information Section
                      _buildSection(
                        title: 'Account Information',
                        icon: Icons.admin_panel_settings_outlined,
                        children: [
                          _buildDetailRow('Role', _agent!.role),
                          _buildDetailRow('Status', _agent!.status),
                          _buildDetailRow('Join Date', 
                              _agent!.joinDate.toString().split(' ')[0]),
                          _buildDetailRow('Member ID', '#${_agent!.id}'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Photo Section (if available)
                      if (_agent!.photo != null && _agent!.photo!.isNotEmpty)
                        _buildSection(
                          title: 'Photo',
                          icon: Icons.photo_library_outlined,
                          children: [
                            Center(
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _agent!.photo!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}