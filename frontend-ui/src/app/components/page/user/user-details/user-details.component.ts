import { Component, Input, OnInit, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { UsersService } from '../../../../service/models/users.service';
import { User } from '../../../../service/models/user.model';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-user-details',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './user-details.component.html'
})
export class UserDetailsComponent implements OnInit, OnChanges {
  @Input() userId!: number;

  user: User | null = null;
  loading = false;
  message = '';
  isSidebarCollapsed = false;
  constructor(private userService: UsersService,
    private sidebarService: SidebarTopbarService
  ) { }

  ngOnInit() {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });


    if (this.userId) {
      this.loadUser(this.userId);
    }
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes['userId'] && changes['userId'].currentValue) {
      this.loadUser(changes['userId'].currentValue);
    }
  }

  loadUser(id: number) {
    this.loading = true;
    this.userService.getUserById(id).subscribe({
      next: (user: User) => {
        this.user = user;
        this.loading = false;
      },
      error: (err: any) => {
        console.error(err);
        this.message = 'Failed to load user details';
        this.loading = false;
      }
    });
  }

  backToUsers() {
    window.dispatchEvent(new CustomEvent('backToAllUsers'));
  }
}