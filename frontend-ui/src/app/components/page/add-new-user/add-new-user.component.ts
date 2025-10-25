import { Component, OnInit } from '@angular/core';
import { CommonModule, NgFor, NgIf, NgClass } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { UsersService } from '../../../services/services/users.service';
import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';
import { User } from '../../../services/models';

@Component({
  selector: 'app-add-new-user',
  standalone: true,
  imports: [CommonModule, FormsModule, NgFor, NgIf, NgClass],
  templateUrl: './add-new-user.component.html',
  styleUrls: ['./add-new-user.component.css']
})
export class AddNewUserComponent implements OnInit {
  // Must exactly match backend enums
  user: User = {
    username: '',
    password: '',
    role: 'ADMIN',
    status: 'ACTIVE',
    referenceId: 0
  };

  message: { type: string; text: string } | null = null;
  submitting = false;
  isSidebarCollapsed = false;

  roles: User['role'][] = ['ADMIN', 'AGENT', 'SHAREHOLDER'];
  statuses: User['status'][] = ['ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_VERIFICATION'];

  constructor(
    private usersService: UsersService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
  }

  submitUser() {
    if (!this.user.username || !this.user.password) {
      this.message = { type: 'error', text: 'Username and password are required!' };
      return;
    }

    this.submitting = true;

    // Ensure proper typing before sending
    const userPayload: User = {
      username: this.user.username,
      password: this.user.password,
      role: this.user.role,
      status: this.user.status,
      referenceId: this.user.referenceId || 0
    };

    console.log('Sending payload:', JSON.stringify(userPayload));

    this.usersService.createUser({ body: userPayload }).subscribe({
      next: res => {
        console.log('Success response:', res);
        this.message = { type: 'success', text: 'User created successfully!' };
        this.user = {
          username: '',
          password: '',
          role: 'ADMIN',
          status: 'ACTIVE',
          referenceId: 0
        };
        this.submitting = false;
        
        // Auto-hide success message after 3 seconds
        setTimeout(() => {
          this.message = null;
        }, 3000);
      },
      error: err => {
        console.error('Error details:', err);
        this.message = {
          type: 'error',
          text: 'Failed to create user. ' + (err.error?.message || err.error || 'Unknown error')
        };
        this.submitting = false;
      }
    });
  }
}