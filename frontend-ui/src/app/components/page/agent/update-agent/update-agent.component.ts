import { Component, Input, OnInit, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AgentsService } from '../../../../services/services/agents.service';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { Agent } from '../../../../services/models/agent';

@Component({
  selector: 'app-update-agent',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './update-agent.component.html',
  styleUrls: ['./update-agent.component.css']
})
export class UpdateAgentComponent implements OnInit, OnChanges {
  @Input() agentId!: number;
  
  agent: Agent = {};
  isSidebarCollapsed = false;
  loading = true;
  submitting = false;
  message: { text: string; type: 'success' | 'error' } | null = null;

  statuses: Agent['status'][] = ['ACTIVE', 'INACTIVE', 'SUSPENDED'];

  constructor(
    private agentsService: AgentsService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(c => (this.isSidebarCollapsed = c));
    
    if (this.agentId) {
      this.loadAgent(this.agentId);
    }
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['agentId'] && this.agentId) {
      this.loadAgent(this.agentId);
    }
  }

  loadAgent(id: number) {
    this.loading = true;
    this.agentsService.getAgentById({ id }).subscribe({
      next: (res: any) => {
        this.agent = res;
        this.loading = false;
      },
      error: err => {
        console.error('Error:', err);
        this.message = { text: 'Failed to load agent details', type: 'error' };
        this.loading = false;
      }
    });
  }

  updateAgent() {
    if (!this.agent.id) return;
    this.submitting = true;
    this.agentsService.updateAgent({ id: this.agent.id, body: this.agent }).subscribe({
      next: () => {
        this.message = { text: 'Agent updated successfully!', type: 'success' };
        this.submitting = false;
        // Dispatch event to go back to all agents after successful update
        setTimeout(() => window.dispatchEvent(new CustomEvent('backToAllAgents')), 1000);
      },
      error: err => {
        console.error(err);
        this.message = { text: 'Update failed!', type: 'error' };
        this.submitting = false;
      }
    });
  }

  goBack() {
    window.dispatchEvent(new CustomEvent('backToAllAgents'));
  }
}