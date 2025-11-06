import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { InstallmentManagementService } from '../../../../services/services/installment-management.service';
import { InstallmentResponseDto } from '../../../../services/models/installment-response-dto';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-installment-management',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './installment-management.component.html',
  styleUrls: ['./installment-management.component.css']
})
export class InstallmentManagementComponent implements OnInit {
  installments: InstallmentResponseDto[] = [];
  filteredInstallments: InstallmentResponseDto[] = [];
  loading: boolean = true;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  // Search and Filter
  searchTerm: string = '';
  statusFilter: string = 'ALL';
  dateFilter: string = '';

  // Edit Modal
  showEditModal: boolean = false;
  editingInstallment: InstallmentResponseDto | null = null;
  editFormData: any = {};
  saving: boolean = false;

  // Delete Confirmation
  showDeleteModal: boolean = false;
  deletingInstallment: InstallmentResponseDto | null = null;
  deleting: boolean = false;

  // Pagination
  currentPage: number = 1;
  itemsPerPage: number = 10;
  totalPages: number = 1;

  // For template Math reference
  Math = Math;

  constructor(
    private installmentService: InstallmentManagementService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadInstallments();
  }

  loadInstallments(): void {
    this.loading = true;
    this.error = null;
    
    this.installmentService.getAllInstallments({}).subscribe({
      next: (data) => {
        this.installments = Array.isArray(data) ? data : [data];
        this.applyFilters();
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load installments';
        this.loading = false;
        console.error('Error loading installments:', err);
      }
    });
  }

  searchInstallments(): void {
    if (this.searchTerm.trim()) {
      this.installmentService.searchInstallment({ keyword: this.searchTerm }).subscribe({
        next: (data) => {
          this.installments = Array.isArray(data) ? data : [data];
          this.applyFilters();
        },
        error: (err) => {
          console.error('Search error:', err);
        }
      });
    } else {
      this.loadInstallments();
    }
  }

  applyFilters(): void {
    let filtered = [...this.installments];

    // Status filter
    if (this.statusFilter !== 'ALL') {
      filtered = filtered.filter(installment => 
        installment.status === this.statusFilter
      );
    }

    // Date filter (simple implementation)
    if (this.dateFilter) {
      filtered = filtered.filter(installment => {
        const createdDate = new Date(installment.createdTime || '').toISOString().split('T')[0];
        return createdDate === this.dateFilter;
      });
    }

    this.filteredInstallments = filtered;
    this.updatePagination();
  }

  updatePagination(): void {
    this.totalPages = Math.ceil(this.filteredInstallments.length / this.itemsPerPage);
    this.currentPage = Math.min(this.currentPage, this.totalPages || 1);
  }

  get paginatedInstallments(): InstallmentResponseDto[] {
    const startIndex = (this.currentPage - 1) * this.itemsPerPage;
    return this.filteredInstallments.slice(startIndex, startIndex + this.itemsPerPage);
  }

  // Add new installment
  addNewInstallment(): void {
    window.dispatchEvent(new CustomEvent('addInstallment'));
  }

  // View installment details
  viewInstallmentDetails(installment: InstallmentResponseDto): void {
    console.log('View details for installment:', installment);
    // Navigate to details page or open modal
  }

  // Get installments count by status
  getInstallmentsByStatus(status: string): number {
    return this.installments.filter(i => i.status === status).length;
  }

  // Edit functionality
  openEditModal(installment: InstallmentResponseDto): void {
    this.editingInstallment = installment;
    this.editFormData = {
      totalAmountOfProduct: installment.totalAmountOfProduct,
      otherCost: installment.otherCost || 0,
      advanced_paid: installment.advanced_paid,
      installmentMonths: installment.installmentMonths,
      interestRate: installment.interestRate,
      status: installment.status
    };
    this.showEditModal = true;
  }

  closeEditModal(): void {
    this.showEditModal = false;
    this.editingInstallment = null;
    this.editFormData = {};
    this.saving = false;
  }

  updateInstallment(): void {
    if (!this.editingInstallment) return;

    this.saving = true;
    this.installmentService.updateInstallment({
      id: this.editingInstallment.id!,
      body: this.editFormData
    }).subscribe({
      next: (updatedInstallment) => {
        // Update the installment in the list
        const index = this.installments.findIndex(i => i.id === updatedInstallment.id);
        if (index !== -1) {
          this.installments[index] = updatedInstallment;
        }
        this.applyFilters();
        this.successMessage = 'Installment updated successfully!';
        this.closeEditModal();
        setTimeout(() => this.successMessage = null, 3000);
        this.saving = false;
      },
      error: (err) => {
        this.error = 'Failed to update installment';
        this.saving = false;
        console.error('Error updating installment:', err);
      }
    });
  }

  // Delete functionality
  openDeleteModal(installment: InstallmentResponseDto): void {
    this.deletingInstallment = installment;
    this.showDeleteModal = true;
  }

  closeDeleteModal(): void {
    this.showDeleteModal = false;
    this.deletingInstallment = null;
    this.deleting = false;
  }

  deleteInstallment(): void {
    if (!this.deletingInstallment) return;

    this.deleting = true;
    this.installmentService.deleteInstallment({
      id: this.deletingInstallment.id!
    }).subscribe({
      next: () => {
        // Remove from list
        this.installments = this.installments.filter(
          i => i.id !== this.deletingInstallment!.id
        );
        this.applyFilters();
        this.successMessage = 'Installment deleted successfully!';
        this.closeDeleteModal();
        setTimeout(() => this.successMessage = null, 3000);
        this.deleting = false;
      },
      error: (err) => {
        this.error = 'Failed to delete installment';
        this.deleting = false;
        console.error('Error deleting installment:', err);
      }
    });
  }

  // Utility methods
  getStatusBadgeClass(status: string | undefined): string {
    switch (status) {
      case 'ACTIVE': return 'badge bg-success';
      case 'PENDING': return 'badge bg-warning';
      case 'COMPLETED': return 'badge bg-info';
      case 'OVERDUE': return 'badge bg-danger';
      case 'DEFAULTED': return 'badge bg-dark';
      case 'CANCELLED': return 'badge bg-secondary';
      default: return 'badge bg-secondary';
    }
  }

  formatCurrency(amount: number | undefined): string {
    if (!amount) return '৳0.00';
    return '৳' + amount.toLocaleString('en-BD', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }

  formatDate(date: string | undefined): string {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString();
  }

  calculateProgress(installment: InstallmentResponseDto): number {
    const total = installment.totalAmountWithInterest || 0;
    const paid = installment.advanced_paid || 0;
    if (total <= 0) return 0;
    return Math.min((paid / total) * 100, 100);
  }

  // Pagination methods
  goToPage(page: number): void {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
    }
  }

  nextPage(): void {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
    }
  }

  previousPage(): void {
    if (this.currentPage > 1) {
      this.currentPage--;
    }
  }

  clearFilters(): void {
    this.searchTerm = '';
    this.statusFilter = 'ALL';
    this.dateFilter = '';
    this.loadInstallments();
  }

  // Helper for pagination
  getPaginationArray(): number[] {
    return Array.from({ length: this.totalPages }, (_, i) => i + 1);
  }
}