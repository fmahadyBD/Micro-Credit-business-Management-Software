export interface User {
  id?: number;
  username: string;
  password?: string;
  role: 'ADMIN' | 'AGENT' | 'SHAREHOLDER';
  status: 'ACTIVE' | 'INACTIVE' | 'SUSPENDED' | 'PENDING_VERIFICATION';
  referenceId?: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface DeletedUser {
  id?: number;
  username: string;
  role: string;
  deletedAt?: string;
}