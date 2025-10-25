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
  loading: boolean = false;
  message: Message | null = null;
  isSidebarCollapsed = false;

  selectedUser: User | null = null;
  newStatus: string = '';

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
      this.message = { type: 'error', text: `Cannot delete ${user.username}: ID missing.` };
      return;
    }
    if (!confirm(`Are you sure you want to delete ${user.username}?`)) return;

    this.userService.deleteUser({ id: user.id }).subscribe({
      next: () => {
        this.users = this.users.filter(u => u.id !== user.id);
        this.message = { type: 'success', text: `Deleted user ${user.username}.` };
      },
      error: (err) => {
        console.error('Delete user error:', err);
        this.message = { type: 'error', text: `Failed to delete ${user.username}.` };
      }
    });
  }

  /** Open confirmation modal to change status */
  confirmStatusChange(user: User) {
    this.selectedUser = user;
    this.newStatus = user.status === 'Active' ? 'Inactive' : 'Active';
    const modalElement = document.getElementById('statusModal');
    if (modalElement) {
      const modal = new bootstrap.Modal(modalElement);
      modal.show();
    }
  }

  /** Update status after confirmation */
  updateStatus() {
    if (!this.selectedUser || this.selectedUser.id === undefined) return;

    const userId = this.selectedUser.id;

    this.userService.updateUser({
      id: userId,
      body: { ...this.selectedUser, status: this.newStatus }
    }).subscribe({
      next: (updated) => {
        if (this.selectedUser) this.selectedUser.status = updated.status;
        this.message = { type: 'success', text: `User ${this.selectedUser?.username} status updated.` };
        this.selectedUser = null;
      },
      error: (err) => {
        console.error('Toggle status error:', err);
        this.message = { type: 'error', text: `Failed to update status.` };
        this.selectedUser = null;
      }
    });

    const modalElement = document.getElementById('statusModal');
    if (modalElement) {
      const modal = bootstrap.Modal.getInstance(modalElement);
      modal?.hide();
    }
  }
}
