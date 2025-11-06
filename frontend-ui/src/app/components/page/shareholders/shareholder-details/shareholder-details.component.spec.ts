import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ShareholderDetailsComponent } from './shareholder-details.component';

describe('ShareholderDetailsComponent', () => {
  let component: ShareholderDetailsComponent;
  let fixture: ComponentFixture<ShareholderDetailsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ShareholderDetailsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ShareholderDetailsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
