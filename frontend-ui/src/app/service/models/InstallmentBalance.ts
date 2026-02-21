export interface InstallmentBalance {
  installmentId: number;
  totalAmount: number;
  totalPaid: number;
  remainingBalance: number;
  totalPayments: number;
  status: string;
}