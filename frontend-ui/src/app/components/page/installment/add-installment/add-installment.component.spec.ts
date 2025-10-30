import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AddInstallmentComponent } from './add-installment.component';

describe('AddInstallmentComponent', () => {
  let component: AddInstallmentComponent;
  let fixture: ComponentFixture<AddInstallmentComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AddInstallmentComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AddInstallmentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
