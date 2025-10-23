import { Component, OnInit } from '@angular/core';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { getAllUsers } from '../../../services/functions';
import { User } from '../../../services/models/user';
import { ApiConfiguration } from '../../../services/api-configuration';
import { NgFor, NgIf } from '@angular/common';
import { map } from 'rxjs';

@Component({
  selector: 'app-all-users',
  standalone: true,
  imports: [HttpClientModule, NgIf, NgFor],
  templateUrl: './all-users.component.html',
  styleUrls: ['./all-users.component.css']
})
export class AllUsersComponent implements OnInit {

  users: User[] = [];

  constructor(
    private http: HttpClient,
    private apiConfig: ApiConfiguration
  ) {}

  ngOnInit(): void {
    // Call the generated API function
    getAllUsers(this.http, this.apiConfig.rootUrl).pipe(
      // Extract the actual array from StrictHttpResponse.body
      map(res => res.body ?? [])
    ).subscribe({
      next: (users: User[]) => {
        this.users = users;
        console.log(this.users); // should log the array of users
      },
      error: (err) => console.error(err)
    });
  }
}
