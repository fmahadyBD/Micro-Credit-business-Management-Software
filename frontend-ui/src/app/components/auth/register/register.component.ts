import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService, RegistrationRequest } from '../../../service/auth.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';


@Component({
  selector: 'app-register',
    standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './register.component.html'
})
export class RegisterComponent {
  request: RegistrationRequest = {
    firstname: '',
    lastname: '',
    email: '',
    password: ''
  };

  successMessage = '';
  errorMessage = '';

  constructor(private authService: AuthService, private router: Router) {}

  onSubmit() {
    this.authService.register(this.request).subscribe({
      next: () => {
        this.successMessage = 'Registration successful! You can now login.';
        setTimeout(() => this.router.navigate(['/login']), 1500);
      },
      error: (err) => {
        console.error(err);
        this.errorMessage = err.error?.message || 'Registration failed';
      }
    });
  }
}
