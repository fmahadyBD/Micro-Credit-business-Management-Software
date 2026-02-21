import { Component, Input, OnInit, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AgentsService } from '../../../../services/services/agents.service';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { Agent } from '../../../../services/models/agent';

@Component({
  selector: 'app-agent-details',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './details-agent.component.html',
  styleUrls: ['./details-agent.component.css']
})
export class DetailsAgentComponent implements OnInit, OnChanges {
  @Input() agentId!: number;
  
  agent: Agent | null = null;
  loading = true;
  isSidebarCollapsed = false;
  message: string | null = null;

  constructor(
    private agentsService: AgentsService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(c => (this.isSidebarCollapsed = c));
    
    // Load agent when component initializes with agentId
    if (this.agentId) {
      this.loadAgent(this.agentId);
    }
  }

  ngOnChanges(changes: SimpleChanges): void {
    // Reload agent when agentId input changes
    if (changes['agentId'] && this.agentId) {
      this.loadAgent(this.agentId);
    }
  }

  loadAgent(id: number): void {
    this.loading = true;
    this.message = null;
    this.agent = null;
    
    this.agentsService.getAgentById({ id }).subscribe({
      next: (data: any) => {
        this.agent = data;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading agent:', err);
        this.message = 'Failed to load agent details. Please try again.';
        this.loading = false;
      }
    });
  }

  editAgent(): void {
    if (this.agent?.id) {
      // Dispatch event to parent component to switch to edit mode
      window.dispatchEvent(new CustomEvent('editAgent', { detail: this.agent.id }));
    }
  }

  goBack(): void {
    // Dispatch event to parent component to go back to all agents
    window.dispatchEvent(new CustomEvent('backToAllAgents'));
  }

  getStatusClass(status: string | undefined): string {
    switch (status) {
      case 'ACTIVE': return 'badge bg-success';
      case 'INACTIVE': return 'badge bg-secondary';
      case 'SUSPENDED': return 'badge bg-warning';
      default: return 'badge bg-secondary';
    }
  }

  formatDate(date: string | undefined): string {
    if (!date) return 'N/A';
    try {
      return new Date(date).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      });
    } catch {
      return 'Invalid Date';
    }
  }
}