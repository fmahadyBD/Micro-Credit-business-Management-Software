import { Component, OnInit } from '@angular/core';
import { CommonModule, NgFor, NgClass } from '@angular/common';
import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';
import { ThemeService } from '../../../service/theme.service.ts.service';
import { AuthService } from '../../../service/auth.service';

interface Notification {
  icon: string[];
  title: string;
  time: string;
  unread: boolean;
}

@Component({
  selector: 'app-top-bar',
  standalone: true,
  imports: [CommonModule, NgFor, NgClass],
  templateUrl: './top-bar.component.html',
})
export class TopBarComponent implements OnInit {
  isSidebarCollapsed = false;
  userEmail: string | null = null;
  userRole: string | null = null;
  userInitial: string = 'U';

  notifications: Notification[] = [
    { icon: ['fas', 'fa-user'], title: 'New user registered', time: '2 minutes ago', unread: true },
    { icon: ['fas', 'fa-shopping-cart'], title: 'New order received', time: '15 minutes ago', unread: true },
    { icon: ['fas', 'fa-exclamation-circle'], title: 'Server alert', time: '1 hour ago', unread: true },
    { icon: ['fas', 'fa-credit-card'], title: 'Payment overdue', time: '2 hours ago', unread: true },
    { icon: ['fas', 'fa-chart-line'], title: 'Monthly report ready', time: '3 hours ago', unread: true },
  ];

  constructor(
    private sidebarService: SidebarTopbarService,
    private themeService: ThemeService,
    private authService: AuthService
  ) {}

  ngOnInit() {
    // Sidebar state listener
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });

    this.themeService.initSystemThemeListener();

    // ✅ Load logged-in user info
    this.userEmail = this.authService.getUserEmail();
    this.userRole = this.authService.getRole();
    this.userInitial = this.userEmail ? this.userEmail.charAt(0).toUpperCase() : 'U';
  }

  toggleSidebar() {
    this.sidebarService.toggleSidebar();
  }

  toggleMobileSidebar() {
    this.sidebarService.toggleMobileSidebar();
  }

  markAsRead(index: number, event: Event) {
    event.preventDefault();
    event.stopPropagation();
    this.notifications[index].unread = false;
  }

  markAllAsRead(event: Event) {
    event.preventDefault();
    event.stopPropagation();
    this.notifications.forEach(n => n.unread = false);
  }

  setTheme(theme: 'light' | 'dark' | 'auto', event?: Event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    this.themeService.setTheme(theme);
  }

  getUnreadCount(): number {
    return this.notifications.filter(n => n.unread).length;
  }

  logout(event: Event) {
    event.preventDefault();
    event.stopPropagation();
    this.authService.logout();
    window.location.href = '/login';
  }
}
