import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MembersService } from '../../../../services/services/members.service';
import { AgentsService } from '../../../../services/services/agents.service';
import { Product } from '../../../../services/models/product';
import { Member } from '../../../../services/models/member';
import { Agent } from '../../../../services/models/agent';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../../environments/environment';

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
  };

  selectedFiles: File[] = [];
  imagePreviews: string[] = [];
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
    private http: HttpClient,
    private membersService: MembersService,
    private agentsService: AgentsService,
    private sidebarService: SidebarTopbarService
  ) { }

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadMembers();
    this.loadAgents();
  }

  // 🔹 Load members from backend
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

  // 🔹 Member Search
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

  // 🔹 Submit form with images
  onSubmit(): void {
    if (!this.product.name || this.product.price === undefined) return;

    this.loading = true;
    this.error = null;

    // const productData: any = {
    //   name: this.product.name,
    //   description: this.product.description,
    //   category: this.product.category,
    //   price: this.product.price,
    //   costPrice: this.product.costPrice,
    //   isDeliveryRequired: this.product.isDeliveryRequired,
    //   whoRequest: this.selectedMember ? { id: this.selectedMember.id } : undefined,
    //   soldByAgent: this.selectedAgent ? { id: this.selectedAgent.id } : undefined
    // };

    const productData: any = {
      name: this.product.name,
      description: this.product.description,
      category: this.product.category,
      price: this.product.price,
      costPrice: this.product.costPrice,
      isDeliveryRequired: this.product.isDeliveryRequired,
      whoRequestId: this.selectedMember ? this.selectedMember.id : null,
      soldByAgentId: this.selectedAgent ? this.selectedAgent.id : null
    };


    const formData = new FormData();
    formData.append('product', JSON.stringify(productData));
    this.selectedFiles.forEach(file => formData.append('images', file, file.name));

    this.http.post(`${environment.apiBaseUrl}/products/with-images`, formData)
      .subscribe({
        next: (res: any) => {
          this.loading = false;
          this.successMessage = 'Product created successfully!';
          console.log('Created Product:', res.product);
          this.resetForm();
          setTimeout(() => window.dispatchEvent(new CustomEvent('productAdded')), 1500);
        },
        error: (err) => {
          this.loading = false;
          console.error('Error creating product:', err);
          this.error = err.error?.message || 'Failed to create product';
        }
      });
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
    this.imagePreviews = [];
    this.clearMember();
    this.clearAgent();
  }

  cancel(): void {
    window.dispatchEvent(new CustomEvent('cancelAddProduct'));
  }
}
