import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

import { SideBarComponent } from '../../layout/side-bar/side-bar.component';
import { TopBarComponent } from '../../layout/top-bar/top-bar.component';
import { AdminMainComponent } from '../admin-main/admin-main.component';



import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';
import { AllMembersComponent } from '../../page/members/all-members/all-members.component';
import { AllAgentsComponent } from '../../page/agent/all-agents/all-agents.component';
import { AddNewMemberComponent } from '../../page/members/add-new-member/add-new-member.component';
import { AddNewAgentComponent } from '../../page/agent/add-new-agent/add-new-agent.component';
import { DeletedUsersComponent } from '../../page/user/deleted-users/deleted-users.component';
import { AddNewUserComponent } from '../../page/user/add-new-user/add-new-user.component';
import { AllUsersComponent } from '../../page/user/all-users/all-users.component';

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
    DeletedUsersComponent,
    AllMembersComponent,
    AddNewMemberComponent,
    AllAgentsComponent,
    AddNewAgentComponent
  ],
  templateUrl: './admin-dashboard.component.html',
  styleUrls: ['./admin-dashboard.component.css']
})
export class AdminDashboardComponent implements OnInit {
  isSidebarCollapsed = false;

  currentView:
    | 'dashboard'
    | 'all-users' | 'add-user' | 'deleted-users'
    | 'all-members' | 'add-member'
    | 'all-agents' | 'add-agent'
    = 'dashboard';

  constructor(private sidebarService: SidebarTopbarService) {}

  ngOnInit() {
    this.sidebarService.isCollapsed$.subscribe(state => {
      this.isSidebarCollapsed = state;
    });
  }

  setView(view:
    | 'dashboard'
    | 'all-users' | 'add-user' | 'deleted-users'
    | 'all-members' | 'add-member'
    | 'all-agents' | 'add-agent') {
    this.currentView = view;
  }
}
