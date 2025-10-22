import { AfterViewInit, Component, ElementRef, ViewChild, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Chart, ChartConfiguration } from 'chart.js';

@Component({
  selector: 'app-main-content',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './main-content.component.html',
  styleUrls: ['./main-content.component.css']
})
export class MainContentComponent implements AfterViewInit {
  @ViewChild('lineChartCanvas') lineChartCanvas!: ElementRef<HTMLCanvasElement>;
  @ViewChild('barChartCanvas') barChartCanvas!: ElementRef<HTMLCanvasElement>;
  @Input() isSidebarOpen: boolean = true; // Add this input

  lineChart!: Chart;
  barChart!: Chart;

  stats = [
    { title: 'Total Members', value: '1,254', icon: 'fas fa-users', color: 'primary' },
    { title: 'Active Share Holders', value: '892', icon: 'fas fa-chart-pie', color: 'success' },
    { title: 'Pending Installments', value: '156', icon: 'fas fa-calendar-alt', color: 'warning' },
    { title: 'Product Requests', value: '43', icon: 'fas fa-box', color: 'info' }
  ];

  recentTransactions = [
    { id: 1, member: 'John Doe', type: 'Installment', amount: 500, date: '2024-01-15', status: 'Completed' },
    { id: 2, member: 'Jane Smith', type: 'Product Purchase', amount: 1200, date: '2024-01-14', status: 'Pending' },
    { id: 3, member: 'Mike Johnson', type: 'Share Purchase', amount: 2500, date: '2024-01-13', status: 'Completed' },
    { id: 4, member: 'Sarah Wilson', type: 'Installment', amount: 750, date: '2024-01-12', status: 'Failed' },
    { id: 5, member: 'Tom Brown', type: 'Product Request', amount: 1800, date: '2024-01-11', status: 'Completed' }
  ];

  ngAfterViewInit(): void {
    this.initLineChart();
    this.initBarChart();
  }

  private initLineChart(): void {
    const config: ChartConfiguration<'line'> = {
      type: 'line',
      data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
        datasets: [
          {
            label: 'Revenue',
            data: [65, 59, 80, 81, 56, 55, 40],
            borderColor: '#667eea',
            backgroundColor: 'rgba(102, 126, 234, 0.2)',
            tension: 0.4,
            fill: true,
          },
          {
            label: 'Users',
            data: [28, 48, 40, 19, 86, 27, 90],
            borderColor: '#764ba2',
            backgroundColor: 'rgba(118, 75, 162, 0.2)',
            tension: 0.4,
            fill: true,
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom' }
        }
      }
    };
    this.lineChart = new Chart(this.lineChartCanvas.nativeElement, config);
  }

  private initBarChart(): void {
    const config: ChartConfiguration<'bar'> = {
      type: 'bar',
      data: {
        labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        datasets: [
          {
            label: 'Sales',
            data: [12, 19, 3, 5, 2, 3, 9],
            backgroundColor: 'rgba(102, 126, 234, 0.8)',
            borderColor: '#667eea',
            borderWidth: 1,
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: { beginAtZero: true }
        }
      }
    };
    this.barChart = new Chart(this.barChartCanvas.nativeElement, config);
  }
}