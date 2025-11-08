import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AuthenticationRequest, AuthService } from '../../../service/auth.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';


@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html'
})
export class LoginComponent {
  request: AuthenticationRequest = { email: '', password: '' };
  errorMessage = '';

  constructor(private authService: AuthService, private router: Router) { }

  onSubmit() {
    this.authService.login(this.request).subscribe({
      next: () => this.router.navigate(['/dashboard']),
      error: (err) => {
        console.error(err);
        this.errorMessage = 'Invalid email or password';
      }
    });
  }
}
