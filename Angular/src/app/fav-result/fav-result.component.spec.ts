import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { FavResultComponent } from './fav-result.component';

describe('FavResultComponent', () => {
  let component: FavResultComponent;
  let fixture: ComponentFixture<FavResultComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ FavResultComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(FavResultComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
