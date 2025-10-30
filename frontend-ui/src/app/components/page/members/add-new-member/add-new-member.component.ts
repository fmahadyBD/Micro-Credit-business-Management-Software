import { Component, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, NgForm } from '@angular/forms';
import { MembersService } from '../../../../services/services/members.service';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { HttpErrorResponse } from '@angular/common/http';

@Component({
  selector: 'app-add-new-member',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './add-new-member.component.html',
  styleUrls: ['./add-new-member.component.css']
})
export class AddNewMemberComponent implements OnInit {
  @ViewChild('memberForm') memberForm!: NgForm;

  member: any = {
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

  // File upload properties
  nidCardImageFile: File | null = null;
  photoFile: File | null = null;
  nomineeNidCardImageFile: File | null = null;

  // Preview URLs
  nidCardImagePreview: string | null = null;
  photoPreview: string | null = null;
  nomineeNidCardImagePreview: string | null = null;

  saving: boolean = false;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  constructor(
    private membersService: MembersService,
    private sidebarService: SidebarTopbarService
  ) { }

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
  }

  onFileSelect(event: any, fileType: 'nidCard' | 'photo' | 'nomineeNidCard'): void {
    const file = event.target.files[0];
    if (file) {
      // Validate file type
      if (!file.type.startsWith('image/')) {
        this.error = 'Please select a valid image file';
        this.clearFileInput(event.target);
        return;
      }

      // Validate file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        this.error = 'File size should not exceed 5MB';
        this.clearFileInput(event.target);
        return;
      }

      // Store file and create preview
      const reader = new FileReader();
      reader.onload = (e: any) => {
        switch (fileType) {
          case 'nidCard':
            this.nidCardImageFile = file;
            this.nidCardImagePreview = e.target.result;
            break;
          case 'photo':
            this.photoFile = file;
            this.photoPreview = e.target.result;
            break;
          case 'nomineeNidCard':
            this.nomineeNidCardImageFile = file;
            this.nomineeNidCardImagePreview = e.target.result;
            break;
        }
        this.error = null;
      };
      reader.readAsDataURL(file);
    }
  }

  private clearFileInput(input: HTMLInputElement): void {
    input.value = '';
  }

  removeFile(fileType: 'nidCard' | 'photo' | 'nomineeNidCard'): void {
    switch (fileType) {
      case 'nidCard':
        this.nidCardImageFile = null;
        this.nidCardImagePreview = null;
        break;
      case 'photo':
        this.photoFile = null;
        this.photoPreview = null;
        break;
      case 'nomineeNidCard':
        this.nomineeNidCardImageFile = null;
        this.nomineeNidCardImagePreview = null;
        break;
    }
  }

  validateForm(): boolean {
    this.error = null;

    // Validate required fields
    const requiredFields = [
      { field: this.member.name, message: 'Member name is required' },
      { field: this.member.phone, message: 'Phone number is required' },
      { field: this.member.nidCardNumber, message: 'NID card number is required' },
      { field: this.member.nomineeName, message: 'Nominee name is required' },
      { field: this.member.nomineePhone, message: 'Nominee phone is required' },
      { field: this.member.nomineeNidCardNumber, message: 'Nominee NID card number is required' },
      { field: this.member.village, message: 'Village is required' },
      { field: this.member.zila, message: 'Zila is required' }
    ];

    for (const required of requiredFields) {
      if (!required.field || required.field.trim() === '') {
        this.error = required.message;
        return false;
      }
    }

    // Validate phone format
    const phoneRegex = /^[0-9]{10,15}$/;
    if (!phoneRegex.test(this.member.phone.replace(/\D/g, ''))) {
      this.error = 'Please enter a valid phone number (10-15 digits)';
      return false;
    }

    if (!phoneRegex.test(this.member.nomineePhone.replace(/\D/g, ''))) {
      this.error = 'Please enter a valid nominee phone number (10-15 digits)';
      return false;
    }

    // Validate required files
    if (!this.nidCardImageFile) {
      this.error = 'NID Card image is mandatory';
      return false;
    }
    if (!this.photoFile) {
      this.error = 'Member photo is mandatory';
      return false;
    }
    if (!this.nomineeNidCardImageFile) {
      this.error = 'Nominee NID Card image is mandatory';
      return false;
    }

    return true;
  }

  onSubmit(): void {
    if (!this.validateForm()) {
      return;
    }

    this.saving = true;
    this.error = null;
    this.successMessage = null;

    // Prepare the form data
    const formData = new FormData();
    formData.append('member', JSON.stringify(this.member));
    
    if (this.nidCardImageFile) {
      formData.append('nidCardImage', this.nidCardImageFile);
    }
    if (this.photoFile) {
      formData.append('photo', this.photoFile);
    }
    if (this.nomineeNidCardImageFile) {
      formData.append('nomineeNidCardImage', this.nomineeNidCardImageFile);
    }

    // Use the generated service method
    this.membersService.createMemberWithImages({
      member: JSON.stringify(this.member),
      body: {
        nidCardImage: this.nidCardImageFile!,
        photo: this.photoFile!,
        nomineeNidCardImage: this.nomineeNidCardImageFile!
      }
    }).subscribe({
      next: (response) => {
        this.successMessage = 'Member created successfully!';
        this.saving = false;
        this.resetForm();
      },
      error: (error: HttpErrorResponse) => {
        console.error('Error creating member:', error);
        
        if (error.error && error.error.message) {
          this.error = error.error.message;
        } else if (error.status === 0) {
          this.error = 'Unable to connect to server. Please check your connection.';
        } else if (error.status === 400) {
          this.error = 'Invalid data provided. Please check all fields.';
        } else if (error.status === 500) {
          this.error = 'Server error. Please try again later.';
        } else {
          this.error = 'Failed to create member. Please try again.';
        }
        
        this.saving = false;
      }
    });
  }

  resetForm(): void {
    // IMPORTANT: Reset the form properly
    if (this.memberForm) {
      this.memberForm.resetForm(); // This resets the form state including dirty/touched
    }

    // Reset member data
    this.member = {
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

    // Reset file uploads
    this.nidCardImageFile = null;
    this.photoFile = null;
    this.nomineeNidCardImageFile = null;
    this.nidCardImagePreview = null;
    this.photoPreview = null;
    this.nomineeNidCardImagePreview = null;
    
    // Clear messages
    this.error = null;
    this.successMessage = null;
  }

  formatPhoneNumber(phone: string): string {
    return phone.replace(/\D/g, '');
  }

  onPhoneInput(field: 'phone' | 'nomineePhone'): void {
    this.member[field] = this.formatPhoneNumber(this.member[field]);
  }
}