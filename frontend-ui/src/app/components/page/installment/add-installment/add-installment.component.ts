import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { AgentsService } from '../../../../services/services/agents.service';
import { ProductsService } from '../../../../services/services/products.service';
import { InstallmentControllerService } from '../../../../services/services/installment-controller.service';
import { Installment } from '../../../../services/models/installment';
import { Member } from '../../../../services/models/member';
import { Agent } from '../../../../services/models/agent';
import { Product } from '../../../../services/models/product';

@Component({
  selector: 'app-add-installment',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './add-installment.component.html',
  styleUrls: ['./add-installment.component.css']
})
export class AddInstallmentComponent implements OnInit {
  installment: Installment = {
    totalAmountOfProduct: 0,
    otherCost: 0,
    advanced_paid: 0,
    installmentMonths: 12,
    interestRate: 15.0,
    status: 'PENDING',
    given_product_agent: {} as Agent,
    member: {} as Member
  };

  selectedFiles: File[] = [];
  imagePreviews: string[] = [];
  loading: boolean = false;
  successMessage: string | null = null;
  error: string | null = null;
  isSidebarCollapsed = false;

  // Product search
  products: Product[] = [];
  filteredProducts: Product[] = [];
  productSearchTerm: string = '';
  selectedProduct: Product | null = null;
  showProductDropdown: boolean = false;
  loadingProducts: boolean = false;

  // Member (auto-populated from product)
  selectedMember: Member | null = null;

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
    private installmentService: InstallmentControllerService,
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
      next: (data) => {
        this.products = data;
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

  selectProduct(product: Product): void {
    this.selectedProduct = product;
    this.productSearchTerm = `${product.name}`;
    this.showProductDropdown = false;

    // Auto-populate member from product
    if (product.whoRequest) {
      this.selectedMember = product.whoRequest;
    }

    // Auto-fill total amount from product price
    if (product.price) {
      this.installment.totalAmountOfProduct = product.price;
    }
  }

  clearProduct(): void {
    this.selectedProduct = null;
    this.selectedMember = null;
    this.productSearchTerm = '';
    this.filteredProducts = [];
    this.installment.totalAmountOfProduct = 0;
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

    event.target.value = '';
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
    const interest = this.installment.interestRate || 15;
    return total + (total * interest / 100);
  }

  calculateMonthlyPayment(): number {
    const totalWithInterest = this.calculateTotalWithInterest();
    const other = this.installment.otherCost || 0;
    const advance = this.installment.advanced_paid || 0;
    const months = this.installment.installmentMonths || 1;

    const remaining = totalWithInterest + other - advance;
    return remaining > 0 ? remaining / months : 0;
  }

  calculateRemainingAmount(): number {
    const totalWithInterest = this.calculateTotalWithInterest();
    const other = this.installment.otherCost || 0;
    const advance = this.installment.advanced_paid || 0;

    return Math.max(totalWithInterest + other - advance, 0);
  }

  // 🔹 Submit form with images
  onSubmit(): void {
    if (!this.selectedProduct || !this.selectedAgent || !this.selectedMember) {
      this.error = 'Please select product, member, and agent';
      return;
    }

    this.loading = true;
    this.error = null;

    const installmentData: any = {
      product: { id: this.selectedProduct.id },
      member: { id: this.selectedMember.id },
      totalAmountOfProduct: this.installment.totalAmountOfProduct,
      otherCost: this.installment.otherCost,
      advanced_paid: this.installment.advanced_paid,
      installmentMonths: this.installment.installmentMonths,
      interestRate: this.installment.interestRate,
      status: this.installment.status,
      given_product_agent: { id: this.selectedAgent.id }
    };

    const formData = new FormData();

    // Create a Blob with the correct content type
    const installmentBlob = new Blob(
      [JSON.stringify(installmentData)],
      { type: 'application/json' }
    );

    formData.append('installment', installmentBlob);
    this.selectedFiles.forEach(file => formData.append('images', file, file.name));

    this.http.post('http://localhost:8080/api/installments/with-images', formData).subscribe({
      next: (res: any) => {
        this.loading = false;
        this.successMessage = 'Installment created successfully!';
        console.log('Created Installment:', res);
        this.resetForm();
        setTimeout(() => window.dispatchEvent(new CustomEvent('installmentAdded')), 1500);
      },
      error: (err) => {
        this.loading = false;
        console.error('Error creating installment:', err);
        this.error = err.error?.message || 'Failed to create installment';
      }
    });
  }

  resetForm(): void {
    this.installment = {
      totalAmountOfProduct: 0,
      otherCost: 0,
      advanced_paid: 0,
      installmentMonths: 12,
      interestRate: 15.0,
      status: 'PENDING',
      given_product_agent: {} as Agent,
      member: {} as Member
    };
    this.selectedFiles = [];
    this.imagePreviews = [];
    this.clearProduct();
    this.clearAgent();
  }

  cancel(): void {
    window.dispatchEvent(new CustomEvent('cancelAddInstallment'));
  }
}