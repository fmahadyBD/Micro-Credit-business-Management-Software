import { ComponentFixture, TestBed } from '@angular/core/testing';

import { EditShareholderComponent } from './edit-shareholder.component';

describe('EditShareholderComponent', () => {
  let component: EditShareholderComponent;
  let fixture: ComponentFixture<EditShareholderComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [EditShareholderComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(EditShareholderComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
