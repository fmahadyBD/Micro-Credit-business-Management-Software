import { ComponentFixture, TestBed } from '@angular/core/testing';

import { InstallmentManagementComponent } from './installment-management.component';

describe('InstallmentManagementComponent', () => {
  let component: InstallmentManagementComponent;
  let fixture: ComponentFixture<InstallmentManagementComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [InstallmentManagementComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(InstallmentManagementComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
