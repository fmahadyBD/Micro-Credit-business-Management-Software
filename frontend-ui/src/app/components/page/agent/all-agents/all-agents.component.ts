import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { Agent } from '../../../../services/models/agent';

@Component({
  selector: 'app-all-agents',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './all-agents.component.html',
  styleUrls: ['./all-agents.component.css']
})
export class AllAgentsComponent implements OnInit {
  agents: Agent[] = [];
  loading = true;
  message: { text: string; type: 'success' | 'error' } | null = null;
  isSidebarCollapsed = false;

  selectedAgent: Agent | null = null;
  newStatus: string = '';

  constructor(private sidebarService: SidebarTopbarService) {}

  ngOnInit(): void {
    // Handle sidebar collapse updates
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });

    // Load agent data (for now, mock data)
    this.loadAgents();
  }

  loadAgents() {
    // Replace with actual API call later
    setTimeout(() => {
      this.agents = [
        { id: 1, name: 'Fahim', phone: '01712345678', village: 'Dhanmondi', zila: 'Dhaka', nidCard: '123456', nominee: 'Mahady', status: 'ACTIVE', email: 'fahim@example.com' },
        { id: 2, name: 'Hasan', phone: '01887654321', village: 'Uttara', zila: 'Dhaka', nidCard: '654321', nominee: 'Rafi', status: 'INACTIVE', email: 'hasan@example.com' }
      ];
      this.loading = false;
    }, 800);
  }

  confirmStatusChange(agent: Agent) {
    this.selectedAgent = agent;
    this.newStatus = agent.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    const modal = document.getElementById('statusModal');
    if (modal) {
      (window as any).bootstrap.Modal.getOrCreateInstance(modal).show();
    }
  }

  updateStatus() {
    if (this.selectedAgent) {
      this.selectedAgent.status = this.newStatus;
      this.message = { text: `Status updated to ${this.newStatus}`, type: 'success' };
      setTimeout(() => (this.message = null), 3000);
    }
    const modal = document.getElementById('statusModal');
    if (modal) {
      (window as any).bootstrap.Modal.getOrCreateInstance(modal).hide();
    }
  }

  viewDetails(agent: Agent) {
    alert(`Viewing details for ${agent.name}`);
  }

  editAgent(agent: Agent) {
    alert(`Editing ${agent.name}`);
  }

  deleteAgent(agent: Agent) {
    this.agents = this.agents.filter(a => a.id !== agent.id);
    this.message = { text: 'Agent deleted successfully', type: 'success' };
    setTimeout(() => (this.message = null), 3000);
  }

  addAgent() {
    alert('Add new agent form');
  }
}
