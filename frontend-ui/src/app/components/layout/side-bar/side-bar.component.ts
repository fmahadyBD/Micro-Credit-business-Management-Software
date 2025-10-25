import { Component, EventEmitter, Output, OnInit, OnDestroy, HostListener, Input } from '@angular/core';
import { Subscription } from 'rxjs';
import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-side-bar',
  templateUrl: './side-bar.component.html',
  styleUrls: ['./side-bar.component.css']
})
export class SideBarComponent implements OnInit, OnDestroy {
  @Input() collapsed = false;
  sidebarOpen = false;
  activeSubmenu: number | null = null;

  @Output() submenuSelected = new EventEmitter<'dashboard' | 'all-users'>();

  private mobileSubscription?: Subscription;
  private collapseSubscription?: Subscription;

  constructor(private sidebarService: SidebarTopbarService) {}

  ngOnInit() {
    this.mobileSubscription = this.sidebarService.isMobileOpen$.subscribe(state => {
      this.sidebarOpen = state;
      if (state) document.body.classList.add('sidebar-open');
      else document.body.classList.remove('sidebar-open');
    });

    this.collapseSubscription = this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.collapsed = collapsed;
    });
  }

  ngOnDestroy() {
    this.mobileSubscription?.unsubscribe();
    this.collapseSubscription?.unsubscribe();
  }

  toggleSidebar() { this.sidebarService.toggleMobileSidebar(); }
  closeSidebar() { this.sidebarService.closeMobileSidebar(); }

  toggleSubmenu(event: Event, index: number) {
    event.preventDefault();
    event.stopPropagation();
    this.activeSubmenu = this.activeSubmenu === index ? null : index;
  }

  handleSubmenuClick(event: Event, view?: 'dashboard' | 'all-users') {
    event.preventDefault();
    event.stopPropagation();
    if (view) this.submenuSelected.emit(view);
    if (window.innerWidth < 768) this.closeSidebar();
  }

  @HostListener('window:resize', ['$event'])
  onResize(event: any) {
    if (event.target.innerWidth >= 768 && this.sidebarOpen) this.closeSidebar();
  }

  @HostListener('click', ['$event'])
  onSidebarClick(event: Event) {
    event.stopPropagation();
  }
}
