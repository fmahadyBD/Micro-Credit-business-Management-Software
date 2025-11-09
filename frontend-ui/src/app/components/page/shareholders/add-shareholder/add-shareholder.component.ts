import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ShareholdersService } from '../../../../services/services/shareholders.service';
import { ShareholderCreateDto } from '../../../../services/models/shareholder-create-dto';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-add-shareholder',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './add-shareholder.component.html',
  styleUrls: ['./add-shareholder.component.css']
})
export class AddShareholderComponent implements OnInit {
  shareholder: {
    name: string;
    phone?: string;
    email: string;
    nidCard?: string;
    nominee?: string;
    role?: string;
    status: 'Active' | 'Inactive';
    zila?: string;
    house?: string;
    joinDate?: string;
    investment?: number;
  } = {
      name: '',
      email: '',
      status: 'Active',
      investment: 0
    };

  loading: boolean = false;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  constructor(
    private shareholdersService: ShareholdersService,
    private sidebarService: SidebarTopbarService
  ) { }

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
  }

  createShareholder(): void {
    this.loading = true;
    this.error = null;
    this.successMessage = null;

    // Validate required fields
    if (!this.shareholder.name?.trim()) {
      this.error = 'Name is required';
      this.loading = false;
      return;
    }

    // Prepare the payload according to the actual ShareholderCreateDto
    const createPayload: ShareholderCreateDto = {
      name: this.shareholder.name.trim(),
      email: this.shareholder.email,
      phone: this.shareholder.phone || undefined,
      nidCard: this.shareholder.nidCard || undefined,
      nominee: this.shareholder.nominee || undefined,
      role: this.shareholder.role || undefined,
      status: this.shareholder.status,
      zila: this.shareholder.zila || undefined,
      house: this.shareholder.house || undefined,
      joinDate: this.shareholder.joinDate || undefined,
      investment: this.shareholder.investment || 0
    };

    console.log('Creating shareholder with payload:', createPayload);

    this.shareholdersService.createShareholder({ body: createPayload }).subscribe({
      next: (response) => {
        this.successMessage = 'Shareholder created successfully!';
        this.loading = false;

        // Reset form
        this.resetForm();

        // Redirect back after delay
        setTimeout(() => {
          window.dispatchEvent(new CustomEvent('backToAllShareholders'));
        }, 2000);
      },
      error: (err) => {
        console.error('Create error:', err);

        if (err.error && err.error.error) {
          this.error = `Server error: ${err.error.error}`;
        } else if (err.status === 400) {
          this.error = 'Validation error: Please check all fields are valid';
        } else {
          this.error = 'Failed to create shareholder. Please try again.';
        }

        this.loading = false;
      }
    });
  }

  onDateChange(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.shareholder.joinDate = input.value;
  }

  goBack(): void {
    window.dispatchEvent(new CustomEvent('backToAllShareholders'));
  }

  resetForm(): void {
    this.shareholder = {
      name: '',
      email: '',
      status: 'Active',
      investment: 0
    };
  }

  formatDate(date: string | undefined): string {
    if (!date) return '';
    return new Date(date).toISOString().split('T')[0];
  }
}