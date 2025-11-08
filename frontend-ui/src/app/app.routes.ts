import { Routes } from '@angular/router';
import { AdminDashboardComponent } from './components/module/admin-dashboard/admin-dashboard.component';
import { SideBarComponent } from './components/layout/side-bar/side-bar.component';
import { AllUsersComponent } from './components/page/user/all-users/all-users.component';
import { AddNewUserComponent } from './components/page/user/add-new-user/add-new-user.component';
import { DeletedUsersComponent } from './components/page/user/deleted-users/deleted-users.component';
import { UserDetailsComponent } from './components/page/user/user-details/user-details.component';
import { EditUserComponent } from './components/page/user/edit-user/edit-user.component';
import { LoginComponent } from './components/auth/login/login.component';
import { RegisterComponent } from './components/auth/register/register.component';

export const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { 
    path: 'admin', 
    component: AdminDashboardComponent,
    // children: [
    //   { path: 'users', component: AllUsersComponent },
    //   { path: 'add-user', component: AddNewUserComponent },
    //   { path: 'deleted-users', component: DeletedUsersComponent },
    //   { path: 'user-details/:id', component: UserDetailsComponent },
    //   { path: 'edit-user/:id', component: EditUserComponent },
    //   { path: '', redirectTo: 'users', pathMatch: 'full' }
    // ]
  },
  { path: 'side', component: SideBarComponent },
  { path: '**', redirectTo: '/login' }
];