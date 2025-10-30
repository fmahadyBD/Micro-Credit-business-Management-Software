import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MembersService } from '../../../../services/services/members.service';
import { AgentsService } from '../../../../services/services/agents.service';
import { Product } from '../../../../services/models/product';
import { Member } from '../../../../services/models/member';
import { Agent } from '../../../../services/models/agent';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { ProductsService } from '../../../../services/services';

@Component({
  selector: 'app-add-product',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './add-product.component.html',
  styleUrls: ['./add-product.component.css']
})
export class AddProductComponent implements OnInit {
  product: Product = {
    name: '',
    description: '',
    category: '',
    price: 0,
    costPrice: 0,
    isDeliveryRequired: false
  };

  selectedFiles: File[] = [];
  loading: boolean = false;
  successMessage: string | null = null;
  error: string | null = null;
  isSidebarCollapsed = false;

  // Member search
  members: Member[] = [];
  filteredMembers: Member[] = [];
  memberSearchTerm: string = '';
  selectedMember: Member | null = null;
  showMemberDropdown: boolean = false;
  loadingMembers: boolean = false;

  // Agent search
  agents: Agent[] = [];
  filteredAgents: Agent[] = [];
  agentSearchTerm: string = '';
  selectedAgent: Agent | null = null;
  showAgentDropdown: boolean = false;
  loadingAgents: boolean = false;

  constructor(
    private productService: ProductsService,
    private membersService: MembersService,
    private agentsService: AgentsService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadMembers();
    this.loadAgents();
  }

  // Load all members
  loadMembers(): void {
    this.loadingMembers = true;
    this.membersService.getAllMembers().subscribe({
      next: (data) => {
        this.members = data;
        this.loadingMembers = false;
      },
      error: (err) => {
        console.error('Error loading members:', err);
        this.loadingMembers = false;
      }
    });
  }

  // Load all agents
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

  // Member search functionality
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

  // Agent search functionality
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

  onFileSelected(event: any): void {
    const files: FileList = event.target.files;
    for (let i = 0; i < files.length; i++) {
      this.selectedFiles.push(files[i]);
    }
    event.target.value = '';
  }

  removeFile(file: File): void {
    this.selectedFiles = this.selectedFiles.filter(f => f !== file);
  }

  onSubmit(): void {
    this.loading = true;
    this.error = null;

    if (this.selectedFiles.length > 0) {
      const formData = new FormData();
      
      const productData: any = {
        name: this.product.name,
        description: this.product.description,
        category: this.product.category,
        price: this.product.price,
        costPrice: this.product.costPrice,
        isDeliveryRequired: this.product.isDeliveryRequired
      };

      // Add whoRequest if member is selected
      if (this.selectedMember) {
        productData.whoRequest = { id: this.selectedMember.id };
      }

      // Add soldByAgent if agent is selected
      if (this.selectedAgent) {
        productData.soldByAgent = { id: this.selectedAgent.id };
      }

      formData.append('product', new Blob([JSON.stringify(productData)], {
        type: 'application/json'
      }));

      this.selectedFiles.forEach((file) => {
        formData.append('images', file, file.name);
      });

      const params: any = {
        body: formData
      };

      this.productService.createProductWithImages(params).subscribe({
        next: (createdProduct) => {
          this.loading = false;
          this.successMessage = 'Product created successfully with images!';
          this.resetForm();
          setTimeout(() => {
            window.dispatchEvent(new CustomEvent('productAdded'));
          }, 1500);
        },
        error: (err) => {
          this.loading = false;
          this.error = 'Failed to create product with images';
          console.error('Error creating product:', err);
        }
      });
    } else {
      const productToSave: any = {
        ...this.product
      };

      // Add whoRequest if member is selected
      if (this.selectedMember) {
        productToSave.whoRequest = { id: this.selectedMember.id };
      }

      // Add soldByAgent if agent is selected
      if (this.selectedAgent) {
        productToSave.soldByAgent = { id: this.selectedAgent.id };
      }

      this.productService.createProduct({ body: productToSave }).subscribe({
        next: (createdProduct) => {
          this.loading = false;
          this.successMessage = 'Product created successfully!';
          this.resetForm();
          setTimeout(() => {
            window.dispatchEvent(new CustomEvent('productAdded'));
          }, 1500);
        },
        error: (err) => {
          this.loading = false;
          this.error = 'Failed to create product';
          console.error('Error creating product:', err);
        }
      });
    }
  }

  resetForm(): void {
    this.product = {
      name: '',
      description: '',
      category: '',
      price: 0,
      costPrice: 0,
      isDeliveryRequired: false
    };
    this.selectedFiles = [];
    this.clearMember();
    this.clearAgent();
  }

  cancel(): void {
    window.dispatchEvent(new CustomEvent('cancelAddProduct'));
  }
}