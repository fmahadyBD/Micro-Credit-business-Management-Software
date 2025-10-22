import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class SidebarTopbarService {
  private collapsedSource = new BehaviorSubject<boolean>(false);
  isCollapsed$ = this.collapsedSource.asObservable();

  toggleSidebar() {
    this.collapsedSource.next(!this.collapsedSource.value);
  }

  setSidebarCollapsed(value: boolean) {
    this.collapsedSource.next(value);
  }

  getSidebarCollapsed(): boolean {
    return this.collapsedSource.value;
  }
}
