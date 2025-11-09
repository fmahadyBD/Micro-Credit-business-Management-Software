export interface User {
  id?: number;
  firstname: string;
  lastname: string;
  username: string;
  role: 'USER' | 'ADMIN';
  status: 'ACTIVE' | 'INACTIVE' | 'SUSPENDED' | 'PENDING_VERIFICATION';
}
