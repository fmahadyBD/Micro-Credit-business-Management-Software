import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AgentsService } from '../../../../services/services/agents.service';
import { Agent } from '../../../../services/models/agent';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-all-agents',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './all-agents.component.html',
  styleUrls: ['./all-agents.component.css']
})
export class AllAgentsComponent implements OnInit {
  agents: Agent[] = [];
  loading: boolean = true;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  constructor(
    private agentsService: AgentsService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadAgents();
  }

  loadAgents(): void {
    this.loading = true;
    this.error = null;

    this.agentsService.getAllAgents().subscribe({
      next: (data) => {
        this.agents = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load agents';
        this.loading = false;
        console.error('Error loading agents:', err);
      }
    });
  }

  viewDetails(agentId: number): void {
    window.dispatchEvent(new CustomEvent('viewAgentDetails', { detail: agentId }));
  }

  editAgent(agentId: number): void {
    window.dispatchEvent(new CustomEvent('editAgent', { detail: agentId }));
  }

  deleteAgent(agentId: number): void {
    if (confirm('Are you sure you want to delete this agent?')) {
      this.agentsService.deleteAgent({ id: agentId }).subscribe({
        next: () => {
          this.successMessage = 'Agent deleted successfully!';
          this.loadAgents();
          setTimeout(() => {
            this.successMessage = null;
          }, 3000);
        },
        error: (err) => {
          this.error = 'Failed to delete agent';
          console.error('Error deleting agent:', err);
        }
      });
    }
  }

  addAgent(): void {
    window.dispatchEvent(new CustomEvent('addAgent'));
  }

  formatDate(date: string | undefined): string {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString();
  }

  getStatusClass(status: string | undefined): string {
    switch (status) {
      case 'ACTIVE': return 'badge bg-success';
      case 'INACTIVE': return 'badge bg-secondary';
      case 'SUSPENDED': return 'badge bg-warning';
      default: return 'badge bg-secondary';
    }
  }
}
