import {MatButtonModule, MatCheckboxModule} from '@angular/material';
import {NgModule} from '@angular/core';
import {MatTooltipModule} from '@angular/material/tooltip';
// import {MatButtonModule} from '@angular/material/button';

@NgModule({
  imports: [MatButtonModule, MatCheckboxModule, MatTooltipModule],
  exports: [MatButtonModule, MatCheckboxModule, MatTooltipModule],
})
export class MaterialModule { }
