package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.entity.Agent;
import com.fmahadybd.backend.service.AgentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/agents")
public class AgentController {

    @Autowired
    private AgentService agentService;

    // Create new Agent
    @PostMapping("/create")
    public ResponseEntity<Agent> createAgent(@RequestBody Agent agent) {
        Agent savedAgent = agentService.createAgent(agent);
        return ResponseEntity.ok(savedAgent);
    }

    // Get all Agents
    @GetMapping("/all")
    public ResponseEntity<List<Agent>> getAllAgents() {
        return ResponseEntity.ok(agentService.getAllAgents());
    }

    // Get Agent by ID
    @GetMapping("/findbyid/{id}")
    public ResponseEntity<?> getAgentById(@PathVariable Long id) {
        return agentService.getAgentById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Update Agent
    @PutMapping("/updatebyid/{id}")
    public ResponseEntity<?> updateAgent(@PathVariable Long id, @RequestBody Agent updatedAgent) {
        Agent updated = agentService.updateAgent(id, updatedAgent);
        if (updated != null) {
            return ResponseEntity.ok(updated);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Delete Agent
    @DeleteMapping("/deletebyid/{id}")
    public ResponseEntity<?> deleteAgent(@PathVariable Long id) {
        boolean deleted = agentService.deleteAgent(id);
        if (deleted) {
            return ResponseEntity.ok("Agent deleted successfully");
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Get Agents by Status
    @GetMapping("/get/status/{status}")
    public ResponseEntity<List<Agent>> getAgentsByStatus(@PathVariable String status) {
        return ResponseEntity.ok(agentService.getAgentsByStatus(status));
    }

    // Update Agent status
    @PutMapping("/update/status/{id}")
    public ResponseEntity<?> updateAgentStatus(
            @PathVariable Long id,
            @RequestParam String status) {

        Agent updated = agentService.updateAgentStatus(id, status);
        if (updated != null) {
            return ResponseEntity.ok(updated);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

}
