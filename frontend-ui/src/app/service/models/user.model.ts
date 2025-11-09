// src/app/models/user.model.ts
export interface User {
  id?: number;
  firstname: string;
  lastname: string;
  username: string;
  password?: string;
  role: 'ADMIN' | 'AGENT' | 'SHAREHOLDER' | 'USER';
  status: 'ACTIVE' | 'INACTIVE' | 'SUSPENDED' | 'PENDING_VERIFICATION';
  referenceId?: number;
  createdDate?: string;
  lastModifiedDate?: string;
}

export interface CreateUserDTO {
  firstname: string;
  lastname: string;
  username: string;
  password: string;
  role: string;
  status: string;
  referenceId?: number;
}

export interface UpdateUserDTO {
  firstname?: string;
  lastname?: string;
  username?: string;
  password?: string;
  role?: string;
  status?: string;
  referenceId?: number;
}
