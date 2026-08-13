import { create } from 'zustand';
import type { Shift, Transaction } from '../api/mockApi';
import { api } from '../api/api';
import { useAuthStore } from './useAuthStore'; // Need this to pass driverId to startShift

interface ShiftState {
  activeShift: Shift | null;
  isLoading: boolean;
  transactions: Transaction[];
  isReversing: boolean;
  startShift: () => Promise<void>;
  endShift: () => Promise<void>;
  simulateTransaction: (amount: number) => void;
  reverseTransaction: (txId: string) => Promise<void>;
}

export const useShiftStore = create<ShiftState>((set, get) => ({
  activeShift: null,
  isLoading: false,
  transactions: [],
  isReversing: false,

  startShift: async () => {
    set({ isLoading: true });
    try {
      // Need driverId
      const driverId = useAuthStore.getState().user?.id;
      if (!driverId) throw new Error("No driver ID");

      const shift = await api.startShift(driverId);
      set({ activeShift: shift, isLoading: false, transactions: [] });
    } catch (err) {
      set({ isLoading: false });
    }
  },

  endShift: async () => {
    const { activeShift } = get();
    if (!activeShift) return;
    set({ isLoading: true });
    try {
      await api.endShift(activeShift.id);
      set({ activeShift: null, isLoading: false });
    } catch (err) {
      set({ isLoading: false });
    }
  },

  simulateTransaction: (amount: number) => {
    const { activeShift, transactions } = get();
    if (!activeShift) return;

    const newTx: Transaction = {
      id: `tx-${Date.now()}`,
      amount,
      time: new Date().toISOString(),
      status: 'completed',
      passengerId: `pass-${Math.floor(Math.random() * 1000)}`
    };

    set({ 
      transactions: [newTx, ...transactions],
      activeShift: {
        ...activeShift,
        totalEarnings: activeShift.totalEarnings + amount
      }
    });
  },

  reverseTransaction: async (txId: string) => {
    set({ isReversing: true });
    try {
      // If it's a real tx from supabase, reverse it. 
      // For simulated transactions (starting with tx-), they don't exist in DB so the API call would fail.
      // We will skip the API call if it's a simulated transaction id for now.
      if (!txId.startsWith('tx-')) {
        await api.reverseTransaction(txId);
      }
      
      const { transactions, activeShift } = get();
      
      const updatedTransactions = transactions.map(tx => 
        tx.id === txId ? { ...tx, status: 'reversed' as const } : tx
      );

      const reversedTx = transactions.find(t => t.id === txId);
      
      set({ 
        transactions: updatedTransactions,
        activeShift: activeShift && reversedTx ? {
          ...activeShift,
          totalEarnings: activeShift.totalEarnings - reversedTx.amount
        } : activeShift,
        isReversing: false 
      });
    } catch (err) {
      set({ isReversing: false });
    }
  }
}));
