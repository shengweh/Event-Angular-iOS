import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';

import { AppComponent } from './app.component';
import { FavResultComponent } from './fav-result/fav-result.component';

import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MaterialModule } from './material';

import { MatAutocompleteModule, MatFormFieldModule, MatInputModule, MatSelectModule } from '@angular/material';
import { ReactiveFormsComponent } from './reactive-forms/reactive-forms.component';

import { RoundProgressModule } from 'angular-svg-round-progressbar';
import { AllResultComponent } from './all-result/all-result.component';

import { AgmCoreModule } from '@agm/core';

@NgModule({
  declarations: [
    AppComponent,
    FavResultComponent,
    ReactiveFormsComponent,
    AllResultComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    ReactiveFormsModule,
    HttpClientModule,
    BrowserAnimationsModule,
    MaterialModule,
    MatAutocompleteModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    RoundProgressModule,
    AgmCoreModule.forRoot({
      apiKey : 'AIzaSyCrR62j9J347qEdTzxQvVkUNBsGjr2Mbfc'
    })
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
