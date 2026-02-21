import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { ProductsService } from '../../../../services/services/products.service';
import { AgentsService } from '../../../../services/services/agents.service';
import { MembersService } from '../../../../services/services/members.service';
import { Product } from '../../../../services/models/product';
import { Agent } from '../../../../services/models/agent';
import { Member } from '../../../../services/models/member';
import { InstallmentCreateDto } from '../../../../services/models/installment-create-dto';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { environment } from '../../../../../environments/environment';

// Extended Product interface to include member details from ProductResponseDTO
interface ProductWithMemberDetails extends Product {
  whoRequestId?: number;
  whoRequestName?: string;
  whoRequestPhone?: string;
  whoRequestNidCardNumber?: string;
  whoRequestVillage?: string;
  whoRequestZila?: string;
}

@Component({
  selector: 'app-add-installment',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './add-installment.component.html',
  styleUrls: ['./add-installment.component.css']
})
export class AddInstallmentComponent implements OnInit {
  installment: any = {
    totalAmountOfProduct: 0,
    otherCost: 0,
    advanced_paid: 0,
    installmentMonths: 1,
    interestRate: 0,
    status: 'PENDING'
  };

  selectedFiles: File[] = [];
  imagePreviews: string[] = [];
  loading: boolean = false;
  successMessage: string | null = null;
  error: string | null = null;
  isSidebarCollapsed = false;

  // Product search
  products: ProductWithMemberDetails[] = [];
  filteredProducts: ProductWithMemberDetails[] = [];
  productSearchTerm: string = '';
  selectedProduct: ProductWithMemberDetails | null = null;
  showProductDropdown: boolean = false;
  loadingProducts: boolean = false;

  // Member (auto-populated from product)
  selectedMember: Member | null = null;
  memberName: string = '';

  // Agent search
  agents: Agent[] = [];
  filteredAgents: Agent[] = [];
  agentSearchTerm: string = '';
  selectedAgent: Agent | null = null;
  showAgentDropdown: boolean = false;
  loadingAgents: boolean = false;

  constructor(
    private http: HttpClient,
    private productsService: ProductsService,
    private agentsService: AgentsService,
    private membersService: MembersService,
    private sidebarService: SidebarTopbarService
  ) { }

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadProducts();
    this.loadAgents();
  }

  // 🔹 Load products from backend
  loadProducts(): void {
    this.loadingProducts = true;
    this.productsService.getAllProducts().subscribe({
      next: (data: any) => {
        this.products = data;
        console.log('Loaded products:', this.products);
        this.loadingProducts = false;
      },
      error: (err) => {
        console.error('Error loading products:', err);
        this.loadingProducts = false;
      }
    });
  }

  // 🔹 Load agents from backend
  loadAgents(): void {
    this.loadingAgents = true;
    this.agentsService.getAllAgents().subscribe({
      next: (data) => {
        this.agents = data;
        this.loadingAgents = false;
      },
      error: (err) => {
        console.error('Error loading agents:', err);
        this.loadingAgents = false;
      }
    });
  }

  // 🔹 Product Search
  onProductSearch(): void {
    if (!this.productSearchTerm.trim()) {
      this.filteredProducts = [];
      this.showProductDropdown = false;
      return;
    }
    const searchLower = this.productSearchTerm.toLowerCase();
    this.filteredProducts = this.products.filter(product =>
      product.name?.toLowerCase().includes(searchLower) ||
      product.category?.toLowerCase().includes(searchLower)
    );
    this.showProductDropdown = this.filteredProducts.length > 0;
  }

  selectProduct(product: ProductWithMemberDetails): void {
    this.selectedProduct = product;
    this.productSearchTerm = `${product.name} (${product.category})`;
    this.showProductDropdown = false;

    console.log('Selected product:', product);

    // Try to get member from ProductResponseDTO fields first
    if (product.whoRequestId && product.whoRequestName) {
      // Create member object from ProductResponseDTO fields
      this.selectedMember = {
        id: product.whoRequestId,
        name: product.whoRequestName,
        phone: product.whoRequestPhone || '',
        nidCardNumber: product.whoRequestNidCardNumber || '',
        village: product.whoRequestVillage || '',
        zila: product.whoRequestZila || '',
        nomineeName: '',
        nomineeNidCardNumber: '',
        nomineePhone: ''
      };
      this.memberName = `${product.whoRequestName} (${product.whoRequestPhone})`;
      console.log('Member auto-selected from DTO:', this.selectedMember);
    }
    // Fallback: Check if whoRequest object exists
    else if (product.whoRequest && product.whoRequest.id) {
      this.selectedMember = product.whoRequest;
      this.memberName = `${product.whoRequest.name} (${product.whoRequest.phone})`;
      console.log('Member auto-selected from nested object:', this.selectedMember);
    }
    else {
      this.selectedMember = null;
      this.memberName = 'No member assigned';
      console.log('No member assigned to this product');
    }

    // Auto-fill total amount
    if (product.price) {
      this.installment.totalAmountOfProduct = product.price;
    }
  }

  clearProduct(): void {
    this.selectedProduct = null;
    this.productSearchTerm = '';
    this.filteredProducts = [];
    this.selectedMember = null;
    this.memberName = '';
  }

  // 🔹 Agent Search
  onAgentSearch(): void {
    if (!this.agentSearchTerm.trim()) {
      this.filteredAgents = [];
      this.showAgentDropdown = false;
      return;
    }
    const searchLower = this.agentSearchTerm.toLowerCase();
    this.filteredAgents = this.agents.filter(agent =>
      agent.name?.toLowerCase().includes(searchLower) ||
      agent.phone?.includes(this.agentSearchTerm) ||
      agent.nidCard?.includes(this.agentSearchTerm)
    );
    this.showAgentDropdown = this.filteredAgents.length > 0;
  }

  selectAgent(agent: Agent): void {
    this.selectedAgent = agent;
    this.agentSearchTerm = `${agent.name} (${agent.phone})`;
    this.showAgentDropdown = false;
  }

  clearAgent(): void {
    this.selectedAgent = null;
    this.agentSearchTerm = '';
    this.filteredAgents = [];
  }

  // 🔹 Handle image selection + preview
  onFileSelected(event: any): void {
    const files: FileList = event.target.files;

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      this.selectedFiles.push(file);

      const reader = new FileReader();
      reader.onload = (e: any) => {
        this.imagePreviews.push(e.target.result);
      };
      reader.readAsDataURL(file);
    }

    event.target.value = ''; // reset input
  }

  removeFile(file: File): void {
    const index = this.selectedFiles.indexOf(file);
    if (index >= 0) {
      this.selectedFiles.splice(index, 1);
      this.imagePreviews.splice(index, 1);
    }
  }

  // 🔹 Calculation methods
  calculateTotalWithInterest(): number {
    const total = this.installment.totalAmountOfProduct || 0;
    const otherCost = this.installment.otherCost || 0;
    const rate = this.installment.interestRate || 0;
    const baseAmount = total + otherCost;
    return baseAmount + (baseAmount * rate / 100);
  }

  calculateMonthlyPayment(): number {
    const totalWithInterest = this.calculateTotalWithInterest();
    const months = this.installment.installmentMonths || 1;
    return totalWithInterest / months;
  }

  calculateRemainingAmount(): number {
    const totalWithInterest = this.calculateTotalWithInterest();
    const advanced = this.installment.advanced_paid || 0;
    return totalWithInterest - advanced;
  }

  // 🔹 Submit form with images
  onSubmit(): void {
    // Validation
    if (!this.selectedProduct) {
      this.error = 'Please select a product';
      return;
    }

    if (!this.selectedMember) {
      this.error = 'Please select a member (product must have an associated member)';
      return;
    }

    if (!this.selectedAgent) {
      this.error = 'Please select an agent';
      return;
    }

    this.loading = true;
    this.error = null;
    this.successMessage = null;

    // ✅ FIXED: Using correct field names matching InstallmentCreateDTO
    const installmentData: InstallmentCreateDto = {
      totalAmountOfProduct: this.installment.totalAmountOfProduct,
      otherCost: this.installment.otherCost || 0,
      advanced_paid: this.installment.advanced_paid,
      installmentMonths: this.installment.installmentMonths,
      interestRate: this.installment.interestRate,
      status: this.installment.status,
      productId: this.selectedProduct.id!,
      memberId: this.selectedMember.id!,
      agentId: this.selectedAgent.id!  // ✅ Changed from deliveryAgentId to agentId
    };

    console.log('Submitting installment data:', installmentData);

    const formData = new FormData();
    formData.append('installment', JSON.stringify(installmentData));

    // Add images if any
    this.selectedFiles.forEach(file => {
      formData.append('images', file, file.name);
    });

    this.http.post(`${environment.apiBaseUrl}/installments/with-images`, formData)
      .subscribe({
        next: (res: any) => {
          this.loading = false;
          this.successMessage = 'Installment created successfully!';
          console.log('Created Installment:', res);
          this.resetForm();

          // Notify parent component or refresh list
          setTimeout(() => {
            window.dispatchEvent(new CustomEvent('installmentAdded'));
          }, 1500);
        },
        error: (err) => {
          this.loading = false;
          console.error('Error creating installment:', err);
          console.error('Error details:', err.error);
          this.error = err.error?.message || 'Failed to create installment. Please check the console for details.';
        }
      });
  }

  resetForm(): void {
    this.installment = {
      totalAmountOfProduct: 0,
      otherCost: 0,
      advanced_paid: 0,
      installmentMonths: 1,
      interestRate: 0,
      status: 'PENDING'
    };
    this.selectedFiles = [];
    this.imagePreviews = [];
    this.clearProduct();
    this.clearAgent();
    this.successMessage = null;
    this.error = null;
  }

  cancel(): void {
    window.dispatchEvent(new CustomEvent('cancelAddInstallment'));
  }
}