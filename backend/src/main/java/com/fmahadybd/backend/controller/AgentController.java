package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.entity.Agent;
import com.fmahadybd.backend.entity.DeletedAgent;
import com.fmahadybd.backend.service.AgentService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/agents")
@Tag(name = "agents")
@RequiredArgsConstructor
public class AgentController {

    private final AgentService agentService;

    /** Create a new Agent with validation */
    @PostMapping
    @Operation(summary = "Create a new agent")
    public ResponseEntity<?> createAgent(@Valid @RequestBody Agent agent, BindingResult result) {
        if (result.hasErrors()) {
            String errorMessage = result.getAllErrors().get(0).getDefaultMessage();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", errorMessage);
            return ResponseEntity.badRequest().body(errorResponse);
        }

        Agent savedAgent = agentService.createAgent(agent);
        return ResponseEntity.ok(savedAgent);
    }

    /** Get all Agents */
    @GetMapping
    @Operation(summary = "Get all agents")
    public ResponseEntity<List<Agent>> getAllAgents() {
        return ResponseEntity.ok(agentService.getAllAgents());
    }

    /** Get Agent by ID (throws if not found) */
    @GetMapping("/{id}")
    @Operation(summary = "Get agent by ID")
    public ResponseEntity<?> getAgentById(@PathVariable Long id) {
        try {
            Agent agent = agentService.getAgentById(id)
                    .orElseThrow(() -> new RuntimeException("Agent not found with ID: " + id));
            return ResponseEntity.ok(agent);
        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(404).body(errorResponse);
        }
    }

    /** Update existing Agent with validation */
    @PutMapping("/{id}")
    @Operation(summary = "Update existing agent")
    public ResponseEntity<?> updateAgent(@PathVariable Long id, @Valid @RequestBody Agent updatedAgent,
            BindingResult result) {
        if (result.hasErrors()) {
            String errorMessage = result.getAllErrors().get(0).getDefaultMessage();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", errorMessage);
            return ResponseEntity.badRequest().body(errorResponse);
        }

        try {
            Agent existingAgent = agentService.getAgentById(id)
                    .orElseThrow(() -> new RuntimeException("Agent not found with ID: " + id));

            existingAgent.setName(updatedAgent.getName());
            existingAgent.setPhone(updatedAgent.getPhone());
            existingAgent.setEmail(updatedAgent.getEmail());
            existingAgent.setZila(updatedAgent.getZila());
            existingAgent.setVillage(updatedAgent.getVillage());
            existingAgent.setNidCard(updatedAgent.getNidCard());
            existingAgent.setPhoto(updatedAgent.getPhoto());
            existingAgent.setNominee(updatedAgent.getNominee());
            existingAgent.setStatus(updatedAgent.getStatus());
            existingAgent.setRole(updatedAgent.getRole());

            Agent savedAgent = agentService.createAgent(existingAgent);
            return ResponseEntity.ok(savedAgent);

        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(404).body(errorResponse);
        }
    }

    /** Delete Agent by ID */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete agent by ID")
    public ResponseEntity<Map<String, Object>> deleteAgent(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        try {
            boolean deleted = agentService.deleteAgent(id);
            if (deleted) {
                response.put("success", true);
                response.put("message", "Agent deleted successfully");
                response.put("id", id);
                return ResponseEntity.ok(response);
            } else {
                throw new RuntimeException("Agent not found with ID: " + id);
            }
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(404).body(response);
        }
    }

    /** Get Agents by Status */
    @GetMapping("/status/{status}")
    @Operation(summary = "Get agents by status")
    public ResponseEntity<List<Agent>> getAgentsByStatus(@PathVariable String status) {
        return ResponseEntity.ok(agentService.getAgentsByStatus(status));
    }

    /** Update only Agent status */
    @PutMapping("/{id}/status")
    @Operation(summary = "Update agent status")
    public ResponseEntity<?> updateAgentStatus(@PathVariable Long id, @RequestParam String status) {
        try {
            Agent updatedAgent = agentService.updateAgentStatus(id, status);
            if (updatedAgent != null) {
                return ResponseEntity.ok(updatedAgent);
            } else {
                throw new RuntimeException("Agent not found with ID: " + id);
            }
        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(404).body(errorResponse);
        }
    }

    /** Get all deleted agents (deletion history) */
    @GetMapping("/deleted")
    @Operation(summary = "Get all deleted agents (deletion history)")
    public ResponseEntity<List<DeletedAgent>> getDeletedAgents() {
        List<DeletedAgent> deletedAgents = agentService.getAllDeletedAgents();
        if (deletedAgents.isEmpty()) {
            return ResponseEntity.ok().body(List.of());
        }
        return ResponseEntity.ok(deletedAgents);
    }

}
