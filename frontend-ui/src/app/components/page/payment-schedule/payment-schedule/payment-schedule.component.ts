import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import {
  PaymentScheduleControllerService,
  InstallmentManagementService
} from '../../../../services/services';
import { InstallmentResponseDto } from '../../../../services/models/installment-response-dto';
import { PaymentScheduleRequestDto } from '../../../../services/models/payment-schedule-request-dto';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { InstallmentBalance } from '../../../../service/models/InstallmentBalance';

@Component({
  selector: 'app-payment-schedule',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './payment-schedule.component.html',
  styleUrls: ['./payment-schedule.component.css']
})
export class PaymentScheduleComponent implements OnInit {

  // Search properties
  searchQuery = '';
  searchResults: InstallmentResponseDto[] = [];
  selectedInstallment: InstallmentResponseDto | null = null;

  // Payment schedule properties
  paymentAmount = 0;
  notes = '';

  // Balance data
  balanceData: InstallmentBalance | null = null;

  // UI state
  isLoading = false;
  isSearching = false;
  isSubmitting = false;
  errorMessage = '';
  successMessage = '';
  isSidebarCollapsed = false;

  constructor(
    private installmentService: InstallmentManagementService,
    private paymentService: PaymentScheduleControllerService,
    private sidebarService: SidebarTopbarService
  ) {
    // Subscribe to sidebar state with automatic cleanup
    this.sidebarService.isCollapsed$
      .pipe(takeUntilDestroyed())
      .subscribe(collapsed => {
        this.isSidebarCollapsed = collapsed;
      });
  }

  ngOnInit(): void {
    // Initialization logic if needed
  }

  // Search installments by product name, member name, or phone
  onSearch(): void {
    if (!this.searchQuery.trim()) {
      this.errorMessage = 'Please enter a search term';
      return;
    }

    this.isSearching = true;
    this.errorMessage = '';
    this.successMessage = '';
    this.searchResults = [];

    this.installmentService.searchInstallment({
      keyword: this.searchQuery
    } as any)
      .subscribe({
        next: (installments) => {
          this.isSearching = false;
          // Handle single result or array
          if (Array.isArray(installments)) {
            this.searchResults = installments;
          } else {
            this.searchResults = [installments];
          }

          if (this.searchResults.length === 0) {
            this.errorMessage = 'No installments found matching your search';
          }
        },
        error: (error) => {
          this.isSearching = false;
          this.errorMessage = 'Unable to search installments. Please try again.';
          console.error('Search error:', error);
        }
      });
  }

  // Select an installment from search results
  selectInstallment(installment: InstallmentResponseDto): void {
    this.selectedInstallment = installment;
    this.errorMessage = '';
    this.successMessage = '';
    this.balanceData = null;

    // Set default payment amount to monthly installment amount
    if (installment.monthlyInstallmentAmount) {
      this.paymentAmount = installment.monthlyInstallmentAmount;
    }

    // Load balance data immediately
    this.loadBalanceData();
  }

  // Load balance data for selected installment
  private loadBalanceData(): void {
    if (!this.selectedInstallment?.id) return;

    this.isLoading = true;

    this.paymentService.getRemainingBalance({
      installmentId: this.selectedInstallment.id
    }).subscribe({
      next: (response: any) => {  // Change back to 'any'
        this.balanceData = response;
        this.isLoading = false;
      },
      error: (error) => {
        console.error('Error loading balance:', error);
        this.errorMessage = 'Unable to load balance information';
        this.isLoading = false;
      }
    });
  }

  // Submit payment
  onPayInstallment(): void {
    if (!this.selectedInstallment) {
      this.errorMessage = 'Please select an installment first';
      return;
    }

    if (!this.paymentAmount || this.paymentAmount <= 0) {
      this.errorMessage = 'Please enter a valid payment amount';
      return;
    }

    const remainingAmount = this.getRemainingAmount();
    if (this.paymentAmount > remainingAmount) {
      this.errorMessage = `Payment amount cannot exceed remaining amount of ${this.formatCurrency(remainingAmount)}`;
      return;
    }

    this.isSubmitting = true;
    this.errorMessage = '';
    this.successMessage = '';

    const paymentRequest: PaymentScheduleRequestDto = {
      installmentId: this.selectedInstallment.id!,
      amount: this.paymentAmount,
      agentId: this.selectedInstallment.given_product_agent?.id || 0,
      notes: this.notes
    };

    this.paymentService.payInstallment({ body: paymentRequest })
      .subscribe({
        next: () => {
          this.isSubmitting = false;
          this.successMessage = `Payment of ${this.formatCurrency(this.paymentAmount)} submitted successfully!`;

          // Reset form
          this.paymentAmount = this.selectedInstallment?.monthlyInstallmentAmount || 0;
          this.notes = '';

          // Reload installment and balance data
          this.reloadInstallmentData();
        },
        error: (error) => {
          this.isSubmitting = false;
          this.errorMessage = 'Unable to process payment. Please try again.';
          console.error('Payment error:', error);
        }
      });
  }

  // Get remaining amount
  getRemainingAmount(): number {
    return this.balanceData?.remainingBalance || 0;
  }

  // Get total paid amount
  getTotalPaidAmount(): number {
    if (!this.selectedInstallment) return 0;

    if (this.balanceData) {
      return this.balanceData.totalPaid;
    }
    return this.selectedInstallment.advanced_paid || 0;
  }

  // Reload installment data after payment
  private reloadInstallmentData(): void {
    if (!this.selectedInstallment?.id) return;

    this.installmentService.getInstallmentById({ id: this.selectedInstallment.id })
      .subscribe({
        next: (updatedInstallment) => {
          this.selectedInstallment = updatedInstallment;
          // Reload balance after getting updated installment
          this.loadBalanceData();
        },
        error: (error) => {
          console.error('Error reloading installment:', error);
        }
      });
  }

  // Clear selection and reset form
  clearSelection(): void {
    this.selectedInstallment = null;
    this.searchResults = [];
    this.searchQuery = '';
    this.paymentAmount = 0;
    this.notes = '';
    this.errorMessage = '';
    this.successMessage = '';
    this.balanceData = null;
  }

  // Format currency
  formatCurrency(amount: number | undefined): string {
    if (amount === undefined || amount === null) return '0.00';
    return amount.toFixed(2);
  }

  // Get status badge class
  getStatusClass(status: string | undefined): string {
    switch (status) {
      case 'ACTIVE': return 'badge bg-success';
      case 'PENDING': return 'badge bg-warning';
      case 'COMPLETED': return 'badge bg-info';
      case 'OVERDUE': return 'badge bg-danger';
      case 'CANCELLED': return 'badge bg-secondary';
      case 'DEFAULTED': return 'badge bg-dark';
      default: return 'badge bg-secondary';
    }
  }

  // Alias properties for template compatibility
  get searchTerm(): string {
    return this.searchQuery;
  }

  set searchTerm(value: string) {
    this.searchQuery = value;
  }

  get installments(): InstallmentResponseDto[] {
    return this.searchResults;
  }
}