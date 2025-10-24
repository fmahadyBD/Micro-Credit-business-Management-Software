import { TestBed } from '@angular/core/testing';

import { SidebarTopbarService } from './sidebar-topbar.service';

describe('SidebarTopbarService', () => {
  let service: SidebarTopbarService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(SidebarTopbarService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
