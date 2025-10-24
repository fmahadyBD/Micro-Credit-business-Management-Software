import { HttpClientModule } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { UsersService } from '../../../services/services';

@Component({
  selector: 'app-all-users',
  standalone: true,
  imports: [HttpClientModule],
  templateUrl: './all-users.component.html',
  styleUrls: ['./all-users.component.css']
})
export class AllUsersComponent implements OnInit {


  ngOnInit(): void {
    // this.loadUsers();
  }

constructor(private userService: UsersService) {}





}
