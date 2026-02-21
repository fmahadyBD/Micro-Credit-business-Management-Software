package com.fmahadybd.backend.service;

import com.fmahadybd.backend.entity.Agent;
import com.fmahadybd.backend.entity.DeletedAgent;
import com.fmahadybd.backend.repository.AgentRepository;
import com.fmahadybd.backend.repository.DeletedAgentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class AgentService {

    @Autowired
    private AgentRepository agentRepository;

    @Autowired
    private DeletedAgentRepository deletedAgentRepository;

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

    // Delete Agent by ID (Move to DeletedAgent before delete)
    public boolean deleteAgent(Long id) {
        Optional<Agent> agentOpt = agentRepository.findById(id);
        if (agentOpt.isPresent()) {
            Agent agent = agentOpt.get();

            DeletedAgent deletedAgent = new DeletedAgent();
            deletedAgent.setOriginalAgentId(agent.getId());
            deletedAgent.setName(agent.getName());
            deletedAgent.setPhone(agent.getPhone());
            deletedAgent.setEmail(agent.getEmail());
            deletedAgent.setZila(agent.getZila());
            deletedAgent.setVillage(agent.getVillage());
            deletedAgent.setNidCard(agent.getNidCard());
            deletedAgent.setPhoto(agent.getPhoto());
            deletedAgent.setNominee(agent.getNominee());
            deletedAgent.setRole(agent.getRole());
            deletedAgent.setStatus(agent.getStatus());
            deletedAgent.setJoinDate(agent.getJoinDate());
            deletedAgent.setDeletedAt(LocalDateTime.now());

            // Save into deleted_agents table
            deletedAgentRepository.save(deletedAgent);

            // Delete from active agents table
            agentRepository.deleteById(id);
            return true;
        }
        return false;
    }

    // Get all deleted agents
    public List<DeletedAgent> getAllDeletedAgents() {
        return deletedAgentRepository.findAll();
    }

    // Find Agents by Status
    public List<Agent> getAgentsByStatus(String status) {
        return agentRepository.findByStatus(status);
    }

    // Update only agent status
    public Agent updateAgentStatus(Long id, String status) {
        return agentRepository.findById(id).map(agent -> {
            agent.setStatus(status);
            return agentRepository.save(agent);
        }).orElse(null);
    }
}