import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MembersService } from '../../../../services/services/members.service';
import { Member } from '../../../../services/models/member';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-member-details',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './member-details.component.html',
  styleUrls: ['./member-details.component.css']
})
export class MemberDetailsComponent implements OnInit {
  @Input() memberId!: number;
  member: Member | null = null;
  loading: boolean = true;
  error: string | null = null;
  isSidebarCollapsed = false;

  constructor(
    private membersService: MembersService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadMemberDetails();
  }

  loadMemberDetails(): void {
    this.loading = true;
    this.error = null;

    this.membersService.getMemberById({ id: this.memberId }).subscribe({
      next: (data: any) => {
        this.member = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load member details';
        this.loading = false;
        console.error('Error loading member:', err);
      }
    });
  }

  goBack(): void {
    window.dispatchEvent(new CustomEvent('backToAllMembers'));
  }

  formatDate(date: string | undefined): string {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString();
  }

  getStatusClass(status: string | undefined): string {
    switch(status) {
      case 'ACTIVE': return 'badge bg-success';
      case 'INACTIVE': return 'badge bg-secondary';
      case 'SUSPENDED': return 'badge bg-warning';
      default: return 'badge bg-secondary';
    }
  }
}