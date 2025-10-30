import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';
import { Component, Input, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { User } from '../../../../services/models/user';
import { UsersService } from '../../../../services/services/users.service';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-edit-user',
  standalone: true,
  imports: [CommonModule, HttpClientModule, FormsModule],
  templateUrl: './edit-user.component.html',
  styleUrls: ['./edit-user.component.css']
})
export class EditUserComponent implements OnInit {

  @Input() userId!: number;
  user: User | null = null;
  loading = false;
  message: string | null = null;
  isSidebarCollapsed = false;

  constructor(
    private userService: UsersService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(c => this.isSidebarCollapsed = c);
    if (this.userId) {
      this.loadUser();
    }
  }

  loadUser(): void {
    this.loading = true;
    this.userService.getUserById({ id: this.userId }).subscribe({
      next: (data: any) => {
        this.user = data;
        this.loading = false;
      },
      error: (err) => {
        this.message = 'Failed to load user for editing.';
        console.error(err);
        this.loading = false;
      }
    });
  }

  saveChanges(): void {
    if (!this.user?.id) return;
    this.loading = true;

    this.userService.updateUser({ id: this.user.id, body: this.user }).subscribe({
      next: () => {
        this.message = 'User updated successfully.';
        this.loading = false;
      },
      error: (err) => {
        this.message = 'Failed to update user.';
        console.error(err);
        this.loading = false;
      }
    });
  }

  backToUsers() {
    const event = new CustomEvent('backToAllUsers');
    window.dispatchEvent(event);
  }
}
