import { Component } from '@angular/core';
import {DataService} from './data.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {

  favDisplay = false;

  someError: boolean;
  processing: boolean;

  // detailOrNot = false;

  showFavTable() {
    this.favDisplay = true;
  }

  showResultTable() {
    this.favDisplay = false;

  }

  constructor( private  data: DataService) {

    // progress bar
    this.data.progress.subscribe(message => {
      this.processing = message;
    });

    // // display detail or not
    // this.data.detail.subscribe(message => {
    //   this.detailOrNot = message;
    // });

    // display the list/detail table or not
    this.data.currentMessage.subscribe(message => {
      if (message === 'do_not_diplay_the_list_table') {
        this.favDisplay = false;
      }
    });

    this.data.errorMessage.subscribe( message => {
      this.someError = message;
    });

  }
}
