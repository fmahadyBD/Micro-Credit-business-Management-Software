export interface ProductRequestDTO {
  name: string;
  category: string;
  description: string;
  price: number;
  costPrice: number;
  isDeliveryRequired: boolean;
  soldByAgentId: number;
  whoRequestId: number;
}