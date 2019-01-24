import {Component, HostListener, OnInit} from '@angular/core';
import {DataService} from '../data.service';
import {FormControl, FormGroup} from '@angular/forms';
import {trigger, style, transition, animate, query, stagger} from '@angular/animations';
import {HttpClient} from '@angular/common/http';

@Component({
  selector: 'app-all-result',
  templateUrl: './all-result.component.html',
  styleUrls: ['./all-result.component.css'],
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

export class AllResultComponent implements OnInit {

  serverURL = 'http://csci571-hw8-event.appspot.com/';

  errorHappened: boolean;     // if a network error

  message: String;           //
  listData: Object;          // for the list table
  progressStatus: boolean;   // the progress bar display or not


  twitterText: String;
  eventDetailID: String;        // for the detail table's bookmark function
  eventJSON: String;            // for the detail table's bookmark function

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

  detailViewPristine: boolean;      // details trigged yet
  displayDetailView: boolean;           // detail view or not

  mobile: boolean;

  sortOptions = new FormGroup({
    byWhat: new FormControl('default'),
    orderDirection: new FormControl({value: 'ascending', disabled: true})
  });

  constructor(private  data: DataService, private http: HttpClient) {
  }


  ngOnInit() {

    if (window.screen.width < 500) {
      this.mobile = true;
    }


    this.errorHappened = false;

    this.detailViewPristine = true; // not triggered yet
    this.displayDetailView = false;

    this.eventDetail = undefined;
    this.venueLat = -25.344;
    this.venuelng = 131.036;

    this.numberToShow = 5;        // upcoming default = 5
    this.showMoreLessBtnText = 'Show More';

    this.data.currentMessage.subscribe(message => {
      this.message = message;
      // if (message === 'oknow') {
        this.eventDetail = undefined;
        this.artistNameList = '';
        this.musicArtistArray = [];
        this.venueDetail = undefined;
        this.upcomings = undefined;
        this.upcomingsCopy = undefined;

        this.displayDetailView = false;
        this.detailViewPristine = true; // detail tab disabled after every new search

      // }
    });

    this.data.currentObj.subscribe(data => {
      // console.log(data);
      this.listData = data;
    });

    this.data.progress.subscribe(message => this.progressStatus = message);
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

  // sort list view's result
  sortData(data) {
    data.sort((a, b) => {
      const event1 = a.dates.start.localDate; // ignore upper and lowercase
      const event2 = b.dates.start.localDate; // ignore upper and lowercase
      if (event1 < event2) {
        return -1;
      }
      if (event1 > event2) {
        return 1;
      }
      return 0;
    });

    return data;
  }

  showDetails(status: boolean) {
    this.displayDetailView = status;
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

  getDetails(id, attractions, venue, event) {


    this.data.setProgressBar(true);


    this.eventDetailID = id;
    this.eventJSON = event;

    this.showDetails(true);

    this.detailViewPristine = false; // detail is touched

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

      // console.log('getting event details');
      // console.log(result);
      this.eventDetail = result;

      this.twitterText = 'https://twitter.com/intent/tweet?text=' +
        'Check out ' + result['name'] + ' located at ' + result['_embedded'].venues[0].name +
        '. Website: ' + result['url'] + ' %23CSCI571EventSearch';

      // console.log('va is ........................');
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
            this.http.get(this.serverURL + 'spotify?artist=' + artistName).subscribe(aresult1 => {
              if (aresult1['artists'] !== undefined) {
                const one = aresult1['artists'].items;
                for (let j = 0; j < one.length; j++) {
                  if (one[j].name.toLowerCase() === artistName) {
                    this.musicArtistArray.push(one[j]);
                    break;
                  }
                } // inner loop iterating all search results returned by the spotify
              }
              // console.log();
              // console.log(this.musicArtistArray);
              // console.log();
              console.log('getting to spotify ');
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
            // console.log('getting images');
          }, () => {
            this.errorHappened = true;
            this.data.setProgressBar(false); // hide the progress bar anyway); // end of all requests
          });
        }
      }
      // 3. get upcoming events
      this.data.getSearchResult(this.serverURL + 'upcoming?upcoming=' + venue[0].name).subscribe(upcoming => {

        // console.log('getting upcomings');

        if (upcoming['resultsPage'] !== undefined) {
          const list = upcoming['resultsPage'].results.event;
          // if returned event = defined, upcomings will become undefined again  (not 'undefined')
          this.upcomings = list;
          this.upcomingsCopy = list;

        }

        // 4. get venue details so ticketmaster api is not called consectively
        this.data.getSearchResult(this.serverURL + 'venue?vname=' + venue[0].name).subscribe(vresult => {

          // console.log('getting venue details');


          if (vresult['_embedded'] !== undefined) {
            if (vresult['_embedded'].venues[0].location !== undefined) {
              this.venueLat = Number(vresult['_embedded'].venues[0].location.latitude);
              this.venuelng = Number(vresult['_embedded'].venues[0].location.longitude);
            }
            this.venueDetail = vresult;
          }
          // console.log('detail: ');
          // console.log(this.venueDetail);

          this.data.setProgressBar(false); // everything is done now hide the progress bar

        }, () => {
          this.errorHappened = true;
          this.data.setProgressBar(false); // hide the progress bar anyway); // end of all requests
        });


      }, () => {
        this.errorHappened = true;
        this.data.setProgressBar(false); // hide the progress bar anyway); // end of all requests
      });

    }, () => {
      this.errorHappened = true;
      this.data.setProgressBar(false); // hide the progress bar anyway); // end of all requests
    });

  }
}
