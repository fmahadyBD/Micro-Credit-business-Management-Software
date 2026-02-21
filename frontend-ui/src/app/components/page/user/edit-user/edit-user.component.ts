import { Component, Input, OnInit, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { UsersService } from '../../../../service/models/users.service';
import { AuthService } from '../../../../service/auth.service';
import { User, UpdateUserDTO } from '../../../../service/models/user.model';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-edit-user',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './edit-user.component.html'
})
export class EditUserComponent implements OnInit, OnChanges {
  @Input() userId!: number;

  user: UpdateUserDTO = {
    firstname: '',
    lastname: '',
    username: '',
    password: '',
    role: 'AGENT',
    status: 'ACTIVE'
  };

  originalUser: User | null = null;
  loading = false;
  message = '';
  isAdmin = false;
  isSidebarCollapsed = false;

  constructor(
    private userService: UsersService,
    private authService: AuthService,
    private sidebarService: SidebarTopbarService
  ) { }

  ngOnInit() {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    
    this.isAdmin = this.authService.isAdmin();
    if (this.userId && this.isAdmin) {
      this.loadUser();
    }
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes['userId'] && changes['userId'].currentValue && this.isAdmin) {
      this.loadUser();
    }
  }

  loadUser() {
    if (!this.isAdmin) {
      this.message = 'Access denied: Only administrators can edit users.';
      return;
    }

    this.loading = true;
    this.userService.getUserById(this.userId).subscribe({
      next: (user: User) => {
        this.originalUser = user;
        this.user = {
          firstname: user.firstname,
          lastname: user.lastname,
          username: user.username,
          password: '', // Don’t prefill password
          role: user.role,
          status: user.status,
          referenceId: user.referenceId
        };
        this.loading = false;
      },
      error: (err: any) => {
        console.error(err);
        this.message = 'Failed to load user';
        this.loading = false;
      }
    });
  }

  saveChanges() {
    if (!this.isAdmin) {
      this.message = 'Access denied: Only administrators can edit users.';
      return;
    }

    if (!this.user.username || !this.user.firstname || !this.user.lastname) {
      this.message = 'Please fill in all required fields.';
      return;
    }

    this.loading = true;
    this.userService.updateUser(this.userId, this.user).subscribe({
      next: () => {
        this.message = 'User updated successfully!';
        this.loading = false;
        setTimeout(() => {
          window.dispatchEvent(new CustomEvent('backToAllUsers'));
        }, 1500);
      },
      error: (err: any) => {
        console.error(err);
        this.message = err.error?.message || 'Failed to update user';
        this.loading = false;
      }
    });
  }

  backToUsers() {
    window.dispatchEvent(new CustomEvent('backToAllUsers'));
  }
}
