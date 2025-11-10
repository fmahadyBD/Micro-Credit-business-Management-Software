// src/app/services/extended-shareholders.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiConfiguration } from '../services/api-configuration';
import { ShareholdersService } from '../services/services/shareholders.service';
import { ShareholderDto } from '../services/models/shareholder-dto';


@Injectable({
  providedIn: 'root'
})
export class ExtendedShareholdersService extends ShareholdersService {
  
  constructor(
    config: ApiConfiguration,
    http: HttpClient,
    private httpClient: HttpClient
  ) {
    super(config, http);
  }

  /**
   * Get shareholder by user ID
   * This method is not in the OpenAPI spec but exists in the backend
   */
  // getShareholderByUserId(userId: number): Observable<ShareholderDto> {
  //   const url = `${this.rootUrl}/api/shareholders/by-user/${userId}`;
  //   return this.httpClient.get<ShareholderDto>(url);
  // }
}