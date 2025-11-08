import { Component, Inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DeletedUser } from '../../../../service/models/user';
import { UsersService } from '../../../../service/models/users.service';

@Component({
  selector: 'app-deleted-users',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './deleted-users.component.html'
})
export class DeletedUsersComponent implements OnInit {
  deletedUsers: DeletedUser[] = [];
  loading = false;
  message: { text: string, type: 'success' | 'error' } | null = null;

  constructor(
    @Inject(UsersService) private usersService: UsersService
  ) {}

  ngOnInit() {
    this.loadDeletedUsers();
  }

  loadDeletedUsers() {
    this.loading = true;
    this.usersService.getDeletedUsers().subscribe({
      next: (data: DeletedUser[]) => {
        this.deletedUsers = data;
        this.loading = false;
      },
      error: (err: any) => {
        console.error(err);
        this.message = { text: 'Failed to load deleted users', type: 'error' };
        this.loading = false;
      }
    });
  }

  restoreUser(id: number) {
    this.usersService.restoreUser(id).subscribe({
      next: () => {
        this.message = { text: 'User restored successfully', type: 'success' };
        this.loadDeletedUsers();
      },
      error: (err: any) => {
        console.error(err);
        this.message = { text: 'Failed to restore user', type: 'error' };
      }
    });
  }
}