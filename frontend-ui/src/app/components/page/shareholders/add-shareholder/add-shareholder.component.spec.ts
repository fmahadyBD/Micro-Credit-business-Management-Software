import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AddShareholderComponent } from './add-shareholder.component';

describe('AddShareholderComponent', () => {
  let component: AddShareholderComponent;
  let fixture: ComponentFixture<AddShareholderComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AddShareholderComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AddShareholderComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
