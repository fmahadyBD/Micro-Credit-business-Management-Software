import { Component, Inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { User } from '../../../../service/models/user.model'; // ✅ fixed import
import { UsersService } from '../../../../service/models/users.service';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { AuthService } from '../../../../service/auth.service';


@Component({
  selector: 'app-all-users',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './all-users.component.html'
})
export class AllUsersComponent implements OnInit {
  users: User[] = [];
  loading = false;
  message: { text: string, type: 'success' | 'error' } | null = null;
  isSidebarCollapsed = false;
  selectedUser: User | null = null;
  newStatus: User['status'] = 'ACTIVE';
  isAdminUser = false; // ✅ for UI condition

  constructor(
    @Inject(UsersService) private userService: UsersService,
    private sidebarService: SidebarTopbarService,
    private router: Router,
    private authService: AuthService // ✅ inject auth
  ) { }

  ngOnInit() {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });

    // ✅ Check if logged-in user is admin
    this.isAdminUser = this.authService.isAdmin();

    if (this.isAdminUser) {
      this.loadUsers();
    } else {
      this.message = {
        text: 'Access denied: only administrators can view all users.',
        type: 'error'
      };
    }
  }

  loadUsers() {
    this.loading = true;
    this.userService.getAllUsers().subscribe({
      next: (users: User[]) => {
        this.users = users;
        this.loading = false;
      },
      error: (err: any) => {
        console.error(err);
        this.message = { text: 'Failed to load users', type: 'error' };
        this.loading = false;
      }
    });
  }

  // addUser() {
  //   this.router.navigate(['/admin/add-user']);
  // }

  // viewDetails(user: User) {
  //   this.router.navigate(['/admin/user-details', user.id]);
  // }

  // editUser(user: User) {
  //   this.router.navigate(['/admin/edit-user', user.id]);
  // }


  viewDetails(user: User) {
    window.dispatchEvent(new CustomEvent('viewUserDetails', { detail: user.id }));
  }

  editUser(user: User) {
    window.dispatchEvent(new CustomEvent('editUser', { detail: user.id }));
  }


  deleteUser(user: User) {
    if (!this.isAdminUser) return;

    if (confirm(`Are you sure you want to delete user: ${user.username}?`)) {
      this.userService.deleteUser(user.id!).subscribe({
        next: () => {
          this.message = { text: 'User deleted successfully', type: 'success' };
          this.loadUsers();
        },
        error: (err: any) => {
          console.error(err);
          this.message = { text: 'Failed to delete user', type: 'error' };
        }
      });
    }
  }

  confirmStatusChange(user: User) {
    if (!this.isAdminUser) return;

    this.selectedUser = user;
    this.newStatus = this.getNextStatus(user.status);

    const modal = new (window as any).bootstrap.Modal(document.getElementById('statusModal'));
    modal.show();
  }

  updateStatus() {
    if (!this.selectedUser) return;

    this.userService.updateUserStatus(this.selectedUser.id!, this.newStatus).subscribe({
      next: () => {
        this.message = { text: 'User status updated successfully', type: 'success' };
        this.loadUsers();

        const modal = (window as any).bootstrap.Modal.getInstance(document.getElementById('statusModal'));
        modal.hide();
      },
      error: (err: any) => {
        console.error(err);
        this.message = { text: 'Failed to update user status', type: 'error' };
      }
    });
  }

  displayStatus(status: User['status']): string {
    const statusMap: { [key in User['status']]: string } = {
      'ACTIVE': 'Active',
      'INACTIVE': 'Inactive',
      'SUSPENDED': 'Suspended',
      'PENDING_VERIFICATION': 'Pending Verification'
    };
    return statusMap[status] || status;
  }

  private getNextStatus(currentStatus: User['status']): User['status'] {
    const statusOrder: User['status'][] = ['ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_VERIFICATION'];
    const currentIndex = statusOrder.indexOf(currentStatus);
    return statusOrder[(currentIndex + 1) % statusOrder.length];
  }
}
