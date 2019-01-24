import { Injectable } from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {BehaviorSubject} from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DataService {

  // display the list/detail table or not
  private messageSource = new BehaviorSubject<String>('default message');
  currentMessage = this.messageSource.asObservable();

  // display progress bar or not
  private ms = new BehaviorSubject<boolean>(false);
  progress = this.ms.asObservable();

  // error happens
  private errorHandling = new BehaviorSubject<boolean>(false);
  errorMessage = this.errorHandling.asObservable();

  // // display favorite or not
  // private detailList = new BehaviorSubject<boolean>(false);
  // detail = this.detailList.asObservable();

  // results returned by a search
  private objTest = new BehaviorSubject<Object>({'x': 'y'});
  currentObj = this.objTest.asObservable();

  setMessageFromForm(message: String) {
    this.messageSource.next(message);
  }

  setSearchResultObj(newResult: Object) {
    this.objTest.next(newResult);
  }

  setProgressBar(status: boolean) {
    this.ms.next(status);
  }

  changeError(status: boolean) {
    this.errorHandling.next(status);
  }

  // changeDetail(status: boolean) {
  //   this.detailList.next(status);
  // }





  constructor(private http: HttpClient) { }

  getSearchResult(url) {
    return this.http.get(url);
  }
}
