import { Component, EventEmitter, Output, Input, OnInit, OnDestroy, HostListener } from '@angular/core';
import { Subscription } from 'rxjs';
import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';
import { CommonModule } from '@angular/common';


@Component({
  selector: 'app-side-bar',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './side-bar.component.html',
  styleUrls: ['./side-bar.component.css']
})
export class SideBarComponent implements OnInit, OnDestroy {
  @Input() collapsed = false;
  @Output() submenuSelected = new EventEmitter<
    | 'dashboard'
    | 'all-users' | 'add-user' | 'deleted-users'
    | 'all-members' | 'add-member'
    | 'all-agents' | 'add-agent'
    | 'all-products' | 'add-product'
    | 'all-installments' | 'add-installment'
    | 'payment-schedules' | 'record-payment'
    | 'all-shareholders' | 'add-shareholder'
  >();

  sidebarOpen = false;
  activeSubmenu: number | null = null;
  private mobileSubscription?: Subscription;
  private collapseSubscription?: Subscription;

  constructor(private sidebarService: SidebarTopbarService) { }

  ngOnInit() {
    this.mobileSubscription = this.sidebarService.isMobileOpen$.subscribe(state => {
      this.sidebarOpen = state;
      document.body.classList.toggle('sidebar-open', state);
    });

    this.collapseSubscription = this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.collapsed = collapsed;
    });
  }

  ngOnDestroy() {
    this.mobileSubscription?.unsubscribe();
    this.collapseSubscription?.unsubscribe();
  }

  toggleSidebar() {
    this.sidebarService.toggleMobileSidebar();
  }

  closeSidebar() {
    this.sidebarService.closeMobileSidebar();
  }

  toggleSubmenu(event: Event, index: number) {
    event.preventDefault();
    event.stopPropagation();
    this.activeSubmenu = this.activeSubmenu === index ? null : index;
  }

  handleSubmenuClick(
    event: Event,
    view?:
      | 'dashboard'
      | 'all-users' | 'add-user' | 'deleted-users'
      | 'all-members' | 'add-member'
      | 'all-agents' | 'add-agent'
      | 'all-products' | 'add-product'
      | 'all-installments' | 'add-installment'
      | 'payment-schedules' | 'record-payment'
      | 'all-shareholders' | 'add-shareholder'
  ) {
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