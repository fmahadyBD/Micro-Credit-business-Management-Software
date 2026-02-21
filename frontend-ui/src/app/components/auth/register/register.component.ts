import { Component, ElementRef, ViewChild } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService, RegistrationRequest } from '../../../service/auth.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { trigger, transition, style, animate, state, query, stagger } from '@angular/animations';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css'],
  animations: [
    // Card entrance animation
    trigger('cardAnimation', [
      transition(':enter', [
        style({ 
          opacity: 0, 
          transform: 'translateY(-30px) scale(0.95)' 
        }),
        animate('600ms cubic-bezier(0.35, 0, 0.25, 1)', 
          style({ opacity: 1, transform: 'translateY(0) scale(1)' }))
      ])
    ]),
    
    // Form field stagger animation
    trigger('fieldAnimation', [
      transition(':enter', [
        query('.form-group', [
          style({ opacity: 0, transform: 'translateX(-20px)' }),
          stagger(100, [
            animate('400ms cubic-bezier(0.35, 0, 0.25, 1)', 
              style({ opacity: 1, transform: 'translateX(0)' }))
          ])
        ])
      ])
    ]),
    
    // Button loading state
    trigger('buttonState', [
      state('default', style({
        transform: 'scale(1)'
      })),
      state('loading', style({
        transform: 'scale(0.98)'
      })),
      transition('default <=> loading', [
        animate('200ms ease-in-out')
      ])
    ]),
    
    // Message animations
    trigger('messageAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(-10px)' }),
        animate('300ms ease-out', 
          style({ opacity: 1, transform: 'translateY(0)' }))
      ]),
      transition(':leave', [
        animate('200ms ease-in', 
          style({ opacity: 0, transform: 'translateY(-5px)' }))
      ])
    ]),
    
    // Input validation states
    trigger('inputState', [
      state('valid', style({
        borderColor: '#10b981',
        'box-shadow': '0 0 0 3px rgba(16, 185, 129, 0.1)'
      })),
      state('invalid', style({
        borderColor: '#ef4444',
        'box-shadow': '0 0 0 3px rgba(239, 68, 68, 0.1)'
      })),
      transition('* => valid', [
        animate('300ms ease-out')
      ]),
      transition('* => invalid', [
        animate('300ms ease-out')
      ])
    ])
  ]
})
export class RegisterComponent {
  @ViewChild('formRef') formRef: any;
  @ViewChild('firstnameInput') firstnameInput!: ElementRef;
  @ViewChild('lastnameInput') lastnameInput!: ElementRef;
  @ViewChild('emailInput') emailInput!: ElementRef;
  @ViewChild('passwordInput') passwordInput!: ElementRef;

  request: RegistrationRequest = {
    firstname: '',
    lastname: '',
    email: '',
    password: ''
  };

  successMessage = '';
  errorMessage = '';
  loading = false;
  submitted = false;

  // Track input states for animations
  inputStates: { [key: string]: string } = {
    firstname: '',
    lastname: '',
    email: '',
    password: ''
  };

  // Password strength
  passwordStrength = {
    value: 0,
    label: '',
    color: ''
  };

  constructor(private authService: AuthService, private router: Router) { }

  onSubmit() {
    this.submitted = true;
    
    if (!this.formRef.form.valid) {
      this.animateInvalidFields();
      return;
    }

    this.loading = true;
    this.successMessage = '';
    this.errorMessage = '';

    this.authService.register(this.request).subscribe({
      next: () => {
        this.loading = false;
        this.successMessage = 'Registration successful! Redirecting to login…';
        
        // Success animation delay before redirect
        setTimeout(() => {
          this.router.navigate(['/login']);
        }, 1800);
      },
      error: (err) => {
        this.loading = false;
        console.error(err);
        this.errorMessage = err.error?.message || 'Registration failed. Please try again';
        
        // Scroll to top with smooth animation
        window.scrollTo({ top: 0, behavior: 'smooth' });
        
        // Shake animation for error state
        this.shakeCard();
      }
    });
  }

  // Animate invalid fields
  private animateInvalidFields() {
    const invalidControls: string[] = [];
    
    if (!this.request.firstname) invalidControls.push('firstname');
    if (!this.request.lastname) invalidControls.push('lastname');
    if (!this.request.email) invalidControls.push('email');
    if (!this.request.password) invalidControls.push('password');

    invalidControls.forEach(control => {
      this.inputStates[control] = 'invalid';
      
      // Get the input element and trigger shake animation
      const inputElement = this.getInputElement(control);
      if (inputElement) {
        this.shakeInput(inputElement);
      }
    });

    // Reset states after animation
    setTimeout(() => {
      invalidControls.forEach(control => {
        this.inputStates[control] = '';
      });
    }, 600);
  }

  // Get input element by name
  private getInputElement(controlName: string): HTMLElement | null {
    switch (controlName) {
      case 'firstname': return this.firstnameInput?.nativeElement;
      case 'lastname': return this.lastnameInput?.nativeElement;
      case 'email': return this.emailInput?.nativeElement;
      case 'password': return this.passwordInput?.nativeElement;
      default: return null;
    }
  }

  // Shake animation for individual input
  private shakeInput(element: HTMLElement) {
    element.style.animation = 'shake 0.5s ease-in-out';
    setTimeout(() => {
      element.style.animation = '';
    }, 500);
  }

  // Shake animation for card on error
  private shakeCard() {
    const card = document.querySelector('.register-card');
    if (card) {
      (card as HTMLElement).style.animation = 'shake 0.6s ease-in-out';
      setTimeout(() => {
        (card as HTMLElement).style.animation = '';
      }, 600);
    }
  }

  // Update input state on blur
  onInputBlur(fieldName: string, value: string) {
    if (this.submitted || value) {
      if (this.isFieldValid(fieldName, value)) {
        this.inputStates[fieldName] = 'valid';
      } else {
        this.inputStates[fieldName] = 'invalid';
      }
    }
  }

  // Validate individual fields
  private isFieldValid(fieldName: string, value: string): boolean {
    switch (fieldName) {
      case 'email':
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
      case 'password':
        return value.length >= 6;
      case 'firstname':
      case 'lastname':
        return value.trim().length >= 2;
      default:
        return true;
    }
  }

  // Calculate password strength
  onPasswordInput() {
    const password = this.request.password;
    let strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.match(/[a-z]/) && password.match(/[A-Z]/)) strength++;
    if (password.match(/\d/)) strength++;
    if (password.match(/[^a-zA-Z\d]/)) strength++;
    
    this.passwordStrength.value = (strength / 4) * 100;
    
    if (strength <= 1) {
      this.passwordStrength.label = 'Weak';
      this.passwordStrength.color = '#ef4444';
    } else if (strength === 2) {
      this.passwordStrength.label = 'Fair';
      this.passwordStrength.color = '#f59e0b';
    } else if (strength === 3) {
      this.passwordStrength.label = 'Good';
      this.passwordStrength.color = '#10b981';
    } else {
      this.passwordStrength.label = 'Strong';
      this.passwordStrength.color = '#059669';
    }
  }

  // Get button state for animation
  get buttonState() {
    return this.loading ? 'loading' : 'default';
  }
}