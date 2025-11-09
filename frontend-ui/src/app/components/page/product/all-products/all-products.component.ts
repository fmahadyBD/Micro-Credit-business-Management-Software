import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Product } from '../../../../services/models/product';
import { Member } from '../../../../services/models/member';
import { Agent } from '../../../../services/models/agent';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { ProductsService } from '../../../../services/services';
import { MembersService } from '../../../../services/services/members.service';
import { AgentsService } from '../../../../services/services/agents.service';
import { HttpClient } from '@angular/common/http';
import { AuthService } from '../../../../service/auth.service';

@Component({
  selector: 'app-all-products',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './all-products.component.html',
  styleUrls: ['./all-products.component.css']
})
export class AllProductsComponent implements OnInit {
  products: Product[] = [];
  loading: boolean = true;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  // Role-based access
  isAdmin: boolean = false;
  userRole: string = '';

  // View Details Modal
  showDetailsModal: boolean = false;
  selectedProduct: Product | null = null;

  // Edit Modal
  showEditModal: boolean = false;
  editingProduct: Product | null = null;
  editFormData: any = {};
  editSaving: boolean = false;

  // Delete Confirmation
  showDeleteModal: boolean = false;
  deletingProduct: Product | null = null;
  deleteLoading: boolean = false;

  // Member search for edit
  members: Member[] = [];
  filteredMembers: Member[] = [];
  memberSearchTerm: string = '';
  selectedMember: Member | null = null;
  showMemberDropdown: boolean = false;

  // Agent search for edit
  agents: Agent[] = [];
  filteredAgents: Agent[] = [];
  agentSearchTerm: string = '';
  selectedAgent: Agent | null = null;
  showAgentDropdown: boolean = false;

  // Image handling for edit
  selectedFiles: File[] = [];
  imagePreviews: string[] = [];
  existingImages: string[] = [];

  constructor(
    private productService: ProductsService,
    private sidebarService: SidebarTopbarService,
    private membersService: MembersService,
    private agentsService: AgentsService,
    private authService: AuthService,
    private http: HttpClient
  ) { }

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });

    // Get user role from auth service
    this.userRole = this.authService.getRole() || '';
    this.isAdmin = this.authService.isAdmin();

    this.loadMembers();
    this.loadAgents();
    this.loadProducts();
  }

  loadProducts(): void {
    this.loading = true;
    this.error = null;
    this.productService.getAllProducts().subscribe({
      next: (data) => {
        this.products = data;
        console.log('Loaded Products:', data);
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load products';
        this.loading = false;
        console.error('Error loading products:', err);
      }
    });
  }

  loadMembers(): void {
    this.membersService.getAllMembers().subscribe({
      next: (data) => {
        this.members = data;
      },
      error: (err) => {
        console.error('Error loading members:', err);
      }
    });
  }

  loadAgents(): void {
    this.agentsService.getAllAgents().subscribe({
      next: (data) => {
        this.agents = data;
      },
      error: (err) => {
        console.error('Error loading agents:', err);
      }
    });
  }

  hasImages(product: Product): boolean {
    const hasImages = !!(product as any).images && (product as any).images.length > 0;
    const hasImageFilePaths = !!(product as any).imageFilePaths && (product as any).imageFilePaths.length > 0;
    const hasImageUrls = !!(product as any).imageUrls && (product as any).imageUrls.length > 0;
    return hasImages || hasImageFilePaths || hasImageUrls;
  }

  getFirstImageUrl(product: Product): string | null {
    if ((product as any).images && (product as any).images.length > 0) {
      return this.getFullImageUrl((product as any).images[0]);
    }
    if ((product as any).imageFilePaths && (product as any).imageFilePaths.length > 0) {
      return this.getFullImageUrl((product as any).imageFilePaths[0]);
    }
    if ((product as any).imageUrls && (product as any).imageUrls.length > 0) {
      return this.getFullImageUrl((product as any).imageUrls[0]);
    }
    return null;
  }

  getFullImageUrl(imagePath: string): string {
    if (!imagePath) return '';
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    const baseUrl = 'http://localhost:8080';
    return `${baseUrl}${imagePath.startsWith('/') ? '' : '/'}${imagePath}`;
  }

  viewDetails(productId: number): void {
    const product = this.products.find(p => p.id === productId);
    if (product) {
      this.selectedProduct = product;
      this.showDetailsModal = true;
    }
  }

  closeDetailsModal(): void {
    this.showDetailsModal = false;
    this.selectedProduct = null;
  }

  // Edit functionality
  openEditModal(product: Product): void {
    if (!this.isAdmin) return;

    this.editingProduct = product;
    this.editFormData = {
      name: product.name,
      description: product.description,
      category: product.category,
      price: product.price,
      costPrice: product.costPrice,
      isDeliveryRequired: product.isDeliveryRequired
    };

    // Set selected member and agent
    if ((product as any).whoRequestId) {
      const member = this.members.find(m => m.id === (product as any).whoRequestId);
      if (member) {
        this.selectedMember = member;
        this.memberSearchTerm = `${member.name} (${member.phone})`;
      }
    }

    if ((product as any).soldByAgentId) {
      const agent = this.agents.find(a => a.id === (product as any).soldByAgentId);
      if (agent) {
        this.selectedAgent = agent;
        this.agentSearchTerm = `${agent.name} (${agent.phone})`;
      }
    }

    // Load existing images
    this.existingImages = [];
    if ((product as any).images && (product as any).images.length > 0) {
      this.existingImages = (product as any).images.map((img: string) => this.getFullImageUrl(img));
    } else if ((product as any).imageFilePaths && (product as any).imageFilePaths.length > 0) {
      this.existingImages = (product as any).imageFilePaths.map((img: string) => this.getFullImageUrl(img));
    }

    this.selectedFiles = [];
    this.imagePreviews = [];
    this.showEditModal = true;
  }

  closeEditModal(): void {
    this.showEditModal = false;
    this.editingProduct = null;
    this.editFormData = {};
    this.selectedMember = null;
    this.selectedAgent = null;
    this.memberSearchTerm = '';
    this.agentSearchTerm = '';
    this.selectedFiles = [];
    this.imagePreviews = [];
    this.existingImages = [];
    this.editSaving = false;
  }

  // Member search for edit
  onMemberSearch(): void {
    if (!this.memberSearchTerm.trim()) {
      this.filteredMembers = [];
      this.showMemberDropdown = false;
      return;
    }
    const searchLower = this.memberSearchTerm.toLowerCase();
    this.filteredMembers = this.members.filter(member =>
      member.name?.toLowerCase().includes(searchLower) ||
      member.phone?.includes(this.memberSearchTerm) ||
      member.nidCardNumber?.includes(this.memberSearchTerm)
    );
    this.showMemberDropdown = this.filteredMembers.length > 0;
  }

  selectMember(member: Member): void {
    this.selectedMember = member;
    this.memberSearchTerm = `${member.name} (${member.phone})`;
    this.showMemberDropdown = false;
  }

  clearMember(): void {
    this.selectedMember = null;
    this.memberSearchTerm = '';
    this.filteredMembers = [];
  }

  // Agent search for edit
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

  // Image handling for edit
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

  removeNewFile(file: File): void {
    const index = this.selectedFiles.indexOf(file);
    if (index >= 0) {
      this.selectedFiles.splice(index, 1);
      this.imagePreviews.splice(index, 1);
    }
  }

  removeExistingImage(index: number): void {
    this.existingImages.splice(index, 1);
  }

  updateProduct(): void {
    if (!this.editingProduct) return;

    this.editSaving = true;

    const productData: any = {
      name: this.editFormData.name,
      description: this.editFormData.description,
      category: this.editFormData.category,
      price: this.editFormData.price,
      costPrice: this.editFormData.costPrice,
      isDeliveryRequired: this.editFormData.isDeliveryRequired,
      whoRequestId: this.selectedMember ? this.selectedMember.id : null,
      soldByAgentId: this.selectedAgent ? this.selectedAgent.id : null
    };

    const formData = new FormData();
    formData.append('product', JSON.stringify(productData));

    // Add new images
    this.selectedFiles.forEach(file => formData.append('images', file, file.name));

    this.http.put(`http://localhost:8080/api/products/${this.editingProduct.id}`, formData).subscribe({
      next: (res: any) => {
        this.editSaving = false;
        this.successMessage = 'Product updated successfully!';
        this.closeEditModal();
        this.loadProducts();
        setTimeout(() => this.successMessage = null, 3000);
      },
      error: (err) => {
        this.editSaving = false;
        this.error = err.error?.message || 'Failed to update product';
        console.error('Error updating product:', err);
      }
    });
  }

  // Delete functionality
  openDeleteModal(product: Product): void {
    if (!this.isAdmin) return;
    this.deletingProduct = product;
    this.showDeleteModal = true;
  }

  closeDeleteModal(): void {
    this.showDeleteModal = false;
    this.deletingProduct = null;
    this.deleteLoading = false;
  }

  deleteProduct(): void {
    if (!this.deletingProduct) return;

    this.deleteLoading = true;
    this.productService.deleteProduct({ id: this.deletingProduct.id! }).subscribe({
      next: () => {
        this.deleteLoading = false;
        this.successMessage = 'Product deleted successfully!';
        this.closeDeleteModal();
        this.loadProducts();
        setTimeout(() => this.successMessage = null, 3000);
      },
      error: (err) => {
        this.deleteLoading = false;
        this.error = 'Failed to delete product';
        console.error('Error deleting product:', err);
      }
    });
  }

  // Utility methods
  formatDate(date: string | undefined): string {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString();
  }

  getMemberName(product: Product): string {
    return (product.whoRequest as any)?.name || 'N/A';
  }

  getMemberPhone(product: Product): string {
    return (product.whoRequest as any)?.phone || '';
  }

  getAgentName(product: Product): string {
    return (product.soldByAgent as any)?.name || 'N/A';
  }

  getAgentPhone(product: Product): string {
    return (product.soldByAgent as any)?.phone || '';
  }

  getTotalPrice(product: Product): number {
    return (product.price || 0) + (product.costPrice || 0);
  }
}