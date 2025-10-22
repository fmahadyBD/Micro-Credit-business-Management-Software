import { Component } from '@angular/core';
import { SideBarComponent } from '../../layout/side-bar/side-bar.component';
import { RouterModule } from '@angular/router';
import { TopBarComponent } from '../../layout/top-bar/top-bar.component';
import { CommonModule } from '@angular/common';
import { AdminMainComponent } from '../admin-main/admin-main.component';

@Component({
  selector: 'app-admin-dashboard',
  imports: [SideBarComponent, RouterModule, TopBarComponent, AdminMainComponent],
  templateUrl: './admin-dashboard.component.html',
  styleUrl: './admin-dashboard.component.css'
})
export class AdminDashboardComponent {
  sidebarCollapsed = false;

  toggleSidebar() {
    this.sidebarCollapsed = !this.sidebarCollapsed;
  }
}