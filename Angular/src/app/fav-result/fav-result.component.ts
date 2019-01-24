import { Component, OnInit } from '@angular/core';
import {DataService} from '../data.service';
import {FormControl, FormGroup} from '@angular/forms';
import {animate, query, stagger, style, transition, trigger} from '@angular/animations';
@Component({
  selector: 'app-fav-result',
  templateUrl: './fav-result.component.html',
  styleUrls: ['./fav-result.component.css'],
  animations: [
    trigger('listAnimation', [
      transition(':enter, * => 0, * => -1', []),
      transition(':increment', [
        query(':enter', [
          style({opacity: 0, height: '0px'}),
          stagger(0, [
            animate('300ms ease', style({opacity: 1, height: '*'})),
          ]),
        ], {optional: true})
      ]),
      transition(':decrement', [
        query(':leave', [
          stagger(0, [
            animate('200ms', style({opacity: 0, height: '0px'})),
          ]),
        ], {optional: true})
      ]),
    ]),

    trigger('slideInOut', [
      transition(':enter', [
        style({transform: 'translateX(-20%)'}),
        animate('400ms ease-in', style({transform: 'translateX(0%)'}))
      ])
    ]),
    trigger('slideInOut3', [
      transition(':enter', [
        style({transform: 'translateX(20%)'}),
        animate('400ms ease-in', style({transform: 'translateX(0%)'}))
      ])
    ])
  ]
})
export class FavResultComponent implements OnInit {

  serverURL = 'http://csci571-hw8-event.appspot.com/';
  errorHappened: boolean;     // if a network error


  progressStatus: boolean;

  mobile: boolean;

  eventDetailID: String;
  eventJSON: String;            // for the detail table's bookmark function



  twitterText: String;
  eventDetail: Object;          // for the detail table  event tab


  artistNameList: String;       // for the detail of artist/teams 's names
  musicArtistArray = [];        // for the detail table  artist tab
  attractPlayers: Object[];    // for the detail table team tab

  venueDetail: Object;          // for the detail table  venue tab
  venueLat: Number;
  venuelng: Number;

  upcomings: [Object];          // for the detail table  upcoming tab
  upcomingsCopy: [Object];      // for the detail table


  numberToShow: number;
  showMoreLessBtnText: String;

  detailViewPristine: boolean;
  displayDetailView: boolean;           // detail view or not

  sortOptions = new FormGroup({
    byWhat: new FormControl('default'),
    orderDirection: new FormControl({value: 'ascending', disabled: true})
  });

  private eventData = this.getData();
  getLocalStorageSize() {
    return localStorage.length;
  }

  getData() {
    const result = [];
    for ( let i = 0; i < localStorage.length; i++ ) {
      const obj =  localStorage.getItem(localStorage.key(i));
      result.push(JSON.parse(obj));
    }

    // sort by date
    result.sort((a, b) => {
      const event1 = a.dates.start.localDate; // ignore upper and lowercase
      const event2 = b.dates.start.localDate; // ignore upper and lowercase
      if (event1 < event2) { return -1; }
      if (event1 > event2) { return 1; }
      return 0;
    });
    return result;
  }

  removeFav(id) {
    localStorage.removeItem(id);
    this.eventData = this.getData();
  }

  // sort for detail view's upcomings
  changeByWhat() {
    const bywhat = this.sortOptions.get('byWhat').value;
    const direction = this.sortOptions.get('orderDirection').value;


    if (bywhat === 'default') { // do nothing
      this.sortOptions.controls['orderDirection'].reset({value: 'ascending', disabled: true});
      this.upcomings = this.upcomingsCopy; // upcomingsCopy is pristine
    } else {
      this.sortOptions.controls['orderDirection'].enable();
      this.upcomings.sort((a, b) => {
        let event1 = '';
        let event2 = '';
        if (bywhat === 'event') {
          event1 = a['displayName']; // ignore upper and lowercase
          event2 = b['displayName']; // ignore upper and lowercase
        } else if (bywhat === 'time') {
          event1 = a['start'].date;
          event2 = b['start'].date;
        } else if (bywhat === 'artist') {
          event1 = a['performance'][0].displayName;
          event2 = b['performance'][0].displayName;
        } else {                      // must be type
          event1 = a['type'];
          event2 = b['type'];
        }

        if (direction === 'ascending') {
          if (event1 < event2) {
            return -1;
          }
          if (event1 > event2) {
            return 1;
          }
          return 0;
        } else {
          if (event1 > event2) {
            return -1;
          }
          if (event1 < event2) {
            return 1;
          }
          return 0;
        }
      });
    }
  }

  // show/less for detail view's upcomings
  showMore() {
    if (this.showMoreLessBtnText === 'Show More') { // show is less now
      this.numberToShow = this.upcomings.length;
      this.showMoreLessBtnText = 'Show Less';
    } else {
      this.numberToShow = 5;
      this.showMoreLessBtnText = 'Show More';
    }
  }

  getDetails(id, attractions, venue, event) {


    this.progressStatus = true;


    this.eventDetailID = id;
    this.eventJSON = event;

    // console.log('id is ' + id);
    // console.log('eventDetailID is' + this.eventDetailID);

    this.showDetails(true);

    this.detailViewPristine = false;   // touched

    if (attractions !== undefined) {
      this.artistNameList = attractions[0].name;
      if (attractions.length > 1) {
        for (let i = 1; i < attractions.length; i++) {
          this.artistNameList += (' | ' + attractions[i].name);
        }
      }
    }


    this.attractPlayers = []; // empty the players
    this.musicArtistArray = []; // empty the artists

    // 1. get even details
    this.data.getSearchResult(this.serverURL + 'event?eventID=' + id).subscribe(result => {


      this.eventDetail = result;
      this.twitterText = 'https://twitter.com/intent/tweet?text=' +
        'Check out ' + result['name'] + ' located at ' + result['_embedded'].venues[0].name +
        '. Website: ' + result['url'] + ' %23CSCI571EventSearch';

      if (venue[0].name === undefined) {
        console.log('no venue name');
        venue = result['_embedded'].venues;
      }

      // 2. get artist deails
      if (attractions !== undefined) {
        if (this.eventDetail['classifications'][0].segment.name === 'Music') {
          // console.log('music');
          // console.log('length: ' + attractions.length);
          //
          //   const musician = [Object];
          for (let i = 0; i < attractions.length; i++) {
            const artistName = attractions[i].name.toLowerCase();
            this.data.getSearchResult(this.serverURL + 'spotify?artist=' + artistName).subscribe(aresult1 => {
              if (aresult1['artists'] !== undefined) {
                const one = aresult1['artists'].items;
                for (let j = 0; j < one.length; j++) {
                  if (one[j].name.toLowerCase() === artistName) {
                    this.musicArtistArray.push(one[j]);
                    break;
                  }
                } // inner loop iterating all search results returned by the spotify
              }
              console.log('getting to spotify ');

              // console.log();
              // console.log(this.musicArtistArray);
              // console.log();
            }, () => {
              this.errorHappened = true;
              this.data.setProgressBar(false); // hide the progress bar anyway); // end of all requests
            });
          } // outer loop iterating all music artists
        }

        // no matter attraction's segment is music or not  still need to search the images
        for (let j = 0; j < attractions.length; j++) {
          const pName = attractions[j].name;
          this.data.getSearchResult(this.serverURL + 'img?player=' + pName).subscribe(player => {
            if (player['items'] !== undefined) {
              player['pname'] = pName;
              this.attractPlayers.push(player);
            }
          }, () => {
            this.errorHappened = true;
            this.data.setProgressBar(false); // hide the progress bar anyway); // end of all requests
          });

        }
      }

      // 3. get upcoming events
      this.data.getSearchResult(this.serverURL + 'upcoming?upcoming=' + venue[0].name).subscribe(upcoming => {


        if (upcoming['resultsPage'] !== undefined) {
          const list = upcoming['resultsPage'].results.event;
          // if returned event = defined, upcomings will become undefined again  (not 'undefined')
          this.upcomings = list;
          this.upcomingsCopy = list;

        }

        // 4. get venue details so ticketmaster api is not called consectively
        this.data.getSearchResult(this.serverURL + 'venue?vname=' + venue[0].name).subscribe(vresult => {

          if (vresult['_embedded'] !== undefined) {
            if (vresult['_embedded'].venues[0].location !== undefined) {
              this.venueLat = Number(vresult['_embedded'].venues[0].location.latitude);
              this.venuelng = Number(vresult['_embedded'].venues[0].location.longitude);
            }
            this.venueDetail = vresult;
          }
          // console.log('detail: ');
          // console.log(this.venueDetail);

          this.progressStatus = false;


        }, () => {
          this.errorHappened = true;
          this.data.setProgressBar(false); // hide the progress bar anyway); // end of all requests
        });

      }, () => {
        this.errorHappened = true;
        this.data.setProgressBar(false); // hide the progress bar anyway); // end of all requests
      });

      this.data.setProgressBar(false); // hide the progress bar
    }, () => {
      this.errorHappened = true;
      this.data.setProgressBar(false); // hide the progress bar anyway); // end of all requests
    });
  }

  showDetails(status: boolean) {
    this.displayDetailView = status;
  }

  constructor(private  data: DataService) { }

  ngOnInit() {
    if (window.screen.width < 500) {
      this.mobile = true;
    }
    this.errorHappened = false;


    this.progressStatus = false;

    this.getData();

    this.detailViewPristine = true; // not triggered yet
    this.displayDetailView = false;  // do not show the detail

    this.eventDetail = undefined;
    this.venueLat = -25.344;
    this.venuelng = 131.036;

    this.numberToShow = 5;        // upcoming default = 5
    this.showMoreLessBtnText = 'Show More';

    // for ( let i = 0; i < localStorage.length; i++ ) {
    //   const obj =  localStorage.getItem(localStorage.key(i));
    //   this.yyy.push(JSON.parse(obj));
    // }
  }

  bookmark(id, eventData) {
    const result = localStorage.getItem(id);
    if (result == null) {                 // not in the storage, add it
      localStorage.setItem(id, JSON.stringify(eventData));
    } else {                            // already in the storage, remove it
      localStorage.removeItem(id);
    }
  }

  checkLocalStraoge(id) {
    return localStorage.getItem(id);
  }

  // see if player and artist match
  findMusician(pname) {
    const p = pname.toLowerCase();
    for (let i = 0; i < this.musicArtistArray.length; i++) {
      if (this.musicArtistArray[i].name.toLowerCase() === p) {
        return true;
      }
    }
    return false;
  }

  getMusician(pname) {
    const result = [];
    const p = pname.toLowerCase();
    for (let i = 0; i < this.musicArtistArray.length; i++) {
      if (this.musicArtistArray[i].name.toLowerCase() === p) {
        result.push(this.musicArtistArray[i]);
        return result;
      }
    }
    return undefined;
  }


}
