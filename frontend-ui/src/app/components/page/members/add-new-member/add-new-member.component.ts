import { Component, OnInit } from '@angular/core';
import { CommonModule, NgIf, NgFor, NgClass } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Member } from '../../../../services/models';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { MembersService } from '../../../../services/services/members.service';


@Component({
  selector: 'app-add-new-member',
  standalone: true,
  imports: [CommonModule, FormsModule, NgIf, NgClass],
  templateUrl: './add-new-member.component.html',
  styleUrls: ['./add-new-member.component.css']
})
export class AddNewMemberComponent implements OnInit {
  member: Member = {
    name: '',
    phone: '',
    zila: '',
    village: '',
    nidCard: '',
    photo: '',
    nominee: ''
  };

  message: { type: string; text: string } | null = null;
  submitting = false;
  isSidebarCollapsed = false;

  constructor(
    private sidebarService: SidebarTopbarService,
    private membersService: MembersService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(c => (this.isSidebarCollapsed = c));
  }

  submitMember() {
    if (!this.member.name || !this.member.phone) {
      this.message = { type: 'error', text: 'Name and phone are required!' };
      return;
    }

    this.submitting = true;

    this.membersService.createMember({ body: this.member }).subscribe({
      next: res => {
        console.log('Member created:', res);
        this.message = { type: 'success', text: 'Member created successfully!' };
        this.resetForm();
      },
      error: err => {
        console.error('Error:', err);
        this.message = {
          type: 'error',
          text: 'Failed to create member. ' + (err.error?.message || 'Unknown error')
        };
        this.submitting = false;
      }
    });
  }

  private resetForm() {
    this.member = {
      name: '',
      phone: '',
      zila: '',
      village: '',
      nidCard: '',
      photo: '',
      nominee: ''
    };
    this.submitting = false;
    setTimeout(() => (this.message = null), 3000);
  }
}
