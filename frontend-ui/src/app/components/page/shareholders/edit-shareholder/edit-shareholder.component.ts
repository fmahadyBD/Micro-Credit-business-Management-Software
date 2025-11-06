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
        this.shareholder = { ...shareholder };
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

    this.shareholdersService.updateShareholder({
      id: this.shareholderId,
      body: this.shareholder
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