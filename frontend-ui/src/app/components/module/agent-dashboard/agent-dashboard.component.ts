import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { RouterModule } from '@angular/router';
import { SideBarComponent } from '../../layout/side-bar/side-bar.component';
import { TopBarComponent } from '../../layout/top-bar/top-bar.component';
import { SidebarTopbarService } from '../../../service/sidebar-topbar.service';

// 🧩 Feature components
import { AllMembersComponent } from '../../page/members/all-members/all-members.component';
import { AddNewMemberComponent } from '../../page/members/add-new-member/add-new-member.component';
import { AllProductsComponent } from '../../page/product/all-products/all-products.component';
import { AddProductComponent } from '../../page/product/add-product/add-product.component';
import { AddInstallmentComponent } from '../../page/installment/add-installment/add-installment.component';
import { InstallmentManagementComponent } from '../../page/installment/installment-management/installment-management.component';
import { PaymentScheduleComponent } from '../../page/payment-schedule/payment-schedule/payment-schedule.component';

// ✅ Allowed view types for the agent dashboard
type AgentView =
  | 'all-members' | 'add-member'
  | 'all-products' | 'add-product'
  | 'add-installment' | 'installment-management'
  | 'payment-schedules' | 'record-payment';

@Component({
  selector: 'app-agent-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    SideBarComponent,
    TopBarComponent,
    // 👨‍👩‍👧 Members
    AllMembersComponent,
    AddNewMemberComponent,
    // 🎁 Products
    AllProductsComponent,
    AddProductComponent,
    // 💳 Installments
    AddInstallmentComponent,
    InstallmentManagementComponent,
    // 💰 Payment Schedules
    PaymentScheduleComponent
  ],
  templateUrl: './agent-dashboard.component.html',
  styleUrls: ['./agent-dashboard.component.css']
})
export class AgentDashboardComponent implements OnInit {
  isSidebarCollapsed = false;

  // ✅ Default view
  currentView: AgentView = 'all-members';

  constructor(private sidebarService: SidebarTopbarService) {}

  // ✅ Safe setter for view
  setView(view: AgentView) {
    this.currentView = view;
  }

  // ✅ Filter events coming from the sidebar
  onSubmenuSelected(event: string) {
    const allowedViews: AgentView[] = [
      'all-members', 'add-member',
      'all-products', 'add-product',
      'add-installment', 'installment-management',
      'payment-schedules', 'record-payment'
    ];

    if (allowedViews.includes(event as AgentView)) {
      this.setView(event as AgentView);
    } else {
      console.warn(`Ignored sidebar event: ${event}`);
    }
  }

  ngOnInit() {
    // Sidebar collapse handling
    this.sidebarService.isCollapsed$.subscribe((state: boolean) => {
      this.isSidebarCollapsed = state;
    });

    // 👨‍👩‍👧 Member events
    window.addEventListener('addMember', () => this.currentView = 'add-member');
    window.addEventListener('backToAllMembers', () => this.currentView = 'all-members');

    // 🎁 Product events
    window.addEventListener('addProduct', () => this.currentView = 'add-product');
    window.addEventListener('backToAllProducts', () => this.currentView = 'all-products');

    // 💳 Installment events
    window.addEventListener('addInstallment', () => this.currentView = 'add-installment');
    window.addEventListener('installment-management', () => this.currentView = 'installment-management');

    // 💰 Payment Schedule events
    window.addEventListener('viewPaymentSchedules', () => this.currentView = 'payment-schedules');
    window.addEventListener('recordPayment', () => this.currentView = 'record-payment');
  }
}
