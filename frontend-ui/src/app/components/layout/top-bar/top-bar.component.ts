import { Component, OnInit, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SidebarService } from '../../../services/sidebar.service';
import { ThemeService } from '../../../services/theme.service';

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
    { icon: ['fas','fa-user'], title: 'New user registered', time: '2 minutes ago', unread: true },
    { icon: ['fas','fa-shopping-cart'], title: 'New order received', time: '15 minutes ago', unread: true },
    { icon: ['fas','fa-exclamation-circle'], title: 'Server alert', time: '1 hour ago', unread: true },
    { icon: ['fas','fa-credit-card'], title: 'Payment overdue', time: '2 hours ago', unread: true },
    { icon: ['fas','fa-chart-line'], title: 'Monthly report ready', time: '3 hours ago', unread: true },
  ];

  isSidebarCollapsed = false;

  constructor(
    private sidebarService: SidebarService,
    private themeService: ThemeService
  ) {}

  ngOnInit() {
    // Initialize theme system listener
    this.themeService.initSystemThemeListener();
  }

  toggleSidebar() {
    this.isSidebarCollapsed = !this.isSidebarCollapsed;
    this.sidebarToggle.emit();
    
    // Also toggle mobile sidebar if needed
    if (window.innerWidth < 768) {
      this.sidebarService.toggleSidebar();
    }
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