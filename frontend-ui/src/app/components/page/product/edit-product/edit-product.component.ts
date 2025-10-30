// src/app/page/product/edit-product/edit-product.component.ts
import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Product } from '../../../../services/models/product';
import { ProductControllerService } from '../../../../services/services/product-controller.service';


@Component({
  selector: 'app-edit-product',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './edit-product.component.html',
  styleUrls: ['./edit-product.component.css']
})
export class EditProductComponent implements OnInit {
  @Input() productId!: number;
  
  product: Partial<Product> = {};
  loading = false;
  error = '';

  constructor(private productService: ProductControllerService) {}

  ngOnInit() {
    this.loadProduct();
  }

  loadProduct() {
    this.loading = true;
    this.productService.getProductById({ id: this.productId }).subscribe({
      next: (product) => {
        this.product = { ...product };
        this.loading = false;
      },
      error: (error) => {
        this.error = 'Failed to load product';
        this.loading = false;
        console.error('Error loading product:', error);
      }
    });
  }

  onSubmit() {
    if (this.isFormValid()) {
      this.loading = true;
      
      this.productService.updateProduct({ 
        id: this.productId, 
        body: this.product as Product 
      }).subscribe({
        next: (updatedProduct) => {
          this.loading = false;
          alert('Product updated successfully!');
          window.dispatchEvent(new CustomEvent('backToAllProducts'));
        },
        error: (error) => {
          this.loading = false;
          this.error = 'Failed to update product';
          console.error('Error updating product:', error);
        }
      });
    }
  }

  isFormValid(): boolean {
    return !!(this.product.name && this.product.category && this.product.price);
  }

  cancel() {
    window.dispatchEvent(new CustomEvent('backToAllProducts'));
  }
}