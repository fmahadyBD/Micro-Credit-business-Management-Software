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

  nidCardFile?: File;
  photoFile?: File;
  nomineeNidCardFile?: File;

  // Preview URLs for new uploaded images
  nidCardPreview?: string;
  photoPreview?: string;
  nomineeNidCardPreview?: string;

  loading: boolean = true;
  saving: boolean = false;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  private baseUrl = 'http://localhost:8080'; // Your backend URL

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

  onFileChange(event: any, type: 'nidCard' | 'photo' | 'nomineeNidCard') {
    const file: File = event.target.files[0];
    if (!file) return;

    // Store the file
    if (type === 'nidCard') {
      this.nidCardFile = file;
      this.createImagePreview(file, 'nidCard');
    } else if (type === 'photo') {
      this.photoFile = file;
      this.createImagePreview(file, 'photo');
    } else if (type === 'nomineeNidCard') {
      this.nomineeNidCardFile = file;
      this.createImagePreview(file, 'nomineeNidCard');
    }
  }

  createImagePreview(file: File, type: string): void {
    const reader = new FileReader();
    reader.onload = (e: any) => {
      if (type === 'nidCard') {
        this.nidCardPreview = e.target.result;
      } else if (type === 'photo') {
        this.photoPreview = e.target.result;
      } else if (type === 'nomineeNidCard') {
        this.nomineeNidCardPreview = e.target.result;
      }
    };
    reader.readAsDataURL(file);
  }

  getImageUrl(relativePath: string | undefined): string {
    if (!relativePath) return '';
    if (relativePath.startsWith('http')) return relativePath;
    const cleanPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return `${this.baseUrl}/${cleanPath}`;
  }

  onSubmit(): void {
    if (!this.member.id) {
      this.error = 'Member ID is missing';
      return;
    }

    this.saving = true;
    this.error = null;
    this.successMessage = null;

    // Prepare the member data (excluding image paths as they will be handled by backend)
    const memberData = {
      name: this.member.name,
      phone: this.member.phone,
      nidCardNumber: this.member.nidCardNumber,
      nomineeName: this.member.nomineeName,
      nomineePhone: this.member.nomineePhone,
      nomineeNidCardNumber: this.member.nomineeNidCardNumber,
      village: this.member.village,
      zila: this.member.zila,
      status: this.member.status
    };

    const params: any = {
      id: this.member.id,
      member: JSON.stringify(memberData),
      body: {}
    };

    // Only add files if they were actually selected
    if (this.nidCardFile) {
      params.body.nidCardImage = this.nidCardFile;
    }
    if (this.photoFile) {
      params.body.photo = this.photoFile;
    }
    if (this.nomineeNidCardFile) {
      params.body.nomineeNidCardImage = this.nomineeNidCardFile;
    }

    console.log('Updating member with params:', params);

    this.membersService.updateMemberWithImages(params).subscribe({
      next: (response) => {
        console.log('Update successful:', response);
        this.successMessage = 'Member updated successfully!';
        this.saving = false;
        
        // Clear file selections
        this.nidCardFile = undefined;
        this.photoFile = undefined;
        this.nomineeNidCardFile = undefined;
        this.nidCardPreview = undefined;
        this.photoPreview = undefined;
        this.nomineeNidCardPreview = undefined;

        setTimeout(() => {
          this.goBack();
        }, 1500);
      },
      error: (err) => {
        console.error('Error updating member:', err);
        this.error = err.error?.message || 'Failed to update member. Please try again.';
        this.saving = false;
      }
    });
  }

  goBack(): void {
    window.dispatchEvent(new CustomEvent('backToAllMembers'));
  }
}