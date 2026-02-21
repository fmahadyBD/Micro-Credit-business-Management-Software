import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { environment } from '../../environments/environment';

export interface RegistrationRequest {
  firstname: string;
  lastname: string;
  email: string;
  password: string;
}

export interface AuthenticationRequest {
  email: string;
  password: string;
}

export interface AuthenticationResponse {
  token: string;
}

interface JWTPayload {
  sub: string;
  authorities: string[];
  exp: number;
  iat: number;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = `${environment.apiUrl}/auth`;
  private readonly TOKEN_KEY = 'token';

  constructor(private http: HttpClient) { }

  register(request: RegistrationRequest): Observable<void> {
    return this.http.post<void>(`${this.apiUrl}/register`, request);
  }

  login(request: AuthenticationRequest): Observable<AuthenticationResponse> {
    return this.http.post<AuthenticationResponse>(`${this.apiUrl}/authenticate`, request)
      .pipe(
        tap(response => {
          // Clear storage first
          this.clearStorage();

          // Store ONLY the token - nothing else!
          localStorage.setItem(this.TOKEN_KEY, response.token);

          console.log('Token stored successfully');
        })
      );
  }

  logout(): void {
    this.clearStorage();
  }

  private clearStorage(): void {
    // Remove only the token
    localStorage.removeItem(this.TOKEN_KEY);
    // No user data to remove
  }

  private decodeToken(token: string): JWTPayload | null {
    try {
      const parts = token.split('.');
      if (parts.length !== 3) return null;

      const payload = parts[1];
      const base64 = payload.replace(/-/g, '+').replace(/_/g, '/');
      const decoded = atob(base64);
      return JSON.parse(decoded);
    } catch (e) {
      console.error('Error decoding token:', e);
      return null;
    }
  }

  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  getRole(): string | null {
    const token = this.getToken();
    if (!token) return null;

    const decoded = this.decodeToken(token);
    if (!decoded?.authorities?.length) return null;

    let role = decoded.authorities[0];
    if (role.startsWith('ROLE_')) {
      role = role.substring(5);
    }

    return role;
  }

  getUserEmail(): string | null {
    const token = this.getToken();
    if (!token) return null;

    const decoded = this.decodeToken(token);
    return decoded?.sub || null;
  }

  isLoggedIn(): boolean {
    const token = this.getToken();
    if (!token) return false;

    try {
      const decoded = this.decodeToken(token);
      if (!decoded) return false;

      const currentTime = Math.floor(Date.now() / 1000);
      if (decoded.exp < currentTime) {
        this.clearStorage();
        return false;
      }

      return true;
    } catch {
      return false;
    }
  }

  getUserId(): number | null {
    const token = this.getToken();
    if (!token) return null;

    const decoded = this.decodeToken(token);
    if (!decoded) return null;

    // 'sub' contains email; if you include userId in JWT claims, use that
    // Example: decoded.userId or decoded.id depending on backend token payload
    return (decoded as any).userId ?? null;
  }

  isAdmin(): boolean { return this.getRole() === 'ADMIN'; }
  isUser(): boolean { return this.getRole() === 'USER'; }
  isShareholder(): boolean { return this.getRole() === 'SHAREHOLDER'; }
  isAgent(): boolean { return this.getRole() === 'AGENT'; }
}