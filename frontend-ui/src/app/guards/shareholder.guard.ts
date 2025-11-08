import { CanActivateFn } from '@angular/router';

export const shareholderGuard: CanActivateFn = (route, state) => {
  return true;
};
