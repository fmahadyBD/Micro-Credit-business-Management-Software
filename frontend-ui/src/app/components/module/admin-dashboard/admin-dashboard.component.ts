// admin-dashboard.component.ts
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

import { SideBarComponent } from '../../layout/side-bar/side-bar.component';
import { TopBarComponent } from '../../layout/top-bar/top-bar.component';
import { AdminMainComponent } from '../admin-main/admin-main.component';
import { AllUsersComponent } from '../../page/all-users/all-users.component';
import { AddNewUserComponent } from '../../page/add-new-user/add-new-user.component';
import { DeletedUsersComponent } from '../../page/deleted-users/deleted-users.component';
import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    SideBarComponent,
    TopBarComponent,
    AdminMainComponent,
    AllUsersComponent,
    AddNewUserComponent,
    DeletedUsersComponent
  ],
  templateUrl: './admin-dashboard.component.html',
  styleUrls: ['./admin-dashboard.component.css']
})
export class AdminDashboardComponent implements OnInit {
  isSidebarCollapsed = false;
  currentView: 'dashboard' | 'all-users' | 'add-user' | 'deleted-users' = 'dashboard';

  constructor(private sidebarService: SidebarTopbarService) {}

  ngOnInit() {
    this.sidebarService.isCollapsed$.subscribe(state => {
      this.isSidebarCollapsed = state;
    });
  }

  setView(view: 'dashboard' | 'all-users' | 'add-user' | 'deleted-users') {
    this.currentView = view;
  }
}
