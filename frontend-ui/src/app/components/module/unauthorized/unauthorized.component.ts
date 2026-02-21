// unauthorized.component.ts
import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../../service/auth.service';


@Component({
  selector: 'app-unauthorized',
  template: `
    <div class="container mt-5">
      <div class="row justify-content-center">
        <div class="col-md-6 text-center">
          <h1>401 - Unauthorized</h1>
          <p>You don't have permission to access this page.</p>
          <button class="btn btn-primary" (click)="goBack()">Go Back</button>
          <button class="btn btn-secondary ms-2" (click)="logout()">Logout</button>
        </div>
      </div>
    </div>
  `
})
export class UnauthorizedComponent {
  
  constructor(private router: Router, private authService: AuthService) {}

  goBack() {
    window.history.back();
  }

  logout() {
    this.authService.logout();
    this.router.navigate(['/login']);
  }
}