import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { SideBarComponent } from '../../layout/side-bar/side-bar.component';
import { TopBarComponent } from '../../layout/top-bar/top-bar.component';
import { AdminMainComponent } from '../admin-main/admin-main.component';
import { SidebarTopbarService } from '../../../services/sidebar-topbar.service';
import { AllUsersComponent } from '../../page/all-users/all-users.component';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, SideBarComponent, TopBarComponent,AllUsersComponent],
  templateUrl: './admin-dashboard.component.html',
  styleUrls: ['./admin-dashboard.component.css']
})
export class AdminDashboardComponent implements OnInit {
  isSidebarCollapsed = false;

  constructor(private sidebarService: SidebarTopbarService) {}

  ngOnInit() {
    this.sidebarService.isCollapsed$.subscribe(state => {
      this.isSidebarCollapsed = state;
    });
  }
}
