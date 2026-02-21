import { Component } from '@angular/core';
import { TopBarComponent } from '../../layout/top-bar/top-bar.component';

@Component({
  selector: 'app-user-dashboard',
  imports: [
      TopBarComponent
  ],
  templateUrl: './user-dashboard.component.html',
  styleUrl: './user-dashboard.component.css'
})
export class UserDashboardComponent {

}
