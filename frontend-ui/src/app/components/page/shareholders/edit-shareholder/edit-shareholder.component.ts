import { Component, OnInit, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ShareholdersService } from '../../../../services/services/shareholders.service';
import { ShareholderDto } from '../../../../services/models/shareholder-dto';
import { ShareholderUpdateDto } from '../../../../services/models/shareholder-update-dto';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-edit-shareholder',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './edit-shareholder.component.html',
  styleUrls: ['./edit-shareholder.component.css']
})
export class EditShareholderComponent implements OnInit {
  @Input() shareholderId!: number;
  
  shareholder: ShareholderUpdateDto = {};
  loading: boolean = true;
  saving: boolean = false;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  constructor(
    private shareholdersService: ShareholdersService,
    private sidebarService: SidebarTopbarService
  ) { }

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadShareholder();
  }

  loadShareholder(): void {
    this.loading = true;
    this.error = null;
    
    this.shareholdersService.getShareholderById({ id: this.shareholderId }).subscribe({
      next: (data) => {
        const shareholder = data as ShareholderDto;
        
        // Only map the fields that exist in ShareholderUpdateDto
        this.shareholder = {
          name: shareholder.name,
          phone: shareholder.phone,
          nidCard: shareholder.nidCard,
          nominee: shareholder.nominee,
          zila: shareholder.zila,
          house: shareholder.house,
          investment: shareholder.investment,
          totalShare: shareholder.totalShare,
          totalEarning: shareholder.totalEarning,
          currentBalance: shareholder.currentBalance,
          role: shareholder.role,
          status: shareholder.status,
          joinDate: shareholder.joinDate
        };
        
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load shareholder data';
        this.loading = false;
        console.error('Error loading shareholder:', err);
      }
    });
  }

  updateShareholder(): void {
    this.saving = true;
    this.error = null;
    this.successMessage = null;

    // Create a clean update object without id or roi
    const updateData: ShareholderUpdateDto = {
      name: this.shareholder.name,
      phone: this.shareholder.phone,
      nidCard: this.shareholder.nidCard,
      nominee: this.shareholder.nominee,
      zila: this.shareholder.zila,
      house: this.shareholder.house,
      investment: this.shareholder.investment,
      totalShare: this.shareholder.totalShare,
      totalEarning: this.shareholder.totalEarning,
      currentBalance: this.shareholder.currentBalance,
      role: this.shareholder.role,
      status: this.shareholder.status,
      joinDate: this.shareholder.joinDate
    };

    this.shareholdersService.updateShareholder({
      id: this.shareholderId,
      body: updateData
    }).subscribe({
      next: () => {
        this.successMessage = 'Shareholder updated successfully!';
        this.saving = false;
        setTimeout(() => {
          window.dispatchEvent(new CustomEvent('backToAllShareholders'));
        }, 2000);
      },
      error: (err) => {
        this.error = 'Failed to update shareholder';
        this.saving = false;
        console.error('Error updating shareholder:', err);
      }
    });
  }

  onDateChange(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.shareholder.joinDate = input.value;
  }

  goBack(): void {
    window.dispatchEvent(new CustomEvent('backToAllShareholders'));
  }

  formatDate(date: string | undefined): string {
    if (!date) return '';
    return new Date(date).toISOString().split('T')[0];
  }
}