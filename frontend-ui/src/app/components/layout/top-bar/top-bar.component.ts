import { Component, OnInit } from '@angular/core';
import { SidebarTopbarService } from '../../../services/sidebar-topbar.service';
import { ThemeService } from '../../../services/theme.service';
import { CommonModule, NgFor, NgClass } from '@angular/common';

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

  notifications: Notification[] = [
    { icon: ['fas', 'fa-user'], title: 'New user registered', time: '2 minutes ago', unread: true },
    { icon: ['fas', 'fa-shopping-cart'], title: 'New order received', time: '15 minutes ago', unread: true },
    { icon: ['fas', 'fa-exclamation-circle'], title: 'Server alert', time: '1 hour ago', unread: true },
    { icon: ['fas', 'fa-credit-card'], title: 'Payment overdue', time: '2 hours ago', unread: true },
    { icon: ['fas', 'fa-chart-line'], title: 'Monthly report ready', time: '3 hours ago', unread: true },
  ];

  constructor(
    private sidebarService: SidebarTopbarService,
    private themeService: ThemeService
  ) {}

  ngOnInit() {
    this.sidebarService.isCollapsed$.subscribe(state => {
      this.isSidebarCollapsed = state;
    });
    this.themeService.initSystemThemeListener();
  }

  toggleSidebar() {
    this.sidebarService.toggleSidebar();
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
}