// deleted-users.component.ts
import { Component, OnInit } from '@angular/core';
import { CommonModule, NgFor, NgIf, NgClass, DatePipe } from '@angular/common';
import { DeletedUser } from '../../../../services/models/deleted-user';
import { UsersService } from '../../../../services/services/users.service';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-deleted-users',
  standalone: true,
  imports: [CommonModule, NgFor, NgIf, NgClass, DatePipe],
  templateUrl: './deleted-users.component.html',
  styleUrls: ['./deleted-users.component.css']
})
export class DeletedUsersComponent implements OnInit {
  deletedUsers: DeletedUser[] = [];
  loading = false;
  message: { type: string, text: string } | null = null;
  isSidebarCollapsed = false;
  constructor(private usersService: UsersService, private sidebarService: SidebarTopbarService) { }

  ngOnInit() {
    this.loadDeletedUsers();
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
  }

  loadDeletedUsers() {
    this.loading = true;
    this.usersService.getDeletedUsers().subscribe({
      next: data => {
        this.deletedUsers = data;
        this.loading = false;
      },
      error: err => {
        this.deletedUsers = [];
        this.loading = false;
        this.message = { type: 'error', text: 'Failed to load deleted users.' };
      }
    });
  }
}
