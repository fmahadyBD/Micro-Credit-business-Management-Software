import { Component, OnInit, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ThemeService } from '../../../services/theme.service';
import { SidebarTopbarService } from '../../../services/sidebar-topbar.service';

interface Notification {
  icon: string[];
  title: string;
  time: string;
  unread: boolean;
}

@Component({
  selector: 'app-top-bar',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './top-bar.component.html',
  styleUrls: ['./top-bar.component.css']
})
export class TopBarComponent implements OnInit {
  @Output() sidebarToggle = new EventEmitter<void>();

  notifications: Notification[] = [
    { icon: ['fas', 'fa-user'], title: 'New user registered', time: '2 minutes ago', unread: true },
    { icon: ['fas', 'fa-shopping-cart'], title: 'New order received', time: '15 minutes ago', unread: true },
    { icon: ['fas', 'fa-exclamation-circle'], title: 'Server alert', time: '1 hour ago', unread: true },
    { icon: ['fas', 'fa-credit-card'], title: 'Payment overdue', time: '2 hours ago', unread: true },
    { icon: ['fas', 'fa-chart-line'], title: 'Monthly report ready', time: '3 hours ago', unread: true },
  ];

  isSidebarCollapsed = false;

  constructor(
    private themeService: ThemeService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit() {
    // Initialize system theme listener
    this.themeService.initSystemThemeListener();
  }

  /** Toggle the sidebar (mobile & desktop) */
  toggleSidebar() {
    this.isSidebarCollapsed = !this.isSidebarCollapsed;
    this.sidebarToggle.emit();

    // Toggle sidebar using the shared service
    this.sidebarService.toggleSidebar();
  }

  /** Mark one notification as read */
  markAsRead(index: number, event: Event) {
    event.preventDefault();
    event.stopPropagation();
    this.notifications[index].unread = false;
  }

  /** Mark all notifications as read */
  markAllAsRead(event: Event) {
    event.preventDefault();
    event.stopPropagation();
    this.notifications.forEach(n => n.unread = false);
  }

  /** Set application theme */
  setTheme(theme: 'light' | 'dark' | 'auto', event?: Event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    this.themeService.setTheme(theme);
  }

  /** Count unread notifications */
  getUnreadCount(): number {
    return this.notifications.filter(n => n.unread).length;
  }
}
