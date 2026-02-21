import { CommonModule } from '@angular/common';
import { AfterViewInit, Component, OnDestroy, OnInit } from '@angular/core';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Chart, registerables } from 'chart.js';
import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';
import { MainBalanceResponseDto } from '../../../services/models/main-balance-response-dto';
import { EarningsResponseDto } from '../../../services/models/earnings-response-dto';
import { TransactionHistoryResponseDto } from '../../../services/models/transaction-history-response-dto';
import { MainBalanceManagementService } from '../../../services/services/main-balance-management.service';

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

@Component({
  selector: 'app-admin-main',
  standalone: true,
  imports: [CommonModule, FormsModule, ReactiveFormsModule],
  templateUrl: './admin-main.component.html',
  styleUrl: './admin-main.component.css'
})
export class AdminMainComponent implements OnInit, AfterViewInit, OnDestroy {
  // Main Balance Data
  mainBalance?: MainBalanceResponseDto;
  earnings?: EarningsResponseDto;
  transactions: TransactionHistoryResponseDto[] = [];

  // Stats Cards
  stats: StatCard[] = [];

  // Forms
  investmentForm!: FormGroup;
  withdrawalForm!: FormGroup;
  installmentReturnForm!: FormGroup;
  productCostForm!: FormGroup;
  maintenanceCostForm!: FormGroup;

  // Modal states
  showInvestmentModal = false;
  showWithdrawalModal = false;
  showInstallmentModal = false;
  showProductCostModal = false;
  showMaintenanceModal = false;

  // Transaction Pagination
  transactionCurrentPage = 1;
  transactionRowsPerPage = 10;
  transactionFilteredData: TransactionHistoryResponseDto[] = [];
  transactionSearchTerm = '';

  // Sidebar state
  isSidebarCollapsed = false;

  // Charts
  private balanceChart?: Chart;
  private transactionChart?: Chart;

  // Loading states
  isLoading = false;
  isSubmitting = false;

  constructor(
    private sidebarService: SidebarTopbarService,
    private mainBalanceService: MainBalanceManagementService,
    private fb: FormBuilder
  ) {
    this.initializeForms();
  }

  ngOnInit() {
    // Subscribe to sidebar collapse state
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });

    this.loadMainBalance();
    this.loadEarnings();
    this.loadTransactions();
  }

  ngAfterViewInit() {
    setTimeout(() => {
      this.initBalanceChart();
      this.initTransactionChart();
    }, 100);
  }

  // Initialize Forms
  private initializeForms() {
    this.investmentForm = this.fb.group({
      amount: ['', [Validators.required, Validators.min(1)]],
      shareholderId: ['', [Validators.required]]
    });

    this.withdrawalForm = this.fb.group({
      amount: ['', [Validators.required, Validators.min(1)]],
      shareholderId: ['', [Validators.required]]
    });

    this.installmentReturnForm = this.fb.group({
      amount: ['', [Validators.required, Validators.min(1)]]
    });

    this.productCostForm = this.fb.group({
      amount: ['', [Validators.required, Validators.min(1)]]
    });

    this.maintenanceCostForm = this.fb.group({
      amount: ['', [Validators.required, Validators.min(1)]]
    });
  }

  // Load Main Balance
  loadMainBalance() {
    this.isLoading = true;
    this.mainBalanceService.getBalance().subscribe({
      next: (response) => {
        this.mainBalance = response;
        this.updateStatsCards();
        this.isLoading = false;
        this.updateCharts();
      },
      error: (error) => {
        console.error('Error loading main balance:', error);
        this.isLoading = false;
      }
    });
  }

  // Load Earnings
  loadEarnings() {
    this.mainBalanceService.calculateEarnings().subscribe({
      next: (response) => {
        this.earnings = response;
      },
      error: (error) => {
        console.error('Error loading earnings:', error);
      }
    });
  }

  // Load Transactions
  loadTransactions() {
    this.mainBalanceService.getAllTransactions().subscribe({
      next: (response: any) => {
        this.transactions = Array.isArray(response) ? response : [];
        this.transactionFilteredData = [...this.transactions];
      },
      error: (error) => {
        console.error('Error loading transactions:', error);
        this.transactions = [];
        this.transactionFilteredData = [];
      }
    });
  }

  // Update Stats Cards
  updateStatsCards() {
    if (!this.mainBalance) return;

    this.stats = [
      {
        title: 'Total Balance',
        value: this.formatCurrency(this.mainBalance.totalBalance || 0),
        change: 'Current available balance',
        trend: 'up',
        icon: 'fas fa-wallet',
        iconBg: 'bg-primary bg-opacity-10',
        iconColor: 'text-primary'
      },
      {
        title: 'Total Investment',
        value: this.formatCurrency(this.mainBalance.totalInvestment || 0),
        change: 'Total invested capital',
        trend: 'up',
        icon: 'fas fa-hand-holding-usd',
        iconBg: 'bg-success bg-opacity-10',
        iconColor: 'text-success'
      },
      {
        title: 'Total Returns',
        value: this.formatCurrency(this.mainBalance.totalInstallmentReturn || 0),
        change: 'Installment collections',
        trend: 'up',
        icon: 'fas fa-money-bill-wave',
        iconBg: 'bg-info bg-opacity-10',
        iconColor: 'text-info'
      },
      {
        title: 'Total Costs',
        value: this.formatCurrency((this.mainBalance.totalProductCost || 0) + (this.mainBalance.totalMaintenanceCost || 0)),
        change: 'Product & Maintenance',
        trend: 'down',
        icon: 'fas fa-chart-line',
        iconBg: 'bg-warning bg-opacity-10',
        iconColor: 'text-warning'
      },
      {
        title: 'Withdrawals',
        value: this.formatCurrency(this.mainBalance.totalWithdrawal || 0),
        change: 'Total withdrawn',
        trend: 'down',
        icon: 'fas fa-arrow-down',
        iconBg: 'bg-danger bg-opacity-10',
        iconColor: 'text-danger'
      },
      {
        title: 'Earnings',
        value: this.formatCurrency(this.mainBalance.earnings || 0),
        change: 'Net profit',
        trend: 'up',
        icon: 'fas fa-trophy',
        iconBg: 'bg-success bg-opacity-10',
        iconColor: 'text-success'
      }
    ];
  }

  // Add Investment
  submitInvestment() {
    if (this.investmentForm.invalid) return;

    this.isSubmitting = true;
    const formValue = this.investmentForm.value;

    this.mainBalanceService.addInvestment({
      body: {
        amount: formValue.amount,
        shareholderId: formValue.shareholderId
      }
    }).subscribe({
      next: (response) => {
        this.mainBalance = response;
        this.updateStatsCards();
        this.closeInvestmentModal();
        this.loadTransactions();
        this.updateCharts();
        this.isSubmitting = false;
      },
      error: (error) => {
        console.error('Error adding investment:', error);
        alert('Failed to add investment: ' + (error.error?.message || error.message));
        this.isSubmitting = false;
      }
    });
  }

  // Withdraw Funds
  submitWithdrawal() {
    if (this.withdrawalForm.invalid) return;

    this.isSubmitting = true;
    const formValue = this.withdrawalForm.value;

    this.mainBalanceService.withdraw({
      body: {
        amount: formValue.amount,
        shareholderId: formValue.shareholderId
      }
    }).subscribe({
      next: (response) => {
        this.mainBalance = response;
        this.updateStatsCards();
        this.closeWithdrawalModal();
        this.loadTransactions();
        this.updateCharts();
        this.isSubmitting = false;
      },
      error: (error) => {
        console.error('Error processing withdrawal:', error);
        alert('Failed to process withdrawal: ' + (error.error?.message || error.message));
        this.isSubmitting = false;
      }
    });
  }

  // Add Installment Return
  submitInstallmentReturn() {
    if (this.installmentReturnForm.invalid) return;

    this.isSubmitting = true;
    const formValue = this.installmentReturnForm.value;

    this.mainBalanceService.addInstallmentReturn({
      body: { amount: formValue.amount }
    }).subscribe({
      next: (response) => {
        this.mainBalance = response;
        this.updateStatsCards();
        this.closeInstallmentModal();
        this.loadTransactions();
        this.updateCharts();
        this.isSubmitting = false;
      },
      error: (error) => {
        console.error('Error adding installment return:', error);
        alert('Failed to add installment return: ' + (error.error?.message || error.message));
        this.isSubmitting = false;
      }
    });
  }

  // Add Product Cost
  submitProductCost() {
    if (this.productCostForm.invalid) return;

    this.isSubmitting = true;
    const formValue = this.productCostForm.value;

    this.mainBalanceService.addProductCost({
      body: { amount: formValue.amount }
    }).subscribe({
      next: (response) => {
        this.mainBalance = response;
        this.updateStatsCards();
        this.closeProductCostModal();
        this.loadTransactions();
        this.updateCharts();
        this.isSubmitting = false;
      },
      error: (error) => {
        console.error('Error adding product cost:', error);
        alert('Failed to add product cost: ' + (error.error?.message || error.message));
        this.isSubmitting = false;
      }
    });
  }

  // Add Maintenance Cost
  submitMaintenanceCost() {
    if (this.maintenanceCostForm.invalid) return;

    this.isSubmitting = true;
    const formValue = this.maintenanceCostForm.value;

    this.mainBalanceService.addMaintenanceCost({
      body: { amount: formValue.amount }
    }).subscribe({
      next: (response) => {
        this.mainBalance = response;
        this.updateStatsCards();
        this.closeMaintenanceModal();
        this.loadTransactions();
        this.updateCharts();
        this.isSubmitting = false;
      },
      error: (error) => {
        console.error('Error adding maintenance cost:', error);
        alert('Failed to add maintenance cost: ' + (error.error?.message || error.message));
        this.isSubmitting = false;
      }
    });
  }

  // Modal Controls
  openInvestmentModal() {
    this.showInvestmentModal = true;
    this.investmentForm.reset();
  }

  closeInvestmentModal() {
    this.showInvestmentModal = false;
    this.investmentForm.reset();
  }

  openWithdrawalModal() {
    this.showWithdrawalModal = true;
    this.withdrawalForm.reset();
  }

  closeWithdrawalModal() {
    this.showWithdrawalModal = false;
    this.withdrawalForm.reset();
  }

  openInstallmentModal() {
    this.showInstallmentModal = true;
    this.installmentReturnForm.reset();
  }

  closeInstallmentModal() {
    this.showInstallmentModal = false;
    this.installmentReturnForm.reset();
  }

  openProductCostModal() {
    this.showProductCostModal = true;
    this.productCostForm.reset();
  }

  closeProductCostModal() {
    this.showProductCostModal = false;
    this.productCostForm.reset();
  }

  openMaintenanceModal() {
    this.showMaintenanceModal = true;
    this.maintenanceCostForm.reset();
  }

  closeMaintenanceModal() {
    this.showMaintenanceModal = false;
    this.maintenanceCostForm.reset();
  }

  // Charts
  private initBalanceChart() {
    const canvas = document.getElementById('balanceChart') as HTMLCanvasElement;
    if (!canvas || !this.mainBalance) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    this.balanceChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Investment', 'Returns', 'Costs', 'Withdrawals', 'Balance'],
        datasets: [{
          label: 'Amount',
          data: [
            this.mainBalance.totalInvestment || 0,
            this.mainBalance.totalInstallmentReturn || 0,
            (this.mainBalance.totalProductCost || 0) + (this.mainBalance.totalMaintenanceCost || 0),
            this.mainBalance.totalWithdrawal || 0,
            this.mainBalance.totalBalance || 0
          ],
          backgroundColor: [
            'rgba(34, 197, 94, 0.8)',
            'rgba(59, 130, 246, 0.8)',
            'rgba(251, 146, 60, 0.8)',
            'rgba(239, 68, 68, 0.8)',
            'rgba(102, 126, 234, 0.8)'
          ],
          borderRadius: 8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
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

  private initTransactionChart() {
    const canvas = document.getElementById('transactionChart') as HTMLCanvasElement;
    if (!canvas || !this.mainBalance) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    this.transactionChart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Investment', 'Returns', 'Costs', 'Withdrawals'],
        datasets: [{
          data: [
            this.mainBalance.totalInvestment || 0,
            this.mainBalance.totalInstallmentReturn || 0,
            (this.mainBalance.totalProductCost || 0) + (this.mainBalance.totalMaintenanceCost || 0),
            this.mainBalance.totalWithdrawal || 0
          ],
          backgroundColor: [
            'rgba(34, 197, 94, 0.8)',
            'rgba(59, 130, 246, 0.8)',
            'rgba(251, 146, 60, 0.8)',
            'rgba(239, 68, 68, 0.8)'
          ]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom'
          }
        },
        cutout: '65%'
      }
    });
  }

  private updateCharts() {
    setTimeout(() => {
      if (this.balanceChart) {
        this.balanceChart.destroy();
      }
      if (this.transactionChart) {
        this.transactionChart.destroy();
      }
      this.initBalanceChart();
      this.initTransactionChart();
    }, 100);
  }

  // Transaction Table Methods
  get paginatedTransactions(): TransactionHistoryResponseDto[] {
    const start = (this.transactionCurrentPage - 1) * this.transactionRowsPerPage;
    return this.transactionFilteredData.slice(start, start + this.transactionRowsPerPage);
  }

  get transactionTotalPages(): number {
    return Math.ceil(this.transactionFilteredData.length / this.transactionRowsPerPage);
  }

  onTransactionSearch() {
    const term = this.transactionSearchTerm.toLowerCase();
    this.transactionFilteredData = this.transactions.filter(row =>
      JSON.stringify(row).toLowerCase().includes(term)
    );
    this.transactionCurrentPage = 1;
  }

  changeTransactionPage(page: number) {
    if (page >= 1 && page <= this.transactionTotalPages) {
      this.transactionCurrentPage = page;
    }
  }

  getTransactionTypeClass(type?: string): string {
    if (!type) return 'secondary';
    const lowerType = type.toLowerCase();
    if (lowerType.includes('investment') || lowerType.includes('return') || lowerType.includes('installment')) return 'success';
    if (lowerType.includes('withdrawal') || lowerType.includes('cost') || lowerType.includes('expense')) return 'danger';
    return 'primary';
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

  // Utility Methods
  formatCurrency(value: number): string {
    return '$' + value.toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
  }

  formatDate(date?: string): string {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  // Expose Math to template
  Math = Math;

  // Cleanup
  ngOnDestroy() {
    if (this.balanceChart) {
      this.balanceChart.destroy();
    }
    if (this.transactionChart) {
      this.transactionChart.destroy();
    }
  }
}