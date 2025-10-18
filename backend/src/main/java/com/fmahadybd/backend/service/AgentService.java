package com.fmahadybd.backend.service;

import com.fmahadybd.backend.entity.Agent;
import com.fmahadybd.backend.repository.AgentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class AgentService {

    @Autowired
    private AgentRepository agentRepository;

    // Create new Agent
    public Agent createAgent(Agent agent) {
        agent.setJoinDate(LocalDateTime.now());
        return agentRepository.save(agent);
    }

    // Get all Agents
    public List<Agent> getAllAgents() {
        return agentRepository.findAll();
    }

    // Get Agent by ID
    public Optional<Agent> getAgentById(Long id) {
        return agentRepository.findById(id);
    }

    // Update Agent by ID
    public Agent updateAgent(Long id, Agent updatedAgent) {
        return agentRepository.findById(id).map(agent -> {
            agent.setName(updatedAgent.getName());
            agent.setPhone(updatedAgent.getPhone());
            agent.setEmail(updatedAgent.getEmail());
            agent.setZila(updatedAgent.getZila());
            agent.setVillage(updatedAgent.getVillage());
            agent.setNidCard(updatedAgent.getNidCard());
            agent.setPhoto(updatedAgent.getPhoto());
            agent.setNominee(updatedAgent.getNominee());
            agent.setRole(updatedAgent.getRole());
            agent.setStatus(updatedAgent.getStatus());
            return agentRepository.save(agent);
        }).orElse(null);
    }

    // Delete Agent by ID
    public boolean deleteAgent(Long id) {
        if (agentRepository.existsById(id)) {
            agentRepository.deleteById(id);
            return true;
        }
        return false;
    }

    // Find Agents by Status
    public List<Agent> getAgentsByStatus(String status) {
        return agentRepository.findByStatus(status);
    }

    // update agent
    public Agent updateAgentStatus(Long id, String status) {
        return agentRepository.findById(id).map(agent -> {
            agent.setStatus(status);
            return agentRepository.save(agent);
        }).orElse(null);
    }
}
