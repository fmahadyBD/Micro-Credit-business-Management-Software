import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';
import { Component, Input, OnInit } from '@angular/core';
import { User } from '../../../../services/models/user';
import { UsersService } from '../../../../services/services/users.service';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-user-details',
  standalone: true,
  imports: [CommonModule, HttpClientModule],
  templateUrl: './user-details.component.html',
  styleUrls: ['./user-details.component.css']
})
export class UserDetailsComponent implements OnInit {

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
        this.message = 'Failed to load user details.';
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
