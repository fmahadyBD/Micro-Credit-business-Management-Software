import { Component, OnInit } from '@angular/core';
import { CommonModule, NgIf, NgFor, NgClass } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Agent } from '../../../../services/models';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { AgentsService } from '../../../../services/services/agents.service';


@Component({
  selector: 'app-add-new-agent',
  standalone: true,
  imports: [CommonModule, FormsModule, NgIf, NgFor, NgClass],
  templateUrl: './add-new-agent.component.html',
  styleUrls: ['./add-new-agent.component.css']
})
export class AddNewAgentComponent implements OnInit {
  agent: Agent = {
    name: '',
    phone: '',
    email: '',
    zila: '',
    village: '',
    nidCard: '',
    photo: '',
    nominee: '',
    role: 'AGENT',
    status: 'ACTIVE'
  };

  message: { type: string; text: string } | null = null;
  submitting = false;
  isSidebarCollapsed = false;

  statuses: Agent['status'][] = ['ACTIVE', 'INACTIVE', 'SUSPENDED'];

  constructor(
    private sidebarService: SidebarTopbarService,
    private agentsService: AgentsService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(c => (this.isSidebarCollapsed = c));
  }

  submitAgent() {
    if (!this.agent.name || !this.agent.phone) {
      this.message = { type: 'error', text: 'Name and phone are required!' };
      return;
    }

    this.submitting = true;

    const agentPayload: Agent = {
      ...this.agent,
      email: this.agent.email || '',
      nominee: this.agent.nominee || '',
      role: 'AGENT'
    };

    console.log('Sending payload:', agentPayload);

    this.agentsService.createAgent({ body: agentPayload }).subscribe({
      next: res => {
        console.log('Agent created:', res);
        this.message = { type: 'success', text: 'Agent created successfully!' };
        this.resetForm();
      },
      error: err => {
        console.error('Error:', err);
        this.message = {
          type: 'error',
          text: 'Failed to create agent. ' + (err.error?.message || 'Unknown error')
        };
        this.submitting = false;
      }
    });
  }

  private resetForm() {
    this.agent = {
      name: '',
      phone: '',
      email: '',
      zila: '',
      village: '',
      nidCard: '',
      photo: '',
      nominee: '',
      role: 'AGENT',
      status: 'ACTIVE'
    };
    this.submitting = false;
    setTimeout(() => (this.message = null), 3000);
  }
}
