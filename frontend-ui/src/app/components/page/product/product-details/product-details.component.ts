// src/app/page/product/product-details/product-details.component.ts
import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Product } from '../../../../services/models/product';
import { ProductControllerService } from '../../../../services/services/product-controller.service';


@Component({
  selector: 'app-product-details',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './product-details.component.html',
  styleUrls: ['./product-details.component.css']
})
export class ProductDetailsComponent implements OnInit {
  @Input() productId!: number;
  
  product?: Product;
  loading = false;
  error = '';

  constructor(private productService: ProductControllerService) {}

  ngOnInit() {
    this.loadProductDetails();
  }

  loadProductDetails() {
    this.loading = true;
    this.productService.getProductById({ id: this.productId }).subscribe({
      next: (product) => {
        this.product = product;
        this.loading = false;
      },
      error: (error) => {
        this.error = 'Failed to load product details';
        this.loading = false;
        console.error('Error loading product:', error);
      }
    });
  }

  goBack() {
    window.dispatchEvent(new CustomEvent('backToAllProducts'));
  }

  editProduct() {
    if (this.product?.id) {
      window.dispatchEvent(new CustomEvent('editProduct', { detail: this.product.id }));
    }
  }
}