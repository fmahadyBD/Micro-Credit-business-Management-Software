import { Component, HostListener, OnInit, OnDestroy, Input } from '@angular/core';
import { Subscription } from 'rxjs';
import { SidebarTopbarService } from '../../../services/sidebar-topbar.service';

@Component({
  selector: 'app-side-bar',
  templateUrl: './side-bar.component.html',
  styleUrls: ['./side-bar.component.css']
})
export class SideBarComponent implements OnInit, OnDestroy {
  @Input() collapsed = false;
  sidebarOpen = false;
  activeSubmenu: number | null = null;
  private mobileSubscription?: Subscription;
  private collapseSubscription?: Subscription;

  constructor(private sidebarService: SidebarTopbarService) {}

  ngOnInit() {
    // Subscribe to mobile open/close state
    this.mobileSubscription = this.sidebarService.isMobileOpen$.subscribe(state => {
      this.sidebarOpen = state;
      if (state) {
        document.body.classList.add('sidebar-open');
      } else {
        document.body.classList.remove('sidebar-open');
      }
    });

    // Subscribe to desktop collapse state
    this.collapseSubscription = this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.collapsed = collapsed;
    });
  }

  ngOnDestroy() {
    this.mobileSubscription?.unsubscribe();
    this.collapseSubscription?.unsubscribe();
  }

  /** Toggle Sidebar (mobile) */
  toggleSidebar() {
    this.sidebarService.toggleMobileSidebar();
  }

  /** Close Sidebar (mobile) */
  closeSidebar() {
    this.sidebarService.closeMobileSidebar();
  }

  /** Toggle Desktop Sidebar */
  toggleDesktopSidebar() {
    this.sidebarService.toggleSidebar();
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

