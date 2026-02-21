import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { RouterModule } from '@angular/router';

import { SideBarComponent } from '../../layout/side-bar/side-bar.component';
import { TopBarComponent } from '../../layout/top-bar/top-bar.component';
import { AdminMainComponent } from '../admin-main/admin-main.component';

import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';

// import { AddNewUserComponent } from '../../page/user/add-new-user/add-new-user.component';
import { AllUsersComponent } from '../../page/user/all-users/all-users.component';
// import { DeletedUsersComponent } from '../../page/user/deleted-users/deleted-users.component';
import { EditUserComponent } from '../../page/user/edit-user/edit-user.component';
import { UserDetailsComponent } from '../../page/user/user-details/user-details.component';

import { AddNewMemberComponent } from '../../page/members/add-new-member/add-new-member.component';
import { AllMembersComponent } from '../../page/members/all-members/all-members.component';
import { EditMemberComponent } from '../../page/members/edit-member/edit-member.component';
import { MemberDetailsComponent } from '../../page/members/member-details/member-details.component';

import { AddNewAgentComponent } from '../../page/agent/add-new-agent/add-new-agent.component';
import { AllAgentsComponent } from '../../page/agent/all-agents/all-agents.component';
import { UpdateAgentComponent } from '../../page/agent/update-agent/update-agent.component';
import { DetailsAgentComponent } from '../../page/agent/details-agent/details-agent.component';
import { AllProductsComponent } from '../../page/product/all-products/all-products.component';
import { AddProductComponent } from '../../page/product/add-product/add-product.component';
import { AddInstallmentComponent } from '../../page/installment/add-installment/add-installment.component';
import { PaymentScheduleComponent } from '../../page/payment-schedule/payment-schedule/payment-schedule.component';
import { AllShareholdersComponent } from '../../page/shareholders/all-shareholders/all-shareholders.component';
import { EditShareholderComponent } from '../../page/shareholders/edit-shareholder/edit-shareholder.component';
import { ShareholderDetailsComponent } from '../../page/shareholders/shareholder-details/shareholder-details.component';
import { AddShareholderComponent } from '../../page/shareholders/add-shareholder/add-shareholder.component';
import { InstallmentManagementComponent } from '../../page/installment/installment-management/installment-management.component';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    SideBarComponent,
    TopBarComponent,
    AdminMainComponent,
    // 👥 Users
    AllUsersComponent,
    // AddNewUserComponent,
    // DeletedUsersComponent,
    UserDetailsComponent,
    EditUserComponent,
    // 👨‍👩‍👧 Members
    AllMembersComponent,
    AddNewMemberComponent,
    MemberDetailsComponent,
    EditMemberComponent,
    // 🧑‍💼 Agents
    AllAgentsComponent,
    AddNewAgentComponent,
    UpdateAgentComponent,
    DetailsAgentComponent,
    // 🎁 Products
    AllProductsComponent,
    AddProductComponent,
    // 💳 Installments
    AddInstallmentComponent,
    InstallmentManagementComponent,
    // 💰 Payment Schedules
    PaymentScheduleComponent,
    // 👔 Shareholders
    AllShareholdersComponent,
    ShareholderDetailsComponent,
    EditShareholderComponent,
    AddShareholderComponent
  ],
  templateUrl: './admin-dashboard.component.html',
  styleUrls: ['./admin-dashboard.component.css']
})
export class AdminDashboardComponent implements OnInit {
  isSidebarCollapsed = false;

  currentView:
    | 'dashboard'
    | 'all-users' | 'add-user' | 'deleted-users'
    | 'all-members' | 'add-member'
    | 'all-agents' | 'add-agent'
    | 'user-details' | 'edit-user'
    | 'member-details' | 'edit-member'
    | 'all-products' | 'add-product'
    | 'agent-details' | 'edit-agent'
    | 'add-installment' | 'installment-management'
    | 'payment-schedules' | 'record-payment'
    | 'all-shareholders' | 'shareholder-details' | 'edit-shareholder' | 'add-shareholder'
    = 'dashboard';

  selectedUserId: number | null = null;
  selectedMemberId: number | null = null;
  selectedAgentId: number | null = null;
  selectedProductId: number | null = null;
  selectedShareholderId: number | null = null;

  constructor(private sidebarService: SidebarTopbarService) { }

  setView(view: any) {
    this.currentView = view;
  }

  ngOnInit() {
    // Sidebar collapse handling
    this.sidebarService.isCollapsed$.subscribe((state: boolean) => {
      this.isSidebarCollapsed = state;
    });

    // 🧍 User events
    window.addEventListener('viewUserDetails', (e: any) => {
      this.selectedUserId = e.detail;
      this.currentView = 'user-details';
    });

    window.addEventListener('editUser', (e: any) => {
      this.selectedUserId = e.detail;
      this.currentView = 'edit-user';
    });

    window.addEventListener('backToAllUsers', () => {
      this.selectedUserId = null;
      this.currentView = 'all-users';
    });

    // 👨‍👩‍👧 Member events
    window.addEventListener('viewMemberDetails', (e: any) => {
      this.selectedMemberId = e.detail;
      this.currentView = 'member-details';
    });

    window.addEventListener('editMember', (e: any) => {
      this.selectedMemberId = e.detail;
      this.currentView = 'edit-member';
    });

    window.addEventListener('backToAllMembers', () => {
      this.selectedMemberId = null;
      this.currentView = 'all-members';
    });

    // 🧑‍💼 Agent events
    window.addEventListener('viewAgentDetails', (e: any) => {
      this.selectedAgentId = e.detail;
      this.currentView = 'agent-details';
    });

    window.addEventListener('editAgent', (e: any) => {
      this.selectedAgentId = e.detail;
      this.currentView = 'edit-agent';
    });

    window.addEventListener('addAgent', () => {
      this.currentView = 'add-agent';
    });

    window.addEventListener('backToAllAgents', () => {
      this.selectedAgentId = null;
      this.currentView = 'all-agents';
    });

    // 🎁 Product events
    window.addEventListener('addProduct', () => {
      this.currentView = 'add-product';
    });

    window.addEventListener('backToAllProducts', () => {
      this.selectedProductId = null;
      this.currentView = 'all-products';
    });

    // 💳 Installment events
    window.addEventListener('addInstallment', () => {
      this.currentView = 'add-installment';
    });

    window.addEventListener('installment-management', () => {
      this.currentView = 'installment-management';
    });

    // 💰 Payment Schedule events
    window.addEventListener('viewPaymentSchedules', () => {
      this.currentView = 'payment-schedules';
    });

    window.addEventListener('recordPayment', () => {
      this.currentView = 'record-payment';
    });

    // 👔 Shareholder events
    window.addEventListener('viewShareholderDetails', (e: any) => {
      this.selectedShareholderId = e.detail;
      this.currentView = 'shareholder-details';
    });

    window.addEventListener('editShareholder', (e: any) => {
      this.selectedShareholderId = e.detail;
      this.currentView = 'edit-shareholder';
    });

    window.addEventListener('addShareholder', () => {
      this.currentView = 'add-shareholder';
    });

    window.addEventListener('backToAllShareholders', () => {
      this.selectedShareholderId = null;
      this.currentView = 'all-shareholders';
    });
  }
}