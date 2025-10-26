import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UpdateAgentComponent } from './update-agent.component';

describe('UpdateAgentComponent', () => {
  let component: UpdateAgentComponent;
  let fixture: ComponentFixture<UpdateAgentComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UpdateAgentComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(UpdateAgentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
