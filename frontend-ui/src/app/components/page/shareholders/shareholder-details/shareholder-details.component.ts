import { Component, OnInit, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ShareholdersService } from '../../../../services/services/shareholders.service';
import { ShareholderDetailsDto } from '../../../../services/models/shareholder-details-dto';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { Chart, registerables } from 'chart.js';
import { AuthService } from '../../../../service/auth.service';

// Register Chart.js components
Chart.register(...registerables);

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
  isAdmin: boolean = false;
  currentUserId: number | null = null;
  
  // Chart instances
  private investmentChart?: Chart;
  private earningsChart?: Chart;
  private monthlyChart?: Chart;

  constructor(
    private shareholdersService: ShareholdersService,
    private sidebarService: SidebarTopbarService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    
    // Check user role and set permissions
    this.isAdmin = this.authService.isAdmin();
    // this.currentUserId = 1; // Hey in hhere i needed assign the logged in share holder id
    this.currentUserId = this.authService.getUserId();


















    
    this.loadShareholderDetails();
  }

  loadShareholderDetails(): void {
    this.loading = true;
    this.error = null;
    
    // Determine which ID to use
    let idToUse = this.shareholderId;
    
    // If no ID provided via input and user is shareholder, use their own ID
    if (!idToUse && this.authService.isShareholder() && this.currentUserId) {
      idToUse = this.currentUserId;
    }
    
    if (!idToUse) {
      this.error = 'Unable to load shareholder details. No shareholder ID available.';
      this.loading = false;
      return;
    }
    
    this.shareholdersService.getShareholderDetails({ id: idToUse }).subscribe({
      next: (data) => {
        this.shareholderDetails = data;
        this.loading = false;
        
        // Create charts after data is loaded
        setTimeout(() => {
          this.createInvestmentOverviewChart();
          this.createEarningsBreakdownChart();
          this.createMonthlyPerformanceChart();
        }, 100);
      },
      error: (err) => {
        this.error = 'Failed to load shareholder details';
        this.loading = false;
        console.error('Error loading shareholder details:', err);
      }
    });
  }

  createInvestmentOverviewChart(): void {
    const canvas = document.getElementById('investmentChart') as HTMLCanvasElement;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Destroy existing chart if any
    if (this.investmentChart) {
      this.investmentChart.destroy();
    }

    const investment = this.shareholderDetails?.investment || 0;
    const earnings = this.shareholderDetails?.totalEarnings || 0;
    const balance = this.shareholderDetails?.currentBalance || 0;

    this.investmentChart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Investment', 'Earnings', 'Current Balance'],
        datasets: [{
          data: [investment, earnings, balance],
          backgroundColor: [
            'rgba(54, 162, 235, 0.8)',
            'rgba(75, 192, 192, 0.8)',
            'rgba(255, 206, 86, 0.8)'
          ],
          borderColor: [
            'rgba(54, 162, 235, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(255, 206, 86, 1)'
          ],
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              padding: 15,
              font: { size: 12 }
            }
          },
          title: {
            display: true,
            text: 'Financial Overview',
            font: { size: 16, weight: 'bold' }
          }
        }
      }
    });
  }

  createEarningsBreakdownChart(): void {
    const canvas = document.getElementById('earningsChart') as HTMLCanvasElement;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    if (this.earningsChart) {
      this.earningsChart.destroy();
    }

    const investment = this.shareholderDetails?.investment || 0;
    const earnings = this.shareholderDetails?.totalEarnings || 0;
    const totalValue = this.shareholderDetails?.totalValue || 0;

    this.earningsChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Investment', 'Total Earnings', 'Total Value'],
        datasets: [{
          label: 'Amount (৳)',
          data: [investment, earnings, totalValue],
          backgroundColor: [
            'rgba(54, 162, 235, 0.7)',
            'rgba(75, 192, 192, 0.7)',
            'rgba(255, 159, 64, 0.7)'
          ],
          borderColor: [
            'rgba(54, 162, 235, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(255, 159, 64, 1)'
          ],
          borderWidth: 2,
          borderRadius: 8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          title: {
            display: true,
            text: 'Investment vs Earnings',
            font: { size: 16, weight: 'bold' }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: (value) => '৳' + value.toLocaleString()
            }
          }
        }
      }
    });
  }

  createMonthlyPerformanceChart(): void {
    const canvas = document.getElementById('monthlyChart') as HTMLCanvasElement;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    if (this.monthlyChart) {
      this.monthlyChart.destroy();
    }

    const totalEarnings = this.shareholderDetails?.totalEarnings || 0;
    const joinDate = this.shareholderDetails?.activeSince;
    
    let monthsActive = 1;
    if (joinDate) {
      const join = new Date(joinDate);
      const now = new Date();
      monthsActive = Math.max(1, Math.floor((now.getTime() - join.getTime()) / (1000 * 60 * 60 * 24 * 30)));
    }

    const monthlyAvg = totalEarnings / monthsActive;
    
    // Generate sample monthly data (in real scenario, this would come from backend)
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const currentMonth = new Date().getMonth();
    const labels = [];
    const data = [];
    
    for (let i = 0; i < Math.min(6, monthsActive); i++) {
      const monthIndex = (currentMonth - i + 12) % 12;
      labels.unshift(months[monthIndex]);
      // Generate realistic-looking data
      data.unshift(monthlyAvg * (0.8 + Math.random() * 0.4));
    }

    this.monthlyChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: 'Monthly Earnings',
          data: data,
          borderColor: 'rgba(75, 192, 192, 1)',
          backgroundColor: 'rgba(75, 192, 192, 0.2)',
          borderWidth: 3,
          fill: true,
          tension: 0.4,
          pointRadius: 5,
          pointBackgroundColor: 'rgba(75, 192, 192, 1)',
          pointBorderColor: '#fff',
          pointBorderWidth: 2
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          title: {
            display: true,
            text: 'Monthly Performance Trend',
            font: { size: 16, weight: 'bold' }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: (value) => '৳' + value.toLocaleString()
            }
          }
        }
      }
    });
  }

  goBack(): void {
    window.dispatchEvent(new CustomEvent('backToAllShareholders'));
  }

  editShareholder(): void {
    if (this.shareholderDetails?.shareholder?.id) {
      window.dispatchEvent(new CustomEvent('editShareholder', { 
        detail: this.shareholderDetails.shareholder.id 
      }));
    }
  }

  /**
   * Check if edit button should be shown (only for admin users)
   */
  shouldShowEditButton(): boolean {
    return this.isAdmin && !!this.shareholderDetails?.shareholder?.id;
  }

  formatCurrency(amount: number | undefined): string {
    if (!amount) return '৳0.00';
    return '৳' + amount.toLocaleString('en-BD', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }

  formatDate(date: string | undefined): string {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  }

  getStatusClass(status: string | undefined): string {
    switch (status) {
      case 'Active': return 'badge bg-success';
      case 'Inactive': return 'badge bg-secondary';
      default: return 'badge bg-secondary';
    }
  }

  getROIClass(): string {
    const roi = this.shareholderDetails?.shareholder?.roi;
    if (roi && roi > 0) {
      return 'text-success';
    }
    return 'text-muted';
  }

  formatROI(): string {
    const roi = this.shareholderDetails?.shareholder?.roi;
    if (roi) {
      return roi.toFixed(2) + '%';
    }
    return '0%';
  }

  getMonthsActive(): number {
    const joinDate = this.shareholderDetails?.activeSince;
    if (!joinDate) return 0;
    
    const join = new Date(joinDate);
    const now = new Date();
    return Math.floor((now.getTime() - join.getTime()) / (1000 * 60 * 60 * 24 * 30));
  }

  getMonthlyAverage(): string {
    const totalEarnings = this.shareholderDetails?.totalEarnings || 0;
    const months = this.getMonthsActive();
    if (months === 0) return '৳0.00';
    
    const avg = totalEarnings / months;
    return this.formatCurrency(avg);
  }

  getProgressPercentage(): number {
    const investment = this.shareholderDetails?.investment || 0;
    const earnings = this.shareholderDetails?.totalEarnings || 0;
    if (investment === 0) return 0;
    
    return Math.min(100, (earnings / investment) * 100);
  }

  ngOnDestroy(): void {
    // Clean up charts
    if (this.investmentChart) {
      this.investmentChart.destroy();
    }
    if (this.earningsChart) {
      this.earningsChart.destroy();
    }
    if (this.monthlyChart) {
      this.monthlyChart.destroy();
    }
  }
}