import { Component, Input, OnInit, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { User } from '../../../../service/models/user';
import { UsersService } from '../../../../service/models/users.service';

@Component({
  selector: 'app-edit-user',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './edit-user.component.html'
})
export class EditUserComponent implements OnInit, OnChanges {
  @Input() userId!: number;
  
  user: User = {
    username: '',
    password: '',
    role: 'AGENT',
    status: 'ACTIVE'
  };
  
  loading = false;
  message = '';

  constructor(private userService: UsersService) {}

  ngOnInit() {
    if (this.userId) {
      this.loadUser();
    }
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes['userId'] && changes['userId'].currentValue) {
      this.loadUser();
    }
  }

  loadUser() {
    this.loading = true;
    this.userService.getUserById(this.userId).subscribe({
      next: (user: User) => {
        this.user = user;
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