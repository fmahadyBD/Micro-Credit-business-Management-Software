import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { 
  PaymentScheduleControllerService, 
  InstallmentManagementService
} from '../../../../services/services';
import { InstallmentResponseDto } from '../../../../services/models/installment-response-dto';
import { PaymentScheduleRequestDto } from '../../../../services/models/payment-schedule-request-dto';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-payment-schedule',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './payment-schedule.component.html',
  styleUrls: ['./payment-schedule.component.css']
})
export class PaymentScheduleComponent implements OnInit {

  // Search properties
  searchQuery: string = '';
  searchResults: InstallmentResponseDto[] = [];
  selectedInstallment: InstallmentResponseDto | null = null;
  
  // Payment schedule properties
  paymentAmount: number = 0;
  notes: string = '';
  totalAmount: number =0;
  reamingAmount: number =0;
  monthlyAmount: number =0;
  
  // UI state
  isLoading: boolean = false;
  isSearching: boolean = false;
  isSubmitting: boolean = false;
  errorMessage: string = '';
  successMessage: string = '';
  isSidebarCollapsed = false;

  constructor(
    private installmentService: InstallmentManagementService,
    private paymentService: PaymentScheduleControllerService,
     private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
  }
  

  // Search installments by product name, member name, or phone
  onSearch(): void {
    if (!this.searchQuery.trim()) {
      this.errorMessage = 'Please enter a search term';
      return;
    }

    this.isSearching = true;
    this.errorMessage = '';
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
          this.errorMessage = 'Error searching installments: ' + (error.error?.message || error.message);
          console.error('Search error:', error);
        }
      });
  }

  // Select an installment from search results
  selectInstallment(installment: InstallmentResponseDto): void {
    this.selectedInstallment = installment;
    this.errorMessage = '';
    this.successMessage = '';
    
    // Set default payment amount to monthly installment amount
    if (installment.monthlyInstallmentAmount) {
      this.paymentAmount = installment.monthlyInstallmentAmount;
    }
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

    if (this.paymentAmount > this.getRemainingAmount()) {
      this.errorMessage = 'Payment amount cannot exceed remaining amount';
      return;
    }

    this.isSubmitting = true;
    this.errorMessage = '';
    this.successMessage = '';

    // Use the correct property names from PaymentScheduleRequestDto
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
          this.successMessage = 'Payment submitted successfully!';
          
          // Reset form
          this.paymentAmount = this.selectedInstallment?.monthlyInstallmentAmount || 0;
          this.notes = '';
          
          // Reload installment data to update remaining amount
          this.reloadInstallmentData();
        },
        error: (error) => {
          this.isSubmitting = false;
          this.errorMessage = 'Error submitting payment: ' + (error.error?.message || error.message);
          console.error('Payment error:', error);
        }
      });
  }

// TODO this work need to do
  getRemainingAmount(): number {
    if (!this.selectedInstallment) return 0;


    return this.selectedInstallment.needPaidAmount || 0;
  }

// TODO this work need to do
  getTotalPaidAmount(): number {
    if (!this.selectedInstallment) return 0;
    return (this.selectedInstallment.advanced_paid || 0);
  }

  // Reload installment data after payment
  reloadInstallmentData(): void {
    if (!this.selectedInstallment?.id) return;

    this.installmentService.getInstallmentById({ id: this.selectedInstallment.id })
      .subscribe({
        next: (updatedInstallment) => {
          this.selectedInstallment = updatedInstallment;
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