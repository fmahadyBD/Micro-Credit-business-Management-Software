import { HttpClientModule } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Member } from '../../../../services/models';
import { MembersService } from '../../../../services/services/members.service';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

interface Message {
  type: 'success' | 'error';
  text: string;
}
declare var bootstrap: any;

@Component({
  selector: 'app-all-members',
  standalone: true,
  imports: [HttpClientModule, CommonModule],
  templateUrl: './all-members.component.html',
  styleUrls: ['./all-members.component.css']
})
export class AllMembersComponent implements OnInit {

  members: Member[] = [];
  loading = false;
  message: Message | null = null;
  isSidebarCollapsed = false;

  selectedMember: Member | null = null;
  newStatus: Member['status'] = 'ACTIVE';

  constructor(
    private memberService: MembersService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadMembers();
  }

  loadMembers(): void {
    this.loading = true;
    this.memberService.getAllMembers().subscribe({
      next: (members) => {
        this.members = members;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading members:', err);
        this.message = { type: 'error', text: 'Failed to load members.' };
        this.loading = false;
      }
    });
  }

  addMember(): void {
    this.message = { type: 'success', text: 'Add member clicked (not implemented).' };
  }

  viewDetails(member: Member): void {
    this.message = { type: 'success', text: `View details for ${member.name}.` };
  }

  editMember(member: Member): void {
    this.message = { type: 'success', text: `Edit member ${member.name} clicked.` };
  }

  deleteMember(member: Member): void {
    if (!member.id) {
      this.message = { type: 'error', text: 'Invalid member ID.' };
      return;
    }

    if (!confirm(`Are you sure you want to delete ${member.name}?`)) {
      return;
    }

    const memberId = member.id;
    const name = member.name;

    this.memberService.deleteMember({ id: memberId }).subscribe({
      next: () => {
        this.members = this.members.filter(m => m.id !== memberId);
        this.message = { type: 'success', text: `Member "${name}" deleted successfully.` };
        setTimeout(() => this.message = null, 3000);
      },
      error: (err) => {
        console.error('Delete member error:', err);
        this.message = { type: 'error', text: `Failed to delete "${name}". ${err.error?.message || ''}` };
      }
    });
  }

  confirmStatusChange(member: Member) {
    this.selectedMember = member;
    this.newStatus = member.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';

    const modalElement = document.getElementById('statusModal');
    if (modalElement) {
      const modal = new bootstrap.Modal(modalElement);
      modal.show();
    }
  }

  updateStatus() {
    if (!this.selectedMember || this.selectedMember.id === undefined) {
      this.message = { type: 'error', text: 'Invalid member selected.' };
      return;
    }

    const updatedMember: Member = { ...this.selectedMember, status: this.newStatus };
    const memberId = this.selectedMember.id;
    const name = this.selectedMember.name;

    this.memberService.updateMember({ id: memberId, body: updatedMember }).subscribe({
      next: () => {
        const index = this.members.findIndex(m => m.id === memberId);
        if (index !== -1) this.members[index].status = this.newStatus;
        this.message = { type: 'success', text: `Status of "${name}" updated to ${this.newStatus}.` };
        this.closeModal();
        setTimeout(() => this.message = null, 3000);
      },
      error: (err) => {
        console.error('Update status error:', err);
        this.message = { type: 'error', text: `Failed to update status for "${name}".` };
        this.closeModal();
      }
    });
  }

  closeModal() {
    this.selectedMember = null;
    this.newStatus = 'ACTIVE';
    const modalElement = document.getElementById('statusModal');
    const modal = bootstrap.Modal.getInstance(modalElement!);
    modal?.hide();
  }
}
