import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SidebarService {
  private sidebarState = new BehaviorSubject<boolean>(false);
  public sidebarState$ = this.sidebarState.asObservable();

  toggleSidebar() {
    this.sidebarState.next(!this.sidebarState.value);
  }

  closeSidebar() {
    this.sidebarState.next(false);
  }

  openSidebar() {
    this.sidebarState.next(true);
  }

  getSidebarState(): boolean {
    return this.sidebarState.value;
  }
}