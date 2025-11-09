import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ShareholderDashboardComponent } from './shareholder-dashboard.component';

describe('ShareholderDashboardComponent', () => {
  let component: ShareholderDashboardComponent;
  let fixture: ComponentFixture<ShareholderDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ShareholderDashboardComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ShareholderDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
