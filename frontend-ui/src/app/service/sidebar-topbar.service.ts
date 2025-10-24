import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class SidebarTopbarService {
  private collapsedSource = new BehaviorSubject<boolean>(false);
  private mobileOpenSource = new BehaviorSubject<boolean>(false);
  
  isCollapsed$ = this.collapsedSource.asObservable();
  isMobileOpen$ = this.mobileOpenSource.asObservable();

  // Desktop toggle
  toggleSidebar() {
    this.collapsedSource.next(!this.collapsedSource.value);
  }

  // Mobile toggle
  toggleMobileSidebar() {
    this.mobileOpenSource.next(!this.mobileOpenSource.value);
  }

  closeMobileSidebar() {
    this.mobileOpenSource.next(false);
  }

  setSidebarCollapsed(value: boolean) {
    this.collapsedSource.next(value);
  }

  getSidebarCollapsed(): boolean {
    return this.collapsedSource.value;
  }

  getMobileOpen(): boolean {
    return this.mobileOpenSource.value;
  }
}