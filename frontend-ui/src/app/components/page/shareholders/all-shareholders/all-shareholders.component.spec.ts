import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AllShareholdersComponent } from './all-shareholders.component';

describe('AllShareholdersComponent', () => {
  let component: AllShareholdersComponent;
  let fixture: ComponentFixture<AllShareholdersComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AllShareholdersComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AllShareholdersComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
