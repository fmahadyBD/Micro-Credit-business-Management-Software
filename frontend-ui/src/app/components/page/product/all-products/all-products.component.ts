// src/app/page/product/all-products/all-products.component.ts
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ProductControllerService } from '../../../../services/services/product-controller.service';
import { Product } from '../../../../services/models/product';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-all-products',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './all-products.component.html',
  styleUrls: ['./all-products.component.css']
})
export class AllProductsComponent implements OnInit {
  products: Product[] = [];
  loading = false;
  error = '';
  isSidebarCollapsed = false;

  // Add base URL for images
  private baseUrl = 'http://localhost:8080';

  constructor(
    private productService: ProductControllerService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit() {
    this.sidebarService.isCollapsed$.subscribe(c => (this.isSidebarCollapsed = c));
    this.loadProducts();
  }

  loadProducts() {
    this.loading = true;
    this.productService.getAllProducts().subscribe({
      next: (products) => {
        this.products = products;
        this.loading = false;
        console.log('Products loaded:', products); // Debug
      },
      error: (error) => {
        this.error = 'Failed to load products';
        this.loading = false;
        console.error('Error loading products:', error);
      }
    });
  }

  /**
   * Get full image URL from relative or absolute path
   */
  getImageUrl(relativePath: string | undefined): string {
    if (!relativePath) {
      return '';
    }
    
    console.log('Original path:', relativePath); // Debug
    
    // If the path is already a full URL, return it as is
    if (relativePath.startsWith('http')) {
      return relativePath;
    }
    
    // If it starts with /uploads, it's already a relative web path
    if (relativePath.startsWith('/uploads')) {
      const fullUrl = `${this.baseUrl}${relativePath}`;
      console.log('Full URL:', fullUrl); // Debug
      return fullUrl;
    }
    
    // If it's an absolute file path (e.g., uploads/products/1/image.jpg)
    // Convert it to web path
    if (relativePath.includes('uploads')) {
      const webPath = '/' + relativePath.replace(/\\/g, '/');
      const fullUrl = `${this.baseUrl}${webPath}`;
      console.log('Converted URL:', fullUrl); // Debug
      return fullUrl;
    }
    
    // Fallback: prepend base URL
    const cleanPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return `${this.baseUrl}/${cleanPath}`;
  }

  /**
   * Handle image loading errors
   */
  handleImageError(event: any): void {
    console.error('Error loading image:', event.target.src);
    event.target.style.display = 'none';
    // Optionally set a placeholder
    // event.target.src = 'assets/images/placeholder.png';
  }

  deleteProduct(productId: number | undefined) {
    if (!productId) return;
    
    if (confirm('Are you sure you want to delete this product?')) {
      this.productService.deleteProduct({ id: productId }).subscribe({
        next: () => {
          this.products = this.products.filter(p => p.id !== productId);
        },
        error: (error) => {
          console.error('Error deleting product:', error);
          alert('Failed to delete product');
        }
      });
    }
  }

  viewProductDetails(productId: number | undefined) {
    if (productId) {
      window.dispatchEvent(new CustomEvent('viewProductDetails', { detail: productId }));
    }
  }

  editProduct(productId: number | undefined) {
    if (productId) {
      window.dispatchEvent(new CustomEvent('editProduct', { detail: productId }));
    }
  }

  dispatchAddProductEvent() {
    window.dispatchEvent(new CustomEvent('addProduct'));
  }
}