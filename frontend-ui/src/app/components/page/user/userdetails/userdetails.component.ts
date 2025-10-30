// userdetails.component.ts
import { Component, Input, OnChanges } from '@angular/core';
import { User } from '../../../services/models';
import { UsersService } from '../../../services/services/users.service';

@Component({
  selector: 'app-userdetails',
  templateUrl: './userdetails.component.html',
  styleUrls: ['./userdetails.component.scss']
})
export class UserdetailsComponent implements OnChanges {
  @Input() userId!: number;
  user: User | null = null;
  loading = false;
  message: { type: string, text: string } | null = null;

  constructor(private usersService: UsersService) {}

  ngOnChanges(): void {
    if (this.userId) {
      this.loadUser();
    }
  }

  loadUser() {
    this.loading = true;
    this.message = null;

    this.usersService.getUserById({ id: this.userId }).subscribe({
      next: data => {
        // Type assertion ensures TypeScript knows this is a full User object
        this.user = data as User;
        this.loading = false;
      },
      error: err => {
        this.user = null;
        this.loading = false;
        this.message = { type: 'error', text: 'Failed to load user details.' };
      }
    });
  }
}
