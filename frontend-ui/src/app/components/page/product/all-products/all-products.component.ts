import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Product } from '../../../../services/models/product';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';
import { ProductsService } from '../../../../services/services';

@Component({
  selector: 'app-all-products',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './all-products.component.html',
  styleUrls: ['./all-products.component.css']
})
export class AllProductsComponent implements OnInit {
  products: Product[] = [];
  loading: boolean = true;
  error: string | null = null;
  successMessage: string | null = null;
  isSidebarCollapsed = false;

  constructor(
    private productService: ProductsService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(collapsed => {
      this.isSidebarCollapsed = collapsed;
    });
    this.loadProducts();
  }

  loadProducts(): void {
    this.loading = true;
    this.error = null;
    this.productService.getAllProducts().subscribe({
      next: (data) => {
        this.products = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load products';
        this.loading = false;
        console.error('Error loading products:', err);
      }
    });
  }

  viewDetails(productId: number): void {
    window.dispatchEvent(new CustomEvent('viewProductDetails', { detail: productId }));
  }

  editProduct(productId: number): void {
    window.dispatchEvent(new CustomEvent('editProduct', { detail: productId }));
  }

  addProduct(): void {
    window.dispatchEvent(new CustomEvent('addProduct'));
  }

  deleteProduct(productId: number): void {
    if (confirm('Are you sure you want to delete this product?')) {
      this.productService.deleteProduct({ id: productId }).subscribe({
        next: () => {
          this.successMessage = 'Product deleted successfully!';
          this.loadProducts();
          setTimeout(() => {
            this.successMessage = null;
          }, 3000);
        },
        error: (err) => {
          this.error = 'Failed to delete product';
          console.error('Error deleting product:', err);
        }
      });
    }
  }

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