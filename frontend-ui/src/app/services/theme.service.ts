import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ThemeService {
  private currentTheme: 'light' | 'dark' | 'auto' = 'light';

  constructor() {
    this.loadTheme();
  }

  private loadTheme() {
    const savedTheme = localStorage.getItem('theme') as 'light' | 'dark' | 'auto';
    if (savedTheme) {
      this.setTheme(savedTheme);
    } else {
      this.setTheme('auto');
    }
  }

  setTheme(theme: 'light' | 'dark' | 'auto') {
    this.currentTheme = theme;
    localStorage.setItem('theme', theme);

    let appliedTheme: 'light' | 'dark';

    if (theme === 'auto') {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      appliedTheme = prefersDark ? 'dark' : 'light';
    } else {
      appliedTheme = theme;
    }

    document.documentElement.setAttribute('data-bs-theme', appliedTheme);
  }

  getCurrentTheme(): 'light' | 'dark' | 'auto' {
    return this.currentTheme;
  }

  initSystemThemeListener() {
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      if (this.currentTheme === 'auto') {
        document.documentElement.setAttribute('data-bs-theme', e.matches ? 'dark' : 'light');
      }
    });
  }
}