import { Component, Inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { User } from '../../../../service/models/user';
import { UsersService } from '../../../../service/models/users.service';

@Component({
  selector: 'app-add-new-user',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './add-new-user.component.html'
})
export class AddNewUserComponent {
  user: User = {
    username: '',
    password: '',
    role: 'AGENT',
    status: 'ACTIVE',
    referenceId: 0
  };

  submitting = false;
  message: { text: string, type: 'success' | 'error' } | null = null;

  roles: User['role'][] = ['ADMIN', 'AGENT', 'SHAREHOLDER'];
  statuses: User['status'][] = ['ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_VERIFICATION'];

  constructor(
    @Inject(UsersService) private usersService: UsersService,
    private router: Router
  ) {}

  submitUser() {
    this.submitting = true;
    this.message = null;

    this.usersService.createUser(this.user).subscribe({
      next: (res: User) => {
        this.message = { text: 'User created successfully!', type: 'success' };
        this.submitting = false;
        setTimeout(() => this.router.navigate(['/admin/users']), 2000);
      },
      error: (err: any) => {
        console.error(err);
        this.message = { 
          text: err.error?.message || 'Failed to create user', 
          type: 'error' 
        };
        this.submitting = false;
      }
    });
  }
}