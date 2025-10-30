import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MembersService } from '../../../../services/services/members.service';
import { Member } from '../../../../services/models/member';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-edit-member',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './edit-member.component.html',
  styleUrls: ['./edit-member.component.css']
})
export class EditMemberComponent implements OnInit {
  @Input() memberId!: number;
  
  member: Member = {
    name: '',
    phone: '',
    nidCardNumber: '',
    nomineeName: '',
    nomineePhone: '',
    nomineeNidCardNumber: '',
    village: '',
    zila: '',
    status: 'ACTIVE'
  };

  loading: boolean = true;
  saving: boolean = false;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  constructor(
    private membersService: MembersService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadMemberData();
  }

  loadMemberData(): void {
    this.loading = true;
    this.error = null;

    this.membersService.getMemberById({ id: this.memberId }).subscribe({
      next: (data: any) => {
        this.member = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load member data';
        this.loading = false;
        console.error('Error loading member:', err);
      }
    });
  }

  onSubmit(): void {
    this.saving = true;
    this.error = null;
    this.successMessage = null;

    this.membersService.updateMember({ 
      id: this.memberId, 
      body: this.member 
    }).subscribe({
      next: () => {
        this.successMessage = 'Member updated successfully!';
        this.saving = false;
        setTimeout(() => {
          this.goBack();
        }, 1500);
      },
      error: (err) => {
        this.error = 'Failed to update member. Please try again.';
        this.saving = false;
        console.error('Error updating member:', err);
      }
    });
  }

  goBack(): void {
    window.dispatchEvent(new CustomEvent('backToAllMembers'));
  }
}