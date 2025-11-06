import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ShareholdersService } from '../../../../services/services/shareholders.service';
import { ShareholderDto } from '../../../../services/models/shareholder-dto';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-all-shareholders',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './all-shareholders.component.html',
  styleUrls: ['./all-shareholders.component.css']
})
export class AllShareholdersComponent implements OnInit {
  shareholders: ShareholderDto[] = [];
  loading: boolean = true;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  constructor(
    private shareholdersService: ShareholdersService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadShareholders();
  }

  loadShareholders(): void {
    this.loading = true;
    this.error = null;

    this.shareholdersService.getAllShareholders().subscribe({
      next: (data) => {
        this.shareholders = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load shareholders';
        this.loading = false;
        console.error('Error loading shareholders:', err);
      }
    });
  }

  viewDetails(shareholderId: number): void {
    window.dispatchEvent(new CustomEvent('viewShareholderDetails', { detail: shareholderId }));
  }

  editShareholder(shareholderId: number): void {
    window.dispatchEvent(new CustomEvent('editShareholder', { detail: shareholderId }));
  }

  deleteShareholder(shareholderId: number): void {
    if (confirm('Are you sure you want to delete this shareholder?')) {
      this.shareholdersService.deleteShareholder({ id: shareholderId }).subscribe({
        next: () => {
          this.successMessage = 'Shareholder deleted successfully!';
          this.loadShareholders();
          setTimeout(() => {
            this.successMessage = null;
          }, 3000);
        },
        error: (err) => {
          this.error = 'Failed to delete shareholder';
          console.error('Error deleting shareholder:', err);
        }
      });
    }
  }

  addShareholder(): void {
    window.dispatchEvent(new CustomEvent('addShareholder'));
  }

  formatDate(date: string | undefined): string {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString();
  }

  formatCurrency(amount: number | undefined): string {
    if (!amount) return '৳0.00';
    return '৳' + amount.toLocaleString('en-BD', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }

  getStatusClass(status: string | undefined): string {
    switch (status) {
      case 'Active': return 'badge bg-success';
      case 'Inactive': return 'badge bg-secondary';
      default: return 'badge bg-secondary';
    }
  }

  getROIClass(roi: number | undefined): string {
    if (!roi) return 'text-muted';
    if (roi > 20) return 'text-success';
    if (roi > 10) return 'text-warning';
    return 'text-danger';
  }
}