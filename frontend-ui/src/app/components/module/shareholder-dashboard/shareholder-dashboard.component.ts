import { Component, OnInit, AfterViewInit, OnDestroy, Renderer2, ElementRef } from '@angular/core';
import { ShareholderDetailsDto } from '../../../services/models/shareholder-details-dto';
import { ShareholdersService } from '../../../services/services/shareholders.service';
import { AuthService } from '../../../service/auth.service';
import { ThemeService } from '../../../service/theme.service.ts.service';
import { CommonModule } from '@angular/common';
import { Chart, registerables } from 'chart.js';

Chart.register(...registerables);

interface Notification {
  icon: string[];
  title: string;
  time: string;
  unread: boolean;
}

interface EarningHistory {
  month: string;
  earnings: number;
  investment: number;
}

@Component({
  selector: 'app-shareholder-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './shareholder-dashboard.component.html',
  styleUrls: ['./shareholder-dashboard.component.css']
})
export class ShareholderDashboardComponent implements OnInit, AfterViewInit, OnDestroy {
  shareholderDetails: ShareholderDetailsDto | null = null;
  loading = false;
  error: string | null = null;

  // Topbar properties
  userName: string = '';
  userEmail: string = '';
  userRole: string = '';
  notifications: Notification[] = [
    { icon: ['fas', 'fa-user'], title: 'New user registered', time: '2 minutes ago', unread: true },
    { icon: ['fas', 'fa-shopping-cart'], title: 'New order received', time: '15 minutes ago', unread: true },
    { icon: ['fas', 'fa-exclamation-circle'], title: 'Server alert', time: '1 hour ago', unread: true },
    { icon: ['fas', 'fa-credit-card'], title: 'Payment overdue', time: '2 hours ago', unread: true },
    { icon: ['fas', 'fa-chart-line'], title: 'Monthly report ready', time: '3 hours ago', unread: true },
  ];

  // Chart instances
  private earningsChart: Chart | null = null;
  private roiChart: Chart | null = null;
  private distributionChart: Chart | null = null;

  // Mock earning history data
  earningHistory: EarningHistory[] = [
    { month: 'Jan', earnings: 12500, investment: 100000 },
    { month: 'Feb', earnings: 18700, investment: 120000 },
    { month: 'Mar', earnings: 22300, investment: 150000 },
    { month: 'Apr', earnings: 28900, investment: 180000 },
    { month: 'May', earnings: 34500, investment: 200000 },
    { month: 'Jun', earnings: 41200, investment: 220000 },
  ];

  // Animation states
  counterValues = {
    investment: 0,
    earnings: 0,
    balance: 0,
    totalValue: 0
  };

  private animationFrame: number | null = null;
  private moneyRainInterval: any = null;
  private chartsInitialized = false;

  constructor(
    private shareholdersService: ShareholdersService,
    private authService: AuthService,
    private themeService: ThemeService,
    private renderer: Renderer2,
    private el: ElementRef
  ) {}

  ngOnInit(): void {
    this.loadUserInfo();
    this.loadShareholderDetails();
    this.themeService.initSystemThemeListener();
  }

  ngAfterViewInit(): void {
    // Initialize money rain effect
    this.initMoneyRain();
  }

  ngOnDestroy(): void {
    // Clean up animations
    if (this.animationFrame !== null) {
      cancelAnimationFrame(this.animationFrame);
    }
    
    // Clean up money rain
    if (this.moneyRainInterval) {
      clearInterval(this.moneyRainInterval);
    }
    
    // Destroy charts
    this.destroyCharts();
  }

  // ---------- MONEY RAIN EFFECT ----------
  private initMoneyRain(): void {
    const moneyRain = this.el.nativeElement.querySelector('#moneyRain');
    if (!moneyRain) return;

    const symbols = ['💰', '💵', '💎', '🪙', '💸', '🏆'];
    
    const createMoney = () => {
      const money = this.renderer.createElement('div');
      this.renderer.addClass(money, 'money-symbol');
      this.renderer.setProperty(money, 'textContent', symbols[Math.floor(Math.random() * symbols.length)]);
      this.renderer.setStyle(money, 'left', Math.random() * 100 + 'vw');
      this.renderer.setStyle(money, 'animationDuration', (Math.random() * 3 + 2) + 's');
      this.renderer.setStyle(money, 'fontSize', (Math.random() * 10 + 15) + 'px');
      this.renderer.setStyle(money, 'opacity', (Math.random() * 0.5 + 0.3).toString());
      
      this.renderer.appendChild(moneyRain, money);
      
      setTimeout(() => {
        this.renderer.removeChild(moneyRain, money);
      }, 5000);
    };
    
    // Create money symbols periodically
    this.moneyRainInterval = setInterval(createMoney, 200);
  }

  // ---------- ANIMATION FUNCTIONS ----------
  animateCounters(): void {
    if (!this.shareholderDetails) return;

    const finalValues = {
      investment: this.shareholderDetails.investment || 0,
      earnings: this.shareholderDetails.totalEarnings || 0,
      balance: this.shareholderDetails.currentBalance || 0,
      totalValue: this.shareholderDetails.totalValue || 0
    };

    const duration = 2000; // 2 seconds
    const startTime = performance.now();

    const animate = (currentTime: number) => {
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);

      // Easing function for smooth animation
      const easeOutQuart = 1 - Math.pow(1 - progress, 4);

      this.counterValues.investment = Math.floor(finalValues.investment * easeOutQuart);
      this.counterValues.earnings = Math.floor(finalValues.earnings * easeOutQuart);
      this.counterValues.balance = Math.floor(finalValues.balance * easeOutQuart);
      this.counterValues.totalValue = Math.floor(finalValues.totalValue * easeOutQuart);

      if (progress < 1) {
        this.animationFrame = requestAnimationFrame(animate);
      }
    };

    this.animationFrame = requestAnimationFrame(animate);
  }

  // ---------- CHART FUNCTIONS ----------
  private destroyCharts(): void {
    if (this.earningsChart) {
      this.earningsChart.destroy();
      this.earningsChart = null;
    }
    if (this.roiChart) {
      this.roiChart.destroy();
      this.roiChart = null;
    }
    if (this.distributionChart) {
      this.distributionChart.destroy();
      this.distributionChart = null;
    }
    this.chartsInitialized = false;
  }

  createCharts(): void {
    // Prevent multiple initializations
    if (this.chartsInitialized) {
      this.destroyCharts();
    }

    // Wait for DOM to be ready
    setTimeout(() => {
      this.createEarningsChart();
      this.createROIChart();
      this.createDistributionChart();
      this.chartsInitialized = true;
    }, 100);
  }

  createEarningsChart(): void {
    const ctx = document.getElementById('earningsChart') as HTMLCanvasElement;
    if (!ctx) {
      console.warn('Earnings chart canvas not found');
      return;
    }

    const labels = this.earningHistory.map(item => item.month);
    const earnings = this.earningHistory.map(item => item.earnings);
    const investments = this.earningHistory.map(item => item.investment);

    this.earningsChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [
          {
            label: 'Monthly Earnings',
            data: earnings,
            borderColor: '#10b981',
            backgroundColor: 'rgba(16, 185, 129, 0.1)',
            borderWidth: 3,
            fill: true,
            tension: 0.4
          },
          {
            label: 'Total Investment',
            data: investments,
            borderColor: '#3b82f6',
            backgroundColor: 'rgba(59, 130, 246, 0.1)',
            borderWidth: 2,
            fill: true,
            tension: 0.4,
            borderDash: [5, 5]
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
          },
          title: {
            display: false
          }
        },
        animation: {
          duration: 2000,
          easing: 'easeOutQuart'
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return '৳' + value.toLocaleString();
              }
            }
          }
        }
      }
    });
  }

  createROIChart(): void {
    const ctx = document.getElementById('roiChart') as HTMLCanvasElement;
    if (!ctx) {
      console.warn('ROI chart canvas not found');
      return;
    }

    const roiData = this.earningHistory.map(item => 
      Number(((item.earnings / item.investment) * 100).toFixed(1))
    );

    this.roiChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: this.earningHistory.map(item => item.month),
        datasets: [{
          label: 'ROI %',
          data: roiData,
          backgroundColor: [
            'rgba(255, 99, 132, 0.8)',
            'rgba(54, 162, 235, 0.8)',
            'rgba(255, 206, 86, 0.8)',
            'rgba(75, 192, 192, 0.8)',
            'rgba(153, 102, 255, 0.8)',
            'rgba(255, 159, 64, 0.8)'
          ],
          borderColor: [
            'rgb(255, 99, 132)',
            'rgb(54, 162, 235)',
            'rgb(255, 206, 86)',
            'rgb(75, 192, 192)',
            'rgb(153, 102, 255)',
            'rgb(255, 159, 64)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          title: {
            display: false
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: 'ROI %'
            }
          }
        },
        animation: {
          duration: 1500,
          easing: 'easeOutBounce'
        }
      }
    });
  }

  createDistributionChart(): void {
    const ctx = document.getElementById('distributionChart') as HTMLCanvasElement;
    if (!ctx || !this.shareholderDetails) {
      console.warn('Distribution chart canvas not found or no shareholder details');
      return;
    }

    const investment = this.shareholderDetails.investment || 0;
    const earnings = this.shareholderDetails.totalEarnings || 0;

    this.distributionChart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Total Investment', 'Total Earnings'],
        datasets: [{
          data: [investment, earnings],
          backgroundColor: [
            'rgba(59, 130, 246, 0.8)',
            'rgba(16, 185, 129, 0.8)'
          ],
          borderColor: [
            'rgb(59, 130, 246)',
            'rgb(16, 185, 129)'
          ],
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '70%',
        plugins: {
          legend: {
            position: 'bottom'
          },
          title: {
            display: false
          }
        },
        animation: {
          animateScale: true,
          animateRotate: true
        }
      }
    });
  }

  // ---------- TOPBAR FUNCTIONS ----------
  loadUserInfo(): void {
    this.userEmail = this.authService.getUserEmail() || 'User';
    this.userName = this.shareholderDetails?.shareholder?.name || this.userEmail.split('@')[0];
    const role = this.authService.getRole();
    this.userRole = role ? this.formatRole(role) : 'Shareholder';
  }

  private formatRole(role: string): string {
    const roleMap: { [key: string]: string } = {
      'ADMIN': 'Administrator',
      'USER': 'User',
      'SHAREHOLDER': 'Shareholder',
      'AGENT': 'Agent'
    };
    return roleMap[role] || role;
  }

  markAsRead(index: number, event: Event): void {
    event.preventDefault();
    event.stopPropagation();
    this.notifications[index].unread = false;
  }

  markAllAsRead(event: Event): void {
    event.preventDefault();
    event.stopPropagation();
    this.notifications.forEach(n => n.unread = false);
  }

  setTheme(theme: 'light' | 'dark' | 'auto', event?: Event): void {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    this.themeService.setTheme(theme);
  }

  getUnreadCount(): number {
    return this.notifications.filter(n => n.unread).length;
  }

  logout(event: Event): void {
    event.preventDefault();
    event.stopPropagation();
    this.authService.logout();
    window.location.href = '/login';
  }

  // ---------- DASHBOARD FUNCTIONS ----------
  loadShareholderDetails(): void {
    const email = this.authService.getUserEmail();
    if (!email) {
      this.error = 'Invalid session. Please log in again.';
      return;
    }

    this.loading = true;
    this.shareholdersService.getShareholderByEmail({ email }).subscribe({
      next: (shareholder) => {
        if (!shareholder?.id) {
          this.error = 'No shareholder found for this account.';
          this.loading = false;
          return;
        }

        this.shareholdersService.getShareholderDetails({ id: shareholder.id }).subscribe({
          next: (details) => {
            this.shareholderDetails = details;
            this.loadUserInfo();
            this.loading = false;
            
            // Start animations after data is loaded
            setTimeout(() => {
              this.animateCounters();
              this.createCharts();
            }, 500);
          },
          error: (err) => {
            console.error('Error loading shareholder details:', err);
            this.error = 'Failed to load shareholder details.';
            this.loading = false;
          }
        });
      },
      error: (err) => {
        console.error('Error finding shareholder by email:', err);
        this.error = 'Failed to find shareholder by email.';
        this.loading = false;
      }
    });
  }

  // ---------- UTILITIES ----------
  formatCurrency(amount: number): string {
    return amount ? `৳${amount.toLocaleString()}` : '৳0';
  }

  formatDate(dateStr: string | null | undefined): string {
    if (!dateStr) return 'N/A';
    try {
      return new Date(dateStr).toLocaleDateString();
    } catch {
      return 'N/A';
    }
  }

  formatROI(): string {
    if (!this.shareholderDetails) return '0%';
    const earnings = this.shareholderDetails.totalEarnings ?? 0;
    const investment = this.shareholderDetails.investment ?? 0;
    if (investment <= 0) return '0%';
    const roi = (earnings / investment) * 100;
    return `${roi.toFixed(2)}%`;
  }

  getStatusClass(status?: string | null): string {
    if (!status) return 'badge bg-secondary';
    return status.toLowerCase() === 'active' ? 'badge bg-success' : 'badge bg-danger';
  }

  getProgressPercentage(): number {
    const earnings = this.shareholderDetails?.totalEarnings ?? 0;
    const totalValue = this.shareholderDetails?.totalValue ?? 0;
    if (totalValue === 0) return 0;
    const progress = (earnings / totalValue) * 100;
    return Math.min(progress, 100);
  }

  getMonthsActive(): number {
    if (!this.shareholderDetails?.activeSince) return 0;
    try {
      const start = new Date(this.shareholderDetails.activeSince);
      const now = new Date();
      return (now.getFullYear() - start.getFullYear()) * 12 + (now.getMonth() - start.getMonth());
    } catch {
      return 0;
    }
  }

  getMonthlyAverage(): string {
    const months = this.getMonthsActive();
    if (!months || !this.shareholderDetails) return '৳0';
    const earnings = this.shareholderDetails.totalEarnings ?? 0;
    const avg = months > 0 ? earnings / months : 0;
    return `৳${avg.toFixed(2)}`;
  }

  goBack(): void {
    window.history.back();
  }
}

/* ============================================
   HTML TEMPLATE (shareholder-dashboard.component.html)
   ============================================
   
   Remove the <script> tag at the bottom of your HTML file.
   The money rain effect is now handled in the TypeScript component.
   
   Everything else in your HTML remains the same.
*/