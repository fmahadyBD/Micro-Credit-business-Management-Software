import { Component, OnInit, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ShareholdersService } from '../../../../services/services/shareholders.service';
import { ShareholderDetailsDto } from '../../../../services/models/shareholder-details-dto';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-shareholder-details',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './shareholder-details.component.html',
  styleUrls: ['./shareholder-details.component.css']
})
export class ShareholderDetailsComponent implements OnInit {
  @Input() shareholderId!: number;
  
  shareholderDetails: ShareholderDetailsDto | null = null;
  loading: boolean = true;
  error: string | null = null;
  isSidebarCollapsed = false;

  constructor(
    private shareholdersService: ShareholdersService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadShareholderDetails();
  }

  loadShareholderDetails(): void {
    this.loading = true;
    this.error = null;

    this.shareholdersService.getShareholderDetails({ id: this.shareholderId }).subscribe({
      next: (data) => {
        this.shareholderDetails = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load shareholder details';
        this.loading = false;
        console.error('Error loading shareholder details:', err);
      }
    });
  }

  goBack(): void {
    window.dispatchEvent(new CustomEvent('backToAllShareholders'));
  }

  editShareholder(): void {
    window.dispatchEvent(new CustomEvent('editShareholder', { detail: this.shareholderId }));
  }

  formatCurrency(amount: number | undefined): string {
    if (!amount) return '৳0.00';
    return '৳' + amount.toLocaleString('en-BD', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }

  formatDate(date: string | undefined): string {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString();
  }

  getStatusClass(status: string | undefined): string {
    switch (status) {
      case 'Active': return 'badge bg-success';
      case 'Inactive': return 'badge bg-secondary';
      default: return 'badge bg-secondary';
    }
  }

  // Helper method to safely check ROI
  getROIClass(): string {
    const roi = this.shareholderDetails?.shareholder?.roi;
    if (roi && roi > 0) {
      return 'text-success';
    }
    return 'text-muted';
  }

  // Helper method to safely format ROI
  formatROI(): string {
    const roi = this.shareholderDetails?.shareholder?.roi;
    if (roi) {
      return roi.toFixed(2) + '%';
    }
    return '0%';
  }
}