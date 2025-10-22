import { CommonModule } from '@angular/common';
import { AfterViewInit, Component, OnDestroy, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);

interface StatCard {
  title: string;
  value: string;
  change: string;
  trend: 'up' | 'down';
  icon: string;
  iconBg: string;
  iconColor: string;
}

interface InstallmentPayment {
  customer: string;
  plan: string;
  amount: string;
  paid: string;
  nextPayment: string;
  status: 'Active' | 'Paid' | 'Due';
}

interface Activity {
  user: string;
  initials: string;
  action: string;
  date: string;
  status: 'Completed' | 'Pending';
  gradient: string;
}

@Component({
  selector: 'app-admin-main',

  imports: [CommonModule, FormsModule],
  templateUrl: './admin-main.component.html',
  styleUrl: './admin-main.component.css'
})
export class AdminMainComponent implements OnInit, AfterViewInit, OnDestroy {
  // Stats Data
  stats: StatCard[] = [
    {
      title: 'Total Users',
      value: '12,458',
      change: '12% from last month',
      trend: 'up',
      icon: 'fas fa-users',
      iconBg: 'bg-primary bg-opacity-10',
      iconColor: 'text-primary'
    },
    {
      title: 'Revenue',
      value: '$48,597',
      change: '8% from last month',
      trend: 'up',
      icon: 'fas fa-dollar-sign',
      iconBg: 'bg-success bg-opacity-10',
      iconColor: 'text-success'
    },
    {
      title: 'Orders',
      value: '3,642',
      change: '3% from last month',
      trend: 'down',
      icon: 'fas fa-shopping-cart',
      iconBg: 'bg-warning bg-opacity-10',
      iconColor: 'text-warning'
    },
    {
      title: 'Growth',
      value: '23.5%',
      change: '5% from last month',
      trend: 'up',
      icon: 'fas fa-chart-line',
      iconBg: 'bg-info bg-opacity-10',
      iconColor: 'text-info'
    }
  ];

  // Installment Data
  installmentData: InstallmentPayment[] = [
    { customer: 'John Smith', plan: '12 Months', amount: '$12,000', paid: '$8,000', nextPayment: '2025-11-15', status: 'Active' },
    { customer: 'Sarah Johnson', plan: '24 Months', amount: '$24,000', paid: '$24,000', nextPayment: 'Completed', status: 'Paid' },
    { customer: 'Mike Brown', plan: '6 Months', amount: '$6,000', paid: '$3,000', nextPayment: '2025-10-22', status: 'Due' },
    { customer: 'Emily Davis', plan: '18 Months', amount: '$18,000', paid: '$10,000', nextPayment: '2025-11-05', status: 'Active' },
    { customer: 'David Wilson', plan: '12 Months', amount: '$12,000', paid: '$12,000', nextPayment: 'Completed', status: 'Paid' },
    { customer: 'Lisa Anderson', plan: '24 Months', amount: '$24,000', paid: '$6,000', nextPayment: '2025-10-18', status: 'Due' },
    { customer: 'James Taylor', plan: '12 Months', amount: '$12,000', paid: '$9,000', nextPayment: '2025-11-20', status: 'Active' },
    { customer: 'Maria Garcia', plan: '6 Months', amount: '$6,000', paid: '$4,000', nextPayment: '2025-10-30', status: 'Active' },
    { customer: 'Robert Martinez', plan: '18 Months', amount: '$18,000', paid: '$18,000', nextPayment: 'Completed', status: 'Paid' },
    { customer: 'Jennifer Lee', plan: '12 Months', amount: '$12,000', paid: '$5,000', nextPayment: '2025-10-25', status: 'Active' },
    { customer: 'William Moore', plan: '24 Months', amount: '$24,000', paid: '$8,000', nextPayment: '2025-11-10', status: 'Active' },
    { customer: 'Patricia White', plan: '6 Months', amount: '$6,000', paid: '$2,000', nextPayment: '2025-10-20', status: 'Due' }
  ];

  // Activity Data
  activityData: Activity[] = [
    { user: 'Alice Martin', initials: 'AM', action: 'Created new project', date: '2 hours ago', status: 'Completed', gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' },
    { user: 'Bob Smith', initials: 'BS', action: 'Updated user settings', date: '5 hours ago', status: 'Pending', gradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)' },
    { user: 'Carol Johnson', initials: 'CJ', action: 'Deleted old files', date: '1 day ago', status: 'Completed', gradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)' },
    { user: 'David Lee', initials: 'DL', action: 'Generated monthly report', date: '1 day ago', status: 'Completed', gradient: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)' },
    { user: 'Emma Wilson', initials: 'EW', action: 'Added new customer', date: '2 days ago', status: 'Completed', gradient: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)' },
    { user: 'Frank Davis', initials: 'FD', action: 'System backup', date: '2 days ago', status: 'Pending', gradient: 'linear-gradient(135deg, #30cfd0 0%, #330867 100%)' },
    { user: 'Grace Taylor', initials: 'GT', action: 'Updated inventory', date: '3 days ago', status: 'Completed', gradient: 'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)' },
    { user: 'Henry Brown', initials: 'HB', action: 'Processed refund', date: '3 days ago', status: 'Completed', gradient: 'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)' }
  ];

  // Pagination for Installments
  installmentCurrentPage = 1;
  installmentRowsPerPage = 5;
  installmentFilteredData: InstallmentPayment[] = [];
  installmentSearchTerm = '';

  // Pagination for Activity
  activityCurrentPage = 1;
  activityRowsPerPage = 5;
  activityFilteredData: Activity[] = [];
  activitySearchTerm = '';

  // Charts
  private revenueChart?: Chart;
  private installmentChart?: Chart;

  ngOnInit() {
    this.installmentFilteredData = [...this.installmentData];
    this.activityFilteredData = [...this.activityData];
  }

  ngAfterViewInit() {
    setTimeout(() => {
      this.initRevenueChart();
      this.initInstallmentChart();
    }, 100);
  }

  // Revenue Chart
  private initRevenueChart() {
    const canvas = document.getElementById('revenueChart') as HTMLCanvasElement;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    this.revenueChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
        datasets: [{
          label: 'Revenue',
          data: [42000, 39000, 45000, 51000, 48000, 55000, 52000, 58000, 54000, 48597],
          backgroundColor: 'rgba(102, 126, 234, 0.8)',
          borderColor: 'rgba(102, 126, 234, 1)',
          borderWidth: 2,
          borderRadius: 8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            padding: 12,
            callbacks: {
              label: (context: any) => {
                const value = context.parsed?.y || 0;
                return 'Revenue: $' + value.toLocaleString();
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: (value: any) => '$' + (+value / 1000) + 'k'
            }
          }
        }
      }
    });
  }

  // Installment Chart
  private initInstallmentChart() {
    const canvas = document.getElementById('installmentChart') as HTMLCanvasElement;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const paidCount = this.installmentData.filter(i => i.status === 'Paid').length;
    const activeCount = this.installmentData.filter(i => i.status === 'Active').length;
    const dueCount = this.installmentData.filter(i => i.status === 'Due').length;

    this.installmentChart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Paid', 'Active', 'Due'],
        datasets: [{
          data: [paidCount, activeCount, dueCount],
          backgroundColor: [
            'rgba(34, 197, 94, 0.8)',
            'rgba(59, 130, 246, 0.8)',
            'rgba(239, 68, 68, 0.8)'
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
            labels: { padding: 15, usePointStyle: true }
          }
        },
        cutout: '65%'
      }
    });
  }

  // Installment Methods
  get paginatedInstallments(): InstallmentPayment[] {
    const start = (this.installmentCurrentPage - 1) * this.installmentRowsPerPage;
    return this.installmentFilteredData.slice(start, start + this.installmentRowsPerPage);
  }

  get installmentTotalPages(): number {
    return Math.ceil(this.installmentFilteredData.length / this.installmentRowsPerPage);
  }

  onInstallmentSearch() {
    const term = this.installmentSearchTerm.toLowerCase();
    this.installmentFilteredData = this.installmentData.filter(row =>
      row.customer.toLowerCase().includes(term) ||
      row.plan.toLowerCase().includes(term) ||
      row.status.toLowerCase().includes(term)
    );
    this.installmentCurrentPage = 1;
  }

  changeInstallmentPage(page: number) {
    if (page >= 1 && page <= this.installmentTotalPages) {
      this.installmentCurrentPage = page;
    }
  }

  getInstallmentStatusClass(status: string): string {
    return status === 'Paid' ? 'success' : status === 'Due' ? 'danger' : 'primary';
  }

  // Activity Methods
  get paginatedActivities(): Activity[] {
    const start = (this.activityCurrentPage - 1) * this.activityRowsPerPage;
    return this.activityFilteredData.slice(start, start + this.activityRowsPerPage);
  }

  get activityTotalPages(): number {
    return Math.ceil(this.activityFilteredData.length / this.activityRowsPerPage);
  }

  onActivitySearch() {
    const term = this.activitySearchTerm.toLowerCase();
    this.activityFilteredData = this.activityData.filter(row =>
      row.user.toLowerCase().includes(term) ||
      row.action.toLowerCase().includes(term)
    );
    this.activityCurrentPage = 1;
  }

  changeActivityPage(page: number) {
    if (page >= 1 && page <= this.activityTotalPages) {
      this.activityCurrentPage = page;
    }
  }

  getActivityStatusClass(status: string): string {
    return status === 'Completed' ? 'success' : 'warning';
  }

  // Pagination Helper
  getPageNumbers(totalPages: number, currentPage: number): (number | string)[] {
    const pages: (number | string)[] = [];
    for (let i = 1; i <= totalPages; i++) {
      if (i === 1 || i === totalPages || (i >= currentPage - 1 && i <= currentPage + 1)) {
        pages.push(i);
      } else if (i === currentPage - 2 || i === currentPage + 2) {
        if (pages[pages.length - 1] !== '...') {
          pages.push('...');
        }
      }
    }
    return pages;
  }

  // Expose Math to template
  Math = Math;

  // Cleanup
  ngOnDestroy() {
    if (this.revenueChart) {
      this.revenueChart.destroy();
    }
    if (this.installmentChart) {
      this.installmentChart.destroy();
    }
  }
}
