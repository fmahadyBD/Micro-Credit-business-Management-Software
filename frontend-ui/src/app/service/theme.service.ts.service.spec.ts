import { TestBed } from '@angular/core/testing';

import { ThemeServiceTsService } from './theme.service.ts.service';

describe('ThemeServiceTsService', () => {
  let service: ThemeServiceTsService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(ThemeServiceTsService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
