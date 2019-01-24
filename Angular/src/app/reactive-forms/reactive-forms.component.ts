import {Component, OnInit} from '@angular/core';
import {FormGroup, FormControl, Validators, AbstractControl, ValidationErrors, ValidatorFn} from '@angular/forms';
import {HttpClient} from '@angular/common/http';
import {DataService} from '../data.service';

@Component({
  selector: 'app-reactive-forms',
  templateUrl: './reactive-forms.component.html',
  styleUrls: ['./reactive-forms.component.css']
})
export class ReactiveFormsComponent implements OnInit {

  serverURL = 'http://csci571-hw8-event.appspot.com/';

  userLocation: any;
  // searchResult: Object;

  // message: String;
  // testObj: Object;

  options: string[] = [];


  searchForm = new FormGroup({

    keyword: new FormControl('', [this.ageRangeValidator]),
    category: new FormControl('all'),
    radius: new FormControl(''),
    unit: new FormControl('miles'),
    startLocation: new FormControl('here'),
    optionalLocation: new FormControl({value: '', disabled: true}, [this.ageRangeValidator]),
  });

  ageRangeValidator(control: AbstractControl): { [key: string]: boolean } | null {
    if (control.value.trim() === '') {
      return {'keyword with only space': true};
    }
    return null; // doesn't fail
  }

  useCurrentLocation() {
    this.searchForm.controls['optionalLocation'].reset({value: '', disabled: true});
  }

  useCustomizedLocation() {
    this.searchForm.controls['optionalLocation'].reset({value: '', disabled: false});
  }

  autocomplete() {
    const input = this.searchForm.get('keyword').value;
    this.data.getSearchResult(this.serverURL + 'suggest?input=' + input).subscribe(result => {

      this.data.changeError(false); // able to get the respond from the server

      if (result['_embedded'] !== undefined) {

        const attractions = result['_embedded'].attractions;
        const suggestion: string[] = [];
        for (let i = 0; i < attractions.length; i++) {
          suggestion.push(attractions[i].name);
        }
        this.options = suggestion;
      }

    }, error => {
      this.data.changeError(true); // cannot get the auto complete response from the server
    });
  }

  onSubmit() {
    const lat = this.userLocation.lat;
    const lng = this.userLocation.lon;

    const submitted = this.searchForm.value;
    const radius = (submitted.radius === '') ? 10 : submitted.radius;

    this.data.setProgressBar(true);

    this.data.getSearchResult(this.serverURL + 'search?keyword=' + submitted.keyword
      + '&category=' + submitted.category + '&radius=' + radius + '&unit=' + submitted.unit
      + '&lat=' + lat + '&lng=' + lng + '&optionalLocation=' + submitted.optionalLocation).subscribe(result => {


      this.data.changeError(false); // able to get the research response from the server

      this.data.setMessageFromForm('oknow');  // search is done
      this.data.setSearchResultObj(result);       // set the object
      this.data.setProgressBar(false); // stop the progress bar

    }, () => {
      this.data.changeError(true); // cannot get the research response from the server
      this.data.setProgressBar(false); // stop the progress bar anyway
    });

    this.data.setMessageFromForm('do_not_diplay_the_list_table');

  }

  reSet() {
    this.searchForm.controls['keyword'].patchValue('');
    this.searchForm.controls['category'].patchValue('all');
    this.searchForm.controls['radius'].patchValue('');
    this.searchForm.controls['unit'].patchValue('miles');
    this.searchForm.controls['startLocation'].patchValue('here');
    this.searchForm.controls['optionalLocation'].patchValue('');
    this.searchForm.controls['optionalLocation'].disable();

    this.searchForm.markAsUntouched();
    this.searchForm.markAsPristine();

    this.data.setMessageFromForm('do_not_diplay_the_list_table');

  }

  constructor(private http: HttpClient, private  data: DataService) {
  }

  ngOnInit() {

    /* get user location */
    this.http.get('http://ip-api.com/json').subscribe( (data) => {
      this.userLocation = data;
    });

  }

}
