import { Component, HostListener } from '@angular/core';

@Component({
  selector: 'app-side-bar',
  templateUrl: './side-bar.component.html',
  styleUrls: ['./side-bar.component.css']
})
export class SideBarComponent {
  sidebarOpen = false;          // Mobile sidebar open/close
  activeSubmenu: number | null = null; // Currently open submenu index

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
  toggleSubmenu(event: Event, index: number) {
    event.preventDefault(); // Prevent page reload
    this.activeSubmenu = this.activeSubmenu === index ? null : index;
  }

  /** Handle submenu click */
  handleSubmenuClick(event: Event) {
    event.preventDefault(); // Prevent page reload
    this.closeSidebar();
  }

  /** Close sidebar if screen resized above mobile width */
  @HostListener('window:resize', ['$event'])
  onResize(event: any) {
    if (event.target.innerWidth > 768) {
      this.closeSidebar();
    }
  }
}
