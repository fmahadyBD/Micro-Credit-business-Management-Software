import { Component, HostListener } from '@angular/core';
import { NgFor, NgIf, NgClass } from '@angular/common';

interface MenuItem {
  title: string;
  icon: string;
  link?: string;
  submenu?: { title: string; link?: string }[];
}

@Component({
  selector: 'app-side-bar',
  standalone: true,
  imports: [NgFor, NgIf, NgClass],
  templateUrl: './side-bar.component.html',
  styleUrls: ['./side-bar.component.css']
})
export class SideBarComponent {
  sidebarOpen = false; // mobile sidebar open/close
  activeSubmenu: number | null = null; // which submenu is open

  // MENU ITEMS
  menu: MenuItem[] = [
    { title: 'Dashboard', icon: 'fa-home' },
    {
      title: 'Users', 
      icon: 'fa-users',
      submenu: [
        { title: 'All Users', link: '#' },
        { title: 'Add New', link: '#' },
        { title: 'Roles', link: '#' }
      ]
    },
    {
      title: 'E-Commerce', 
      icon: 'fa-shopping-cart',
      submenu: [
        { title: 'Products', link: '#' },
        { title: 'Orders', link: '#' },
        { title: 'Customers', link: '#' }
      ]
    },
    { title: 'Analytics', icon: 'fa-chart-line', link: '#' },
    { title: 'Messages', icon: 'fa-envelope', link: '#' },
    {
      title: 'Installment', 
      icon: 'fa-credit-card',
      submenu: [
        { title: 'Payment Plans', link: '#' },
        { title: 'Active Installments', link: '#' },
        { title: 'Payment History', link: '#' },
        { title: 'Overdue Payments', link: '#' }
      ]
    },
    {
      title: 'Shareholders', 
      icon: 'fa-user-tie',
      submenu: [
        { title: 'All Shareholders', link: '#' },
        { title: 'Share Distribution', link: '#' },
        { title: 'Dividends', link: '#' },
        { title: 'Reports', link: '#' }
      ]
    },
    {
      title: 'Settings', 
      icon: 'fa-cog',
      submenu: [
        { title: 'General', link: '#' },
        { title: 'Security', link: '#' },
        { title: 'Notifications', link: '#' }
      ]
    },
    { title: 'Help & Support', icon: 'fa-question-circle', link: '#' }
  ];

  /** Toggle Sidebar (mobile) */
  toggleSidebar() {
    this.sidebarOpen = !this.sidebarOpen;
    if (this.sidebarOpen) {
      document.body.classList.add('sidebar-open');
    } else {
      document.body.classList.remove('sidebar-open');
    }
  }

  /** Close Sidebar */
  closeSidebar() {
    this.sidebarOpen = false;
    document.body.classList.remove('sidebar-open');
  }

  /** Toggle Submenu */
  toggleSubmenu(index: number) {
    this.activeSubmenu = this.activeSubmenu === index ? null : index;
  }

  /** Handle menu click - prevents page refresh */
  handleMenuClick(event: Event, item: MenuItem, index: number) {
    if (item.submenu) {
      event.preventDefault(); // Prevent default link behavior
      this.toggleSubmenu(index);
    } else {
      event.preventDefault(); // Prevent default link behavior
      this.closeSidebar();
      // If you're using Angular Router, navigate programmatically here
      // this.router.navigate([item.link]);
    }
  }

  /** Handle submenu link click */
  handleSubmenuClick(event: Event) {
    event.preventDefault(); // Prevent default link behavior
    this.closeSidebar();
    // If you're using Angular Router, navigate programmatically here
    // this.router.navigate([link]);
  }

  /** Close sidebar automatically if screen resized above mobile width */
  @HostListener('window:resize', ['$event'])
  onResize(event: any) {
    if (event.target.innerWidth > 768) {
      this.closeSidebar();
    }
  }
}