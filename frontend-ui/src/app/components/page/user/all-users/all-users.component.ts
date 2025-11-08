import { Component, Inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { User } from '../../../../service/models/user';
import { UsersService } from '../../../../service/models/users.service';


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
  
  // For status modal
  selectedUser: User | null = null;
  newStatus: User['status'] = 'ACTIVE';

  constructor(
    @Inject(UsersService) private userService: UsersService,
    private router: Router
  ) {}

  ngOnInit() {
    this.loadUsers();
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

  addUser() {
    this.router.navigate(['/admin/add-user']);
  }

  viewDetails(user: User) {
    this.router.navigate(['/admin/user-details', user.id]);
  }

  editUser(user: User) {
    this.router.navigate(['/admin/edit-user', user.id]);
  }

  deleteUser(user: User) {
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
    this.selectedUser = user;
    this.newStatus = this.getNextStatus(user.status);
    // Show modal - you might need to use ViewChild for Bootstrap modal
    const modal = new (window as any).bootstrap.Modal(document.getElementById('statusModal'));
    modal.show();
  }

  updateStatus() {
    if (!this.selectedUser) return;

    this.userService.updateUserStatus(this.selectedUser.id!, this.newStatus).subscribe({
      next: () => {
        this.message = { text: 'User status updated successfully', type: 'success' };
        this.loadUsers();
        // Hide modal
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