import { Routes } from '@angular/router';
import { AdminDashboardComponent } from './components/module/admin-dashboard/admin-dashboard.component';
import { SideBarComponent } from './components/layout/side-bar/side-bar.component';
import { LoginComponent } from './components/auth/login/login.component';
import { RegisterComponent } from './components/auth/register/register.component';
import { UserDashboardComponent } from './components/module/user-dashboard/user-dashboard.component';
import { ShareholderDashboardComponent } from './components/module/shareholder-dashboard/shareholder-dashboard.component';

// Guards
import { AuthGuard } from './guards/auth.guard';
import { AdminGuard } from './guards/admin.guard';
import { UserGuard } from './guards/user.guard';
import { ShareholderGuard } from './guards/shareholder.guard';
import { UnauthorizedComponent } from './components/module/unauthorized/unauthorized.component';
import { AgentDashboardComponent } from './components/module/agent-dashboard/agent-dashboard.component';
import { AgentGuard } from './guards/agent.guard';

export const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { path: 'unauthorized', component: UnauthorizedComponent },

  // Admin routes
  {
    path: 'admin',
    component: AdminDashboardComponent,
    canActivate: [AuthGuard, AdminGuard]
  },

  // User routes
  {
    path: 'user',
    component: UserDashboardComponent,
    canActivate: [AuthGuard, UserGuard]
  },

  // Shareholder routes
  {
    path: 'shareholder',
    component: ShareholderDashboardComponent,
    canActivate: [AuthGuard, ShareholderGuard]
  },

  // Common dashboard (redirects based on role)
  {
    path: 'dashboard',
    canActivate: [AuthGuard],
    component: AdminDashboardComponent // This will be dynamic based on role
  },
  {
    path: 'agent',
    component: AgentDashboardComponent,
    canActivate: [AuthGuard, AgentGuard]
  },



  
  { path: 'side', component: SideBarComponent, canActivate: [AuthGuard] },
  { path: '**', redirectTo: '/login' }
];