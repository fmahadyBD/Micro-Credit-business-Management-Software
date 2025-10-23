import { HttpClient } from '@angular/common/http';
import { Component } from '@angular/core';
import { ApiConfiguration } from '../../../services/api-configuration';
import { getAllUsers } from '../../../services/functions';
import { User } from '../../../services/models';

@Component({
  selector: 'app-userdetails',
  imports: [],
  templateUrl: './userdetails.component.html',
  styleUrl: './userdetails.component.css'
})
export class UserdetailsComponent {
users: User[] = [];
  filteredUsers: User[] = [];
  searchTerm = '';

  constructor(
    private http: HttpClient,
    private apiConfig: ApiConfiguration
  ) {}

  ngOnInit(): void {
    this.loadUsers();
  }

  loadUsers(): void {
    getAllUsers(this.http, this.apiConfig.rootUrl).subscribe({
      next: (res) => {
        this.users = res.body ?? [];
        this.filteredUsers = [...this.users];
      },
      error: (err) => console.error('Failed to fetch users:', err)
    });
  }

  onSearch(): void {
    const term = this.searchTerm.toLowerCase();
    this.filteredUsers = this.users.filter(user =>
      user.username?.toLowerCase().includes(term) ||
      user.role?.toLowerCase().includes(term) ||
      user.status?.toLowerCase().includes(term)
    );
  }

  editUser(user: User): void {
    console.log('Edit user clicked:', user);
  }

  deleteUser(user: User): void {
    console.log('Delete user clicked:', user);
  }
}
