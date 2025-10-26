import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DetailsAgentComponent } from './details-agent.component';

describe('DetailsAgentComponent', () => {
  let component: DetailsAgentComponent;
  let fixture: ComponentFixture<DetailsAgentComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DetailsAgentComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(DetailsAgentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
