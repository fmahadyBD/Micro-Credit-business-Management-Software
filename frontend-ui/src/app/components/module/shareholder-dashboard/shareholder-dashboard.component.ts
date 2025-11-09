import { Component, OnInit } from '@angular/core';
import { TopBarComponent } from '../../layout/top-bar/top-bar.component';
import { ShareholderDetailsDto } from '../../../services/models/shareholder-details-dto';
import { ShareholdersService } from '../../../services/services/shareholders.service';
import { AuthService } from '../../../service/auth.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-shareholder-dashboard',
  standalone: true,
  imports: [CommonModule, TopBarComponent],
  templateUrl: './shareholder-dashboard.component.html',
  styleUrls: ['./shareholder-dashboard.component.css']
})
export class ShareholderDashboardComponent implements OnInit {
  shareholderDetails: ShareholderDetailsDto | null = null;
  loading = false;
  error: string | null = null;

  constructor(
    private shareholdersService: ShareholdersService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.loadShareholderDetails();
  }

  loadShareholderDetails(): void {
    const email = this.authService.getUserEmail();
    if (!email) {
      this.error = 'Invalid session. Please log in again.';
      return;
    }

    this.loading = true;
    this.shareholdersService.getShareholderByEmail({ email }).subscribe({
      next: (shareholder) => {
        if (!shareholder?.id) {
          this.error = 'No shareholder found for this account.';
          this.loading = false;
          return;
        }

        this.shareholdersService.getShareholderDetails({ id: shareholder.id }).subscribe({
          next: (details) => {
            this.shareholderDetails = details;
            this.loading = false;
          },
          error: () => {
            this.error = 'Failed to load shareholder details.';
            this.loading = false;
          }
        });
      },
      error: () => {
        this.error = 'Failed to find shareholder by email.';
        this.loading = false;
      }
    });
  }

  // ---------- UTILITIES ----------
  formatCurrency(amount: number | null | undefined): string {
    return amount ? `৳${amount.toLocaleString()}` : '৳0';
  }

  formatDate(dateStr: string | null | undefined): string {
    if (!dateStr) return 'N/A';
    return new Date(dateStr).toLocaleDateString();
  }

  formatROI(): string {
    if (!this.shareholderDetails) return '0%';
    const earnings = this.shareholderDetails.totalEarnings ?? 0;
    const investment = this.shareholderDetails.investment ?? 0;
    if (investment <= 0) return '0%';
    const roi = (earnings / investment) * 100;
    return `${roi.toFixed(2)}%`;
  }

  getStatusClass(status?: string | null): string {
    if (!status) return 'badge bg-secondary';
    return status.toLowerCase() === 'active' ? 'badge bg-success' : 'badge bg-danger';
  }

  getProgressPercentage(): number {
    const earnings = this.shareholderDetails?.totalEarnings ?? 0;
    const totalValue = this.shareholderDetails?.totalValue ?? 0;
    if (totalValue === 0) return 0;
    const progress = (earnings / totalValue) * 100;
    return Math.min(progress, 100);
  }

  getMonthsActive(): number {
    if (!this.shareholderDetails?.activeSince) return 0;
    const start = new Date(this.shareholderDetails.activeSince);
    const now = new Date();
    return (now.getFullYear() - start.getFullYear()) * 12 + (now.getMonth() - start.getMonth());
  }

  getMonthlyAverage(): string {
    const months = this.getMonthsActive();
    if (!months || !this.shareholderDetails) return '৳0';
    const earnings = this.shareholderDetails.totalEarnings ?? 0;
    const avg = months > 0 ? earnings / months : 0;
    return `৳${avg.toFixed(2)}`;
  }

  goBack(): void {
    window.history.back();
  }
}