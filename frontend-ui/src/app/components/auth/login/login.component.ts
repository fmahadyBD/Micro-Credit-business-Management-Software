import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AuthenticationRequest, AuthService } from '../../../service/auth.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  request: AuthenticationRequest = { email: '', password: '' };
  errorMessage = '';
  isLoading = false;
  constructor(private authService: AuthService, private router: Router) { }
  onSubmit() {
    this.isLoading = true;
    this.errorMessage = '';
    this.authService.login(this.request).subscribe({
      next: (response) => {
        this.isLoading = false;

        // Get the role from the response or from storage
        const role = this.authService.getRole();
        console.log('Login successful, user role:', role);

        // Redirect based on role
        this.redirectBasedOnRole(role);
      },
      error: (err) => {
        this.isLoading = false;
        console.error('Login error:', err);
        this.errorMessage = err.error?.message || 'Invalid email or password';
      }
    });
  }
  private redirectBasedOnRole(role: string | null): void {
    switch (role) {
      case 'ADMIN':
        this.router.navigate(['/admin']);
        break;
      case 'USER':
        this.router.navigate(['/user']);
        break;
      case 'SHAREHOLDER':
        this.router.navigate(['/shareholder']);
        break;
      default:
        console.error('Unknown role:', role);
        this.errorMessage = 'Unknown user role';
        this.authService.logout(); // Clear invalid data
    }
  }
}