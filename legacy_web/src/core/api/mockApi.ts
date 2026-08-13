// Mock API for Sprint 3

export interface User {
  id: string;
  phone: string;
  first_name?: string;
  last_name?: string;
  dob?: string;
  email?: string;
  address?: string;
  driver_type?: string;
  experience_years?: number;
  operating_location?: string;
  primary_route?: string;
  license_number?: string;
  account_status: string;
}

export interface Shift {
  id: string;
  startTime: string;
  endTime?: string;
  totalEarnings: number;
}

export interface Transaction {
  id: string;
  amount: number;
  time: string;
  status: 'completed' | 'reversed';
  passengerId: string;
}

const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

export const mockApi = {
  login: async (phone: string, otp: string): Promise<{ token: string, user: User }> => {
    await delay(1000);
    if (otp !== '1234' && otp !== '0000') { // Let's accept some mocks
      // For now, accept anything to make testing easy
    }
    return {
      token: 'mock-jwt-token-789',
      user: {
        id: 'driver-1',
        phone,
        first_name: 'Oluwaseun',
        last_name: 'Driver',
        account_status: 'phone_verified'
      }
    };
  },

  startShift: async (): Promise<Shift> => {
    await delay(800);
    return {
      id: `shift-${Date.now()}`,
      startTime: new Date().toISOString(),
      totalEarnings: 0
    };
  },

  endShift: async (_shiftId: string): Promise<void> => {
    await delay(800);
    return;
  },

  reverseTransaction: async (_txId: string): Promise<void> => {
    await delay(1500);
    return;
  }
};
