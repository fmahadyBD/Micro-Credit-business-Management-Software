// src/app/page/product/add-product/add-product.component.ts
import { Component, OnInit } from '@angular/core';
import { CommonModule, NgIf, NgFor, NgClass } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Product } from '../../../../services/models/product';
import { ProductControllerService } from '../../../../services/services/product-controller.service';
import { SidebarTopbarService } from '../../../../service/sidebar-topbar.service';

@Component({
  selector: 'app-add-product',
  standalone: true,
  imports: [CommonModule, FormsModule, NgIf, NgFor, NgClass],
  templateUrl: './add-product.component.html',
  styleUrls: ['./add-product.component.css']
})
export class AddProductComponent implements OnInit {
  product: Partial<Product> = {
    name: '',
    category: '',
    description: '',
    price: 0,
    costPrice: 0,
    stock: 0,
    status: 'ACTIVE',
    isDeliveryRequired: false
  };
  
  selectedImages: File[] = [];
  loading = false;
  error = '';
  message: { type: string; text: string } | null = null;
  isSidebarCollapsed = false;

  constructor(
    private productService: ProductControllerService,
    private sidebarService: SidebarTopbarService
  ) {}

  ngOnInit(): void {
    this.sidebarService.isCollapsed$.subscribe(c => (this.isSidebarCollapsed = c));
  }

  onImageSelect(event: any) {
    const files: FileList = event.target.files;
    if (files.length > 0) {
      this.selectedImages = Array.from(files);
    }
  }

  removeImage(index: number) {
    this.selectedImages.splice(index, 1);
  }

  getImageUrl(file: File): string {
    return URL.createObjectURL(file);
  }

  onSubmit() {
    if (this.isFormValid()) {
      this.loading = true;
      this.message = null;
      this.error = '';
      
      if (this.selectedImages.length > 0) {
        // Use createProductWithImages if images are selected
        this.productService.createProductWithImages({ 
          body: {
            product: this.product as Product,
            images: this.selectedImages
          }
        }).subscribe({
          next: (savedProduct) => {
            this.loading = false;
            this.message = { type: 'success', text: 'Product created successfully with images!' };
            this.resetForm();
          },
          error: (error) => {
            this.loading = false;
            this.message = { type: 'error', text: 'Failed to create product with images' };
            console.error('Error creating product:', error);
          }
        });
      } else {
        // Use regular createProduct if no images
        this.productService.createProduct({ 
          body: this.product as Product 
        }).subscribe({
          next: (savedProduct) => {
            this.loading = false;
            this.message = { type: 'success', text: 'Product created successfully!' };
            this.resetForm();
          },
          error: (error) => {
            this.loading = false;
            this.message = { type: 'error', text: 'Failed to create product' };
            console.error('Error creating product:', error);
          }
        });
      }
    } else {
      this.message = { type: 'error', text: 'Please fill all required fields' };
    }
  }

  isFormValid(): boolean {
    return !!(this.product.name && this.product.category && this.product.price);
  }

  cancel() {
    window.dispatchEvent(new CustomEvent('backToAllProducts'));
  }

  private resetForm() {
    this.product = {
      name: '',
      category: '',
      description: '',
      price: 0,
      costPrice: 0,
      stock: 0,
      status: 'ACTIVE',
      isDeliveryRequired: false
    };
    this.selectedImages = [];
    setTimeout(() => {
      this.message = null;
      window.dispatchEvent(new CustomEvent('backToAllProducts'));
    }, 2000);
  }
}