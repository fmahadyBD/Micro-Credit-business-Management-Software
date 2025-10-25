import { HttpClientModule } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { UsersService } from '../../../services/services';
import { User } from '../../../services/models/user';
import { CommonModule } from '@angular/common';
import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';

interface Message {
  type: 'success' | 'error';
  text: string;
}
declare var bootstrap: any;

@Component({
  selector: 'app-all-users',
  standalone: true,
  imports: [HttpClientModule, CommonModule],
  templateUrl: './all-users.component.html',
  styleUrls: ['./all-users.component.css']
})
export class AllUsersComponent implements OnInit {

  users: User[] = [];
  loading = false;
  message: Message | null = null;
  isSidebarCollapsed = false;

  selectedUser: User | null = null;
  newStatus: User['status'] = 'ACTIVE';

  constructor(private userService: UsersService, private sidebarService: SidebarTopbarService) { }

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadUsers();
  }

  loadUsers(): void {
    this.loading = true;
    this.userService.getAllUsers().subscribe({
      next: (users) => {
        this.users = users;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading users:', err);
        this.message = { type: 'error', text: 'Failed to load users.' };
        this.loading = false;
      }
    });
  }

  addUser(): void {
    this.message = { type: 'success', text: 'Add user clicked (not implemented).' };
  }

  viewDetails(user: User): void {
    this.message = { type: 'success', text: `View details for ${user.username}.` };
  }

  editUser(user: User): void {
    this.message = { type: 'success', text: `Edit user ${user.username} clicked.` };
  }

  deleteUser(user: User): void {
    if (!user.id) {
      this.message = { type: 'error', text: 'Invalid user ID.' };
      return;
    }

    if (!confirm(`Are you sure you want to delete ${user.username}?`)) {
      return;
    }

    const userId = user.id;
    const username = user.username;

    this.userService.deleteUser({ id: userId }).subscribe({
      next: (response) => {
        console.log('Delete response:', response);
        
        // Remove user from the list immediately (optimistic update)
        this.users = this.users.filter(u => u.id !== userId);
        
        this.message = { 
          type: 'success', 
          text: `User "${username}" deleted successfully.` 
        };

        // Auto-hide success message after 3 seconds
        setTimeout(() => {
          this.message = null;
        }, 3000);
      },
      error: (err) => {
        console.error('Delete user error:', err);
        console.error('Error details:', err.error);
        
        // Still remove from list if backend says 404 (already deleted)
        if (err.status === 404) {
          this.users = this.users.filter(u => u.id !== userId);
          this.message = { 
            type: 'success', 
            text: `User "${username}" deleted successfully.` 
          };
        } else {
          this.message = { 
            type: 'error', 
            text: `Failed to delete "${username}". ${err.error?.message || err.message || ''}` 
          };
        }
      }
    });
  }

  confirmStatusChange(user: User) {
    this.selectedUser = user;
    this.newStatus = user.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';

    const modalElement = document.getElementById('statusModal');
    if (modalElement) {
      const modal = new bootstrap.Modal(modalElement);
      modal.show();
    }
  }

  updateStatus() {
    if (!this.selectedUser || this.selectedUser.id === undefined) {
      this.message = { type: 'error', text: 'Invalid user selected.' };
      return;
    }

    const updatedUser: User = {
      ...this.selectedUser,
      status: this.newStatus
    };

    const userId = this.selectedUser.id;
    const username = this.selectedUser.username;

    this.userService.updateUser({ id: userId, body: updatedUser }).subscribe({
      next: (response) => {
        console.log('Update response:', response);
        
        // Update user in the list
        const index = this.users.findIndex(u => u.id === userId);
        if (index !== -1) {
          this.users[index].status = this.newStatus;
        }

        this.message = { 
          type: 'success', 
          text: `Status of "${username}" updated to ${this.displayStatus(this.newStatus)}.` 
        };
        
        this.closeModal();

        // Auto-hide success message after 3 seconds
        setTimeout(() => {
          this.message = null;
        }, 3000);
      },
      error: (err) => {
        console.error('Update status error:', err);
        console.error('Error details:', err.error);
        
        this.message = { 
          type: 'error', 
          text: `Failed to update status for "${username}". ${err.error?.message || ''}` 
        };
        
        this.closeModal();
      }
    });
  }

  closeModal() {
    this.selectedUser = null;
    this.newStatus = 'ACTIVE';
    const modalElement = document.getElementById('statusModal');
    const modal = bootstrap.Modal.getInstance(modalElement!);
    modal?.hide();
  }

  displayStatus(status: User['status']): string {
    switch (status) {
      case 'ACTIVE': return 'Active';
      case 'INACTIVE': return 'Inactive';
      case 'SUSPENDED': return 'Suspended';
      case 'PENDING_VERIFICATION': return 'Pending Verification';
    }
  }
}