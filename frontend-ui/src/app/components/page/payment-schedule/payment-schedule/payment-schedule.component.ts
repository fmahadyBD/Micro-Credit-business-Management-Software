import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subject, debounceTime, distinctUntilChanged } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import {
  PaymentScheduleControllerService,
  InstallmentManagementService
} from '../../../../services/services';
import { InstallmentResponseDto } from '../../../../services/models/installment-response-dto';
import { PaymentScheduleRequestDto } from '../../../../services/models/payment-schedule-request-dto';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { InstallmentBalance } from '../../../../service/models/InstallmentBalance';

// Import jsPDF and autoTable
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

interface PaymentHistory {
  id: number;
  paidAmount: number;
  remainingAmount: number;
  paymentDate: string;
  status: string;
  notes: string;
  agentName: string;
}

@Component({
  selector: 'app-payment-schedule',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './payment-schedule.component.html',
  styleUrls: ['./payment-schedule.component.css']
})
export class PaymentScheduleComponent implements OnInit, OnDestroy {
  // Search properties
  searchQuery = '';
  searchResults: InstallmentResponseDto[] = [];
  selectedInstallment: InstallmentResponseDto | null = null;
  private searchSubject = new Subject<string>();

  // Payment schedule properties
  paymentAmount = 0;
  notes = '';

  // Balance data
  balanceData: InstallmentBalance | null = null;

  // Payment history
  paymentHistory: PaymentHistory[] = [];
  showPaymentHistory = false;

  // Warning flags
  duplicatePaymentWarning = false;
  duplicatePaymentMonth = '';

  // UI state
  isLoading = false;
  isSearching = false;
  isSubmitting = false;
  isGeneratingPdf = false;
  errorMessage = '';
  successMessage = '';
  isSidebarCollapsed = false;

  constructor(
    private installmentService: InstallmentManagementService,
    private paymentService: PaymentScheduleControllerService,
    private sidebarService: SidebarTopbarService
  ) {
    this.sidebarService.isCollapsed$
      .pipe(takeUntilDestroyed())
      .subscribe(collapsed => {
        this.isSidebarCollapsed = collapsed;
      });

    // Setup auto-search with debounce
    this.searchSubject.pipe(
      debounceTime(500),
      distinctUntilChanged(),
      takeUntilDestroyed()
    ).subscribe(searchTerm => {
      if (searchTerm.trim().length >= 2) {
        this.performSearch(searchTerm);
      } else if (searchTerm.trim().length === 0) {
        this.searchResults = [];
      }
    });
  }

  ngOnInit(): void {
    // Initialization logic if needed
  }

  ngOnDestroy(): void {
    this.searchSubject.complete();
  }

  // Auto-search trigger
  onSearchInput(): void {
    this.searchSubject.next(this.searchQuery);
  }

  // Manual search
  onSearch(): void {
    if (this.searchQuery.trim().length >= 2) {
      this.performSearch(this.searchQuery);
    }
  }

  // Perform search operation
  private performSearch(searchTerm: string): void {
    this.isSearching = true;
    this.errorMessage = '';
    this.successMessage = '';

    this.installmentService.searchInstallment({
      keyword: searchTerm
    } as any)
      .subscribe({
        next: (installments) => {
          this.isSearching = false;
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
    this.paymentHistory = [];
    this.showPaymentHistory = false;
    this.duplicatePaymentWarning = false;

    if (installment.monthlyInstallmentAmount) {
      this.paymentAmount = installment.monthlyInstallmentAmount;
    }

    this.loadBalanceData();
    this.loadPaymentHistory();
  }

  // Load balance data
  private loadBalanceData(): void {
    if (!this.selectedInstallment?.id) return;

    this.isLoading = true;

    this.paymentService.getRemainingBalance({
      installmentId: this.selectedInstallment.id
    }).subscribe({
      next: (response: any) => {
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

  // Load payment history
  private loadPaymentHistory(): void {
    if (!this.selectedInstallment?.id) return;

    this.paymentService.getPaymentsByInstallment({
      installmentId: this.selectedInstallment.id
    }).subscribe({
      next: (response: any) => {
        if (Array.isArray(response)) {
          this.paymentHistory = response.map((payment: any) => ({
            id: payment.id,
            paidAmount: payment.paidAmount,
            remainingAmount: payment.remainingAmount,
            paymentDate: payment.paymentDate,
            status: payment.status,
            notes: payment.notes,
            agentName: payment.agentName
          }));
        }
        this.checkDuplicatePaymentWarning();
      },
      error: (error) => {
        console.error('Error loading payment history:', error);
      }
    });
  }

  // Check for duplicate payment in same month
  private checkDuplicatePaymentWarning(): void {
    const currentMonth = new Date().getMonth();
    const currentYear = new Date().getFullYear();

    const paymentThisMonth = this.paymentHistory.find(payment => {
      const paymentDate = new Date(payment.paymentDate);
      return paymentDate.getMonth() === currentMonth &&
        paymentDate.getFullYear() === currentYear;
    });

    if (paymentThisMonth) {
      this.duplicatePaymentWarning = true;
      this.duplicatePaymentMonth = new Date(paymentThisMonth.paymentDate).toLocaleDateString('en-US', {
        month: 'long',
        year: 'numeric'
      });
    } else {
      this.duplicatePaymentWarning = false;
    }
  }

  // Toggle payment history visibility
  togglePaymentHistory(): void {
    this.showPaymentHistory = !this.showPaymentHistory;
  }

// Generate PDF Report
generatePdfReport(): void {
  if (!this.selectedInstallment) {
    this.errorMessage = 'No installment selected';
    return;
  }

  this.isGeneratingPdf = true;

  try {
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.getWidth();
    let yPos = 20;

    // Add Title
    doc.setFontSize(20);
    doc.setTextColor(102, 126, 234);
    doc.text('Payment Schedule Report', pageWidth / 2, yPos, { align: 'center' });

    yPos += 10;
    doc.setFontSize(10);
    doc.setTextColor(100, 100, 100);
    doc.text(`Generated on: ${new Date().toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })}`, pageWidth / 2, yPos, { align: 'center' });

    yPos += 15;

    // Member Information Section
    doc.setFontSize(14);
    doc.setTextColor(0, 0, 0);
    doc.text('Member Information', 14, yPos);
    yPos += 7;

    doc.setFontSize(10);
    const memberInfo = [
      ['Full Name:', this.selectedInstallment.member?.name || 'N/A'],
      ['Phone Number:', this.selectedInstallment.member?.phone || 'N/A'],
      ['Status:', this.selectedInstallment.status || 'N/A']
    ];

    memberInfo.forEach(([label, value]) => {
      doc.setTextColor(100, 100, 100);
      doc.text(label || '', 14, yPos);
      doc.setTextColor(0, 0, 0);
      doc.text(value || '', 60, yPos);
      yPos += 6;
    });

    yPos += 5;

    // Product Information Section
    if (this.selectedInstallment.product) {
      doc.setFontSize(14);
      doc.setTextColor(0, 0, 0);
      doc.text('Product Information', 14, yPos);
      yPos += 7;

      doc.setFontSize(10);
      const productInfo = [
        ['Product Name:', this.selectedInstallment.product.name || 'N/A'],
        ['Category:', this.selectedInstallment.product.category || 'N/A']
      ];

      productInfo.forEach(([label, value]) => {
        doc.setTextColor(100, 100, 100);
        doc.text(label || '', 14, yPos);
        doc.setTextColor(0, 0, 0);
        doc.text(value || '', 60, yPos);
        yPos += 6;
      });

      yPos += 5;
    }

    // Financial Summary Section
    doc.setFontSize(14);
    doc.setTextColor(0, 0, 0);
    doc.text('Financial Summary', 14, yPos);
    yPos += 7;

    doc.setFontSize(10);
    const financialInfo = [
      ['Total Amount:', `${this.formatCurrency(this.selectedInstallment.totalAmountWithInterest)} ৳`],
      ['Total Paid:', `${this.formatCurrency(this.getTotalPaidAmount())} ৳`],
      ['Remaining Balance:', `${this.formatCurrency(this.getRemainingAmount())} ৳`],
      ['Monthly Installment:', `${this.formatCurrency(this.selectedInstallment.monthlyInstallmentAmount)} ৳`],
      ['Progress:', `${this.getProgressPercentage().toFixed(1)}%`]
    ];

    financialInfo.forEach(([label, value]) => {
      doc.setTextColor(100, 100, 100);
      doc.text(label || '', 14, yPos);
      doc.setTextColor(0, 0, 0);
      doc.text(value || '', 60, yPos);
      yPos += 6;
    });

    yPos += 10;

    // Payment History Table
    if (this.paymentHistory.length > 0) {
      doc.setFontSize(14);
      doc.setTextColor(0, 0, 0);
      doc.text('Payment History', 14, yPos);
      yPos += 5;

      const tableData = this.paymentHistory.map((payment, index) => [
        (index + 1).toString(),
        this.formatDate(payment.paymentDate),
        `${this.formatCurrency(payment.paidAmount)} ৳`,
        `${this.formatCurrency(payment.remainingAmount)} ৳`,
        payment.agentName || 'N/A',
        payment.status || 'N/A',
        payment.notes || '-'
      ]);

      autoTable(doc, {
        startY: yPos,
        head: [['#', 'Date', 'Amount Paid', 'Remaining', 'Agent', 'Status', 'Notes']],
        body: tableData,
        theme: 'striped',
        headStyles: {
          fillColor: [102, 126, 234],
          textColor: [255, 255, 255],
          fontStyle: 'bold'
        },
        styles: {
          fontSize: 9,
          cellPadding: 3
        },
        columnStyles: {
          0: { cellWidth: 10 },
          1: { cellWidth: 30 },
          2: { cellWidth: 25 },
          3: { cellWidth: 25 },
          4: { cellWidth: 25 },
          5: { cellWidth: 20 },
          6: { cellWidth: 45 }
        }
      });
    } else {
      doc.setFontSize(10);
      doc.setTextColor(150, 150, 150);
      doc.text('No payment history available', 14, yPos);
    }

    // Add footer
    const pageCount = (doc.internal as any).getNumberOfPages();
    for (let i = 1; i <= pageCount; i++) {
      doc.setPage(i);
      doc.setFontSize(8);
      doc.setTextColor(150, 150, 150);
      doc.text(
        `Page ${i} of ${pageCount}`,
        pageWidth / 2,
        doc.internal.pageSize.getHeight() - 10,
        { align: 'center' }
      );
    }

    // Save the PDF
    const fileName = `Payment_Report_${this.selectedInstallment.member?.name?.replace(/\s+/g, '_') || 'Unknown'}_${new Date().getTime()}.pdf`;
    doc.save(fileName);

    this.successMessage = 'PDF report generated successfully!';
    this.isGeneratingPdf = false;
  } catch (error) {
    console.error('Error generating PDF:', error);
    this.errorMessage = 'Failed to generate PDF report';
    this.isGeneratingPdf = false;
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

    const remainingAmount = this.getRemainingAmount();
    if (this.paymentAmount > remainingAmount) {
      this.errorMessage = `Payment amount cannot exceed remaining amount of ${this.formatCurrency(remainingAmount)} ৳`;
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
          this.successMessage = `Payment of ${this.formatCurrency(this.paymentAmount)} ৳ submitted successfully!`;

          this.paymentAmount = this.selectedInstallment?.monthlyInstallmentAmount || 0;
          this.notes = '';

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
    return this.balanceData?.totalPaid || this.selectedInstallment.advanced_paid || 0;
  }

  // Reload installment data after payment
  private reloadInstallmentData(): void {
    if (!this.selectedInstallment?.id) return;

    this.installmentService.getInstallmentById({ id: this.selectedInstallment.id })
      .subscribe({
        next: (updatedInstallment) => {
          this.selectedInstallment = updatedInstallment;
          this.loadBalanceData();
          this.loadPaymentHistory();
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
    this.paymentHistory = [];
    this.showPaymentHistory = false;
    this.duplicatePaymentWarning = false;
  }

  // Format currency
  formatCurrency(amount: number | undefined): string {
    if (amount === undefined || amount === null) return '0.00';
    return amount.toFixed(2);
  }

  // Format date
  formatDate(date: string): string {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  }

  // Get status badge class
  getStatusClass(status: string | undefined): string {
    switch (status) {
      case 'ACTIVE': return 'badge bg-success';
      case 'PENDING': return 'badge bg-warning text-dark';
      case 'COMPLETED': return 'badge bg-info';
      case 'PAID': return 'badge bg-primary';
      case 'OVERDUE': return 'badge bg-danger';
      case 'CANCELLED': return 'badge bg-secondary';
      case 'DEFAULTED': return 'badge bg-dark';
      default: return 'badge bg-secondary';
    }
  }

  // Get progress percentage
  getProgressPercentage(): number {
    if (!this.selectedInstallment) return 0;
    const total = this.selectedInstallment.totalAmountWithInterest || 0;
    const paid = this.getTotalPaidAmount();
    return total > 0 ? (paid / total) * 100 : 0;
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