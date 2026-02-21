import { TestBed } from '@angular/core/testing';
import { CanActivateFn } from '@angular/router';

import { shareholderGuard } from './shareholder.guard';

describe('shareholderGuard', () => {
  const executeGuard: CanActivateFn = (...guardParameters) => 
      TestBed.runInInjectionContext(() => shareholderGuard(...guardParameters));

  beforeEach(() => {
    TestBed.configureTestingModule({});
  });

  it('should be created', () => {
    expect(executeGuard).toBeTruthy();
  });
});
