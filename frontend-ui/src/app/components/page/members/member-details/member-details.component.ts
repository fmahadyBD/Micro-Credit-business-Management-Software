import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MembersService } from '../../../../services/services/members.service';
import { Member } from '../../../../services/models/member';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-member-details',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './member-details.component.html',
  styleUrls: ['./member-details.component.css']
})
export class MemberDetailsComponent implements OnInit {
  @Input() memberId!: number;
  member: Member | null = null;
  loading: boolean = true;
  error: string | null = null;
  isSidebarCollapsed = false;

  // Add base URL for images (adjust according to your API)
  private baseUrl = 'http://localhost:8080'; // Change this to your actual backend URL

  constructor(
    private membersService: MembersService,
    private sidebarService: SidebarTopbarService
  ) { }

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadMemberDetails();
  }

  loadMemberDetails(): void {
    this.loading = true;
    this.error = null;

    this.membersService.getMemberById({ id: this.memberId }).subscribe({
      next: (data: any) => {
        this.member = data;
        this.loading = false;
        // Debug: log image paths
        console.log('Member data:', data);
        console.log('Photo path:', data.photoPath);
        console.log('NID path:', data.nidCardImagePath);
        console.log('Nominee NID path:', data.nomineeNidCardImagePath);
      },
      error: (err) => {
        this.error = 'Failed to load member details';
        this.loading = false;
        console.error('Error loading member:', err);
      }
    });
  }

  // Add this method to get full image URL
  getImageUrl(relativePath: string | undefined): string {
    if (!relativePath) {
      return '';
    }
    
    // If the path is already a full URL, return it as is
    if (relativePath.startsWith('http')) {
      return relativePath;
    }
    
    // If it's a relative path, prepend the base URL
    // Remove leading slash if present to avoid double slashes
    const cleanPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return `${this.baseUrl}/${cleanPath}`;
  }

  // Add this method to handle image loading errors
  handleImageError(event: any): void {
    console.error('Error loading image:', event);
    event.target.style.display = 'none';
    // You could also set a placeholder image here
    // event.target.src = 'assets/images/placeholder.png';
  }

  goBack(): void {
    window.dispatchEvent(new CustomEvent('backToAllMembers'));
  }

  formatDate(date: string | undefined): string {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString();
  }

  getStatusClass(status: string | undefined): string {
    switch (status) {
      case 'ACTIVE': return 'badge bg-success';
      case 'INACTIVE': return 'badge bg-secondary';
      case 'SUSPENDED': return 'badge bg-warning';
      default: return 'badge bg-secondary';
    }
  }
}