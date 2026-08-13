import { create } from 'zustand';
import type { User } from '../api/mockApi';
import { api } from '../api/api';

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  login: (phone: string, otp: string) => Promise<void>;
  requestOtp: (phone: string) => Promise<void>;
  verifyOtp: (phone: string, otp: string) => Promise<void>;
  updateUser: (updates: Partial<User>) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  token: null,
  isAuthenticated: false,
  isLoading: false,
  error: null,

  login: async (phone: string, otp: string) => {
    // Keep for backwards compat during refactoring, but ideally use verifyOtp
    await get().verifyOtp(phone, otp);
  },

  requestOtp: async (phone: string) => {
    set({ isLoading: true, error: null });
    try {
      await api.requestOtp(phone);
      set({ isLoading: false });
    } catch (err: any) {
      set({ error: err.message || 'Failed to send OTP', isLoading: false });
      throw err;
    }
  },

  verifyOtp: async (phone: string, otp: string) => {
    set({ isLoading: true, error: null });
    try {
      const response = await api.verifyOtp(phone, otp);
      set({ 
        user: response.user, 
        token: response.token, 
        isAuthenticated: true,
        isLoading: false 
      });
    } catch (err: any) {
      set({ error: err.message || 'OTP Verification failed', isLoading: false });
      throw err;
    }
  },

  updateUser: async (updates: Partial<User>) => {
    const { user } = get();
    if (!user) return;
    set({ isLoading: true, error: null });
    try {
      const updatedUser = await api.updateDriver(user.id, updates);
      set({ user: updatedUser, isLoading: false });
    } catch (err: any) {
      set({ error: err.message || 'Update failed', isLoading: false });
    }
  },

  logout: () => {
    set({ user: null, token: null, isAuthenticated: false });
  }
}));
