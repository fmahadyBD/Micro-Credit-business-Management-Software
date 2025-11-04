export interface ProductResponseDTO {
  id?: number;
  name: string;
  category: string;
  description: string;
  price: number;
  costPrice: number;
  totalPrice: number;
  isDeliveryRequired: boolean;
  dateAdded: string;
  imageFilePaths: string[];
  soldByAgentName: string;
  whoRequestName: string;
  whoRequestId?: number; 
}