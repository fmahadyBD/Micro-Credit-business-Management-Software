import { Component } from '@angular/core';
import { SideBarComponent } from '../../layout/side-bar/side-bar.component';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-admin-dashboard',
  imports: [SideBarComponent ,RouterModule, ],
  templateUrl: './admin-dashboard.component.html',
  styleUrl: './admin-dashboard.component.css'
})
export class AdminDashboardComponent {

}
