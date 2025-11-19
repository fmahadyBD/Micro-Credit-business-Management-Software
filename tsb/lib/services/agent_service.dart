// lib/services/agent_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/agent_model.dart';
import 'auth_service.dart';

class AgentService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/agents';
  final AuthService _authService = AuthService();

  /// Get authorization headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all agents
  Future<List<AgentModel>> getAllAgents() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AgentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load agents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching agents: $e');
    }
  }

  /// Get agent by ID
  Future<AgentModel> getAgentById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return AgentModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load agent: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching agent: $e');
    }
  }

  /// Create new agent
  // Future<AgentModel> createAgent(AgentModel agent) async {
  //   try {
  //     final headers = await _getHeaders();
  //     final response = await http.post(
  //       Uri.parse(baseUrl),
  //       headers: headers,
  //       body: jsonEncode(agent.toJson()),
  //     );

  //     if (response.statusCode == 200) {
  //       return AgentModel.fromJson(jsonDecode(response.body));
  //     } else {
  //       final error = jsonDecode(response.body);
  //       throw Exception(error['message'] ?? 'Failed to create agent: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error creating agent: $e');
  //   }
  // }


// lib/services/agent_service.dart
/// Create new agent
Future<AgentModel> createAgent(AgentModel agent) async {
  try {
    final headers = await _getHeaders();
    
    // Prepare the request body according to your backend expectations
    final requestBody = {
      'name': agent.name,
      'phone': agent.phone,
      'email': agent.email,
      'zila': agent.zila,
      'village': agent.village,
      'nidCard': agent.nidCard,
      'nominee': agent.nominee,
      'role': agent.role,
      'status': agent.status,
      // Note: joinDate is set by backend, so we don't send it
      // Note: photo is handled separately in with-photo endpoint
    };

    print('Creating agent with data: $requestBody');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    print('Create agent response status: ${response.statusCode}');
    print('Create agent response body: ${response.body}');

    if (response.statusCode == 200) {
      // Handle empty response
      if (response.body.isEmpty) {
        throw Exception('Server returned empty response');
      }

      try {
        final responseData = jsonDecode(response.body);
        
        // Check if response contains success: false
        if (responseData is Map<String, dynamic> && 
            responseData.containsKey('success') && 
            responseData['success'] == false) {
          throw Exception(responseData['message'] ?? 'Failed to create agent');
        }

        return AgentModel.fromJson(responseData);
      } catch (e) {
        print('JSON parsing error: $e');
        throw Exception('Failed to parse server response: $e');
      }
    } else {
      // Handle non-200 responses
      final errorMessage = _parseErrorResponse(response);
      throw Exception(errorMessage);
    }
  } catch (e) {
    print('Create agent error: $e');
    throw Exception('Error creating agent: $e');
  }
}

/// Helper method to parse error responses
String _parseErrorResponse(http.Response response) {
  try {
    if (response.body.isNotEmpty) {
      final errorData = jsonDecode(response.body);
      if (errorData is Map<String, dynamic>) {
        return errorData['message'] ?? 
               errorData['error'] ?? 
               'Failed to create agent: ${response.statusCode}';
      }
    }
  } catch (e) {
    // If we can't parse the error response, fall back to status code
  }
  
  return 'Failed to create agent: ${response.statusCode}';
}
  /// Update agent
  Future<AgentModel> updateAgent(AgentModel agent) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/${agent.id}'),
        headers: headers,
        body: jsonEncode(agent.toJson()),
      );

      if (response.statusCode == 200) {
        return AgentModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update agent: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating agent: $e');
    }
  }

  /// Delete agent
  Future<void> deleteAgent(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] != true) {
          throw Exception(result['message'] ?? 'Failed to delete agent');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete agent: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting agent: $e');
    }
  }

  /// Update agent status
  Future<AgentModel> updateAgentStatus(int id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$id/status?status=$status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return AgentModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }

  /// Get agents by status
  Future<List<AgentModel>> getAgentsByStatus(String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/status/$status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AgentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load agents by status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching agents by status: $e');
    }
  }
}