import { TestBed } from '@angular/core/testing';

import { ExtendedShareholdersService } from './extended-shareholders.service';

describe('ExtendedShareholdersService', () => {
  let service: ExtendedShareholdersService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(ExtendedShareholdersService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
