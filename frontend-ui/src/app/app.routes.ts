import { Routes } from '@angular/router';
import { AdminDashboardComponent } from './components/module/admin-dashboard/admin-dashboard.component';
import { SideBarComponent } from './components/layout/side-bar/side-bar.component';
import { AllUsersComponent } from './components/page/user/all-users/all-users.component';



// Add 'export' here
export const routes: Routes = [
  { path: '', redirectTo: '/admin', pathMatch: 'full' },
  { path: 'admin', component: AdminDashboardComponent },
    { path: 'side', component: SideBarComponent },
    {path:'all-users',component:AllUsersComponent},

  { path: '**', redirectTo: '/admin' }
];