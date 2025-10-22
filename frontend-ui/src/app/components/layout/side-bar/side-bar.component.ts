import { Component, HostListener, OnInit, OnDestroy, Input } from '@angular/core';
import { Subscription } from 'rxjs';
import { SidebarService } from '../../../services/sidebar.service';

@Component({
  selector: 'app-side-bar',
  templateUrl: './side-bar.component.html',
  styleUrls: ['./side-bar.component.css']
})
export class SideBarComponent implements OnInit, OnDestroy {
  @Input() collapsed = false;
  sidebarOpen = false;
  activeSubmenu: number | null = null;
  private sidebarSubscription?: Subscription;

  constructor(private sidebarService: SidebarService) {}

  ngOnInit() {
    // Subscribe to sidebar state changes from the service
    this.sidebarSubscription = this.sidebarService.sidebarState$.subscribe(state => {
      this.sidebarOpen = state;
      if (state) {
        document.body.classList.add('sidebar-open');
      } else {
        document.body.classList.remove('sidebar-open');
      }
    });
  }

  ngOnDestroy() {
    this.sidebarSubscription?.unsubscribe();
  }

  /** Toggle Sidebar (mobile) - used by internal close button */
  toggleSidebar() {
    this.sidebarService.toggleSidebar();
  }

  /** Close Sidebar */
  closeSidebar() {
    this.sidebarService.closeSidebar();
  }

  /** Toggle Submenu */
  toggleSubmenu(event: Event, index: number) {
    event.preventDefault();
    event.stopPropagation();
    this.activeSubmenu = this.activeSubmenu === index ? null : index;
  }

  /** Handle submenu click */
  handleSubmenuClick(event: Event) {
    event.preventDefault();
    event.stopPropagation();
    // Close sidebar on mobile when submenu item is clicked
    if (window.innerWidth < 768) {
      this.closeSidebar();
    }
  }

  /** Close sidebar if screen resized above mobile width */
  @HostListener('window:resize', ['$event'])
  onResize(event: any) {
    if (event.target.innerWidth >= 768 && this.sidebarOpen) {
      this.closeSidebar();
    }
  }

  /** Prevent event bubbling for sidebar clicks */
  @HostListener('click', ['$event'])
  onSidebarClick(event: Event) {
    event.stopPropagation();
  }
}