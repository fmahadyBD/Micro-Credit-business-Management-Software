import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { SideBarComponent } from '../../layout/side-bar/side-bar.component';
import { TopBarComponent } from '../../layout/top-bar/top-bar.component';
import { AdminMainComponent } from '../admin-main/admin-main.component';
import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';
import { AllUsersComponent } from '../../page/all-users/all-users.component';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, SideBarComponent, TopBarComponent, AdminMainComponent, AllUsersComponent],
  templateUrl: './admin-dashboard.component.html',
  styleUrls: ['./admin-dashboard.component.css']
})
export class AdminDashboardComponent implements OnInit {
  isSidebarCollapsed = false;

  // Track which component is currently displayed
  currentView: 'dashboard' | 'all-users' = 'dashboard';

  constructor(private sidebarService: SidebarTopbarService) {}

  ngOnInit() {
    // Maintain sidebar collapse state
    this.sidebarService.isCollapsed$.subscribe(state => {
      this.isSidebarCollapsed = state;
    });
  }

  // Method to switch views from sidebar
  setView(view: 'dashboard' | 'all-users') {
    this.currentView = view;
  }
}
