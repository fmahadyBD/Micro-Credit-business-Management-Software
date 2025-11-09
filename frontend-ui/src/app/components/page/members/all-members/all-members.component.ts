import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MembersService } from '../../../../services/services/members.service';
import { Member } from '../../../../services/models/member';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { AuthService } from '../../../../service/auth.service'; // ✅ Import AuthService

@Component({
  selector: 'app-all-members',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './all-members.component.html',
  styleUrls: ['./all-members.component.css']
})
export class AllMembersComponent implements OnInit {
  members: Member[] = [];
  loading = true;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  // ✅ Track user role
  userRole: string | null = null;

  constructor(
    private membersService: MembersService,
    private sidebarService: SidebarTopbarService,
    private authService: AuthService // ✅ Inject AuthService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });

    // ✅ Get user role from AuthService
    this.userRole = this.authService.getRole();

    this.loadMembers();
  }

  loadMembers(): void {
    this.loading = true;
    this.error = null;

    this.membersService.getAllMembers().subscribe({
      next: (data) => {
        this.members = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load members';
        this.loading = false;
        console.error('Error loading members:', err);
      }
    });
  }

  viewDetails(memberId: number): void {
    window.dispatchEvent(new CustomEvent('viewMemberDetails', { detail: memberId }));
  }

  editMember(memberId: number): void {
    window.dispatchEvent(new CustomEvent('editMember', { detail: memberId }));
  }

  // ✅ Allow delete only if admin
  deleteMember(memberId: number): void {
    if (this.userRole !== 'ADMIN') {
      alert('You are not authorized to delete members.');
      return;
    }

    if (confirm('Are you sure you want to delete this member?')) {
      this.membersService.deleteMember({ id: memberId }).subscribe({
        next: () => {
          this.successMessage = 'Member deleted successfully!';
          this.loadMembers();
          setTimeout(() => {
            this.successMessage = null;
          }, 3000);
        },
        error: (err) => {
          this.error = 'Failed to delete member';
          console.error('Error deleting member:', err);
        }
      });
    }
  }

  formatDate(date: string | undefined): string {
    return date ? new Date(date).toLocaleDateString() : 'N/A';
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
