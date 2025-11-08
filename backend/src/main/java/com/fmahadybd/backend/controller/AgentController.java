package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.entity.Agent;
import com.fmahadybd.backend.entity.DeletedAgent;
import com.fmahadybd.backend.service.AgentService;
import com.fmahadybd.backend.service.FileStorageService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/agents")
@Tag(name = "agents")
@RequiredArgsConstructor
public class AgentController {

    private final AgentService agentService;
    private final FileStorageService fileStorageService;
    private final String imagFolder = "agent";

    /** Create a new Agent with validation - ADMIN only */
    @PostMapping
    @Operation(summary = "Create a new agent")
    @PreAuthorize("hasRole('ADMIN')")
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

    /** Create Agent with Photo Upload - ADMIN only */
    @PostMapping(value = "/with-photo", consumes = "multipart/form-data")
    @Operation(summary = "Create agent with photo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createAgentWithPhoto(
            @RequestPart("agent") @Valid Agent agent,
            BindingResult result,
            @RequestPart(value = "photo", required = false) MultipartFile photo) {

        if (result.hasErrors()) {
            String errorMessage = result.getAllErrors().get(0).getDefaultMessage();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", errorMessage);
            return ResponseEntity.badRequest().body(errorResponse);
        }

        try {
            // Handle photo upload
            if (photo != null && !photo.isEmpty()) {
                Long agentId = agent.getId() != null ? agent.getId() : 0L;
                String photoPath = fileStorageService.saveFile(photo, agentId, imagFolder);
                agent.setPhoto(photoPath);
            }

            Agent savedAgent = agentService.createAgent(agent);
            return ResponseEntity.ok(savedAgent);

        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Error creating agent: " + e.getMessage());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /** Update Agent with Photo - ADMIN only */
    @PutMapping(value = "/{id}/with-photo", consumes = "multipart/form-data")
    @Operation(summary = "Update agent with photo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateAgentWithPhoto(
            @PathVariable Long id,
            @RequestPart("agent") @Valid Agent updatedAgent,
            BindingResult result,
            @RequestPart(value = "photo", required = false) MultipartFile photo) {

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

            // Handle photo upload
            if (photo != null && !photo.isEmpty()) {
                String photoPath = fileStorageService.saveFile(photo, id, imagFolder);
                updatedAgent.setPhoto(photoPath);
            } else {
                updatedAgent.setPhoto(existingAgent.getPhoto());
            }

            // Update fields
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

            Agent savedAgent = agentService.updateAgent(id, existingAgent);
            return ResponseEntity.ok(savedAgent);

        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(404).body(errorResponse);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Error updating agent: " + e.getMessage());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /** Upload/Update Agent Photo - ADMIN only */
    @PostMapping(value = "/{id}/photo", consumes = "multipart/form-data")
    @Operation(summary = "Upload agent photo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> uploadAgentPhoto(
            @PathVariable Long id,
            @RequestPart("photo") MultipartFile photo) {

        try {
            Agent existingAgent = agentService.getAgentById(id)
                    .orElseThrow(() -> new RuntimeException("Agent not found with ID: " + id));

            if (photo != null && !photo.isEmpty()) {
                String photoPath = fileStorageService.saveFile(photo, id, imagFolder);
                existingAgent.setPhoto(photoPath);
                Agent savedAgent = agentService.updateAgent(id, existingAgent);
                return ResponseEntity.ok(savedAgent);
            } else {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", "No photo file provided");
                return ResponseEntity.badRequest().body(errorResponse);
            }

        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(404).body(errorResponse);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Error uploading photo: " + e.getMessage());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /** Get all Agents - ADMIN and AGENT can access */
    @GetMapping
    @Operation(summary = "Get all agents")
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENT')")
    public ResponseEntity<List<Agent>> getAllAgents() {
        return ResponseEntity.ok(agentService.getAllAgents());
    }

    /** Get Agent by ID - ADMIN, AGENT, and SHAREHOLDER can access */
    @GetMapping("/{id}")
    @Operation(summary = "Get agent by ID")
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENT', 'SHAREHOLDER')")
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

    /** Update existing Agent - ADMIN only */
    @PutMapping("/{id}")
    @Operation(summary = "Update existing agent")
    @PreAuthorize("hasRole('ADMIN')")
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

            Agent savedAgent = agentService.updateAgent(id, existingAgent);
            return ResponseEntity.ok(savedAgent);

        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(404).body(errorResponse);
        }
    }

    /** Delete Agent by ID - ADMIN only */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete agent by ID")
    @PreAuthorize("hasRole('ADMIN')")
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

    /** Get Agents by Status - ADMIN and AGENT can access */
    @GetMapping("/status/{status}")
    @Operation(summary = "Get agents by status")
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENT')")
    public ResponseEntity<List<Agent>> getAgentsByStatus(@PathVariable String status) {
        return ResponseEntity.ok(agentService.getAgentsByStatus(status));
    }

    /** Update only Agent status - ADMIN only */
    @PutMapping("/{id}/status")
    @Operation(summary = "Update agent status")
    @PreAuthorize("hasRole('ADMIN')")
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

    /** Get all deleted agents - ADMIN only */
    @GetMapping("/deleted")
    @Operation(summary = "Get all deleted agents (deletion history)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<DeletedAgent>> getDeletedAgents() {
        List<DeletedAgent> deletedAgents = agentService.getAllDeletedAgents();
        if (deletedAgents.isEmpty()) {
            return ResponseEntity.ok().body(List.of());
        }
        return ResponseEntity.ok(deletedAgents);
    }
}