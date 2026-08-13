import React, { createContext, useContext, useState, type ReactNode } from 'react';

export const flow = [
  'welcome', 'phone', 'otp', 'route', 'stops', 'live', 'home',
  'wallet', 'withdraw-amt', 'withdraw-bank', 'withdraw-confirm',
  'withdraw-processing', 'withdraw-success', 'history'
];

export interface Stop {
  id: number;
  name: string;
  fare: number;
}

export interface AppState {
  phoneNumber: string;
  otp: string[];
  routeStart: string;
  routeEnd: string;
  stops: Stop[];
  generatedCode: string;
  hasBank: boolean;
  bankName: string;
  bankAcct: string;
  balance: number;
  todayTotal: number;
  rides: number;
  withdrawAmount: number;
}

interface AppContextType {
  state: AppState;
  setState: React.Dispatch<React.SetStateAction<AppState>>;
  setAmt: (n: number) => void;
  saveBank: (navigate: (path: string) => void) => void;
  doWithdraw: (navigate: (path: string) => void) => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [state, setState] = useState<AppState>({
    phoneNumber: '',
    otp: ['', '', '', ''],
    routeStart: 'Ikorodu Garage',
    routeEnd: '',
    stops: [
      { id: 1, name: 'Ojota', fare: 150 },
      { id: 2, name: 'Maryland', fare: 250 },
      { id: 3, name: 'Anthony', fare: 300 },
      { id: 4, name: 'TBS (end)', fare: 400 }
    ],
    generatedCode: '',
    hasBank: false,
    bankName: '',
    bankAcct: '',
    balance: 18200,
    todayTotal: 4850,
    rides: 18,
    withdrawAmount: 0
  });

  const setAmt = (n: number) => {
    setState(prev => ({ ...prev, withdrawAmount: n }));
  };

  const saveBank = (navigate: (path: string) => void) => {
    setState(prev => ({ ...prev, hasBank: true, bankName: 'GTBank', bankAcct: '•••• 4821' }));
    navigate('/withdraw-confirm');
  };

  const doWithdraw = (navigate: (path: string) => void) => {
    const amt = state.withdrawAmount || state.balance;
    setState(prev => ({ ...prev, balance: prev.balance - amt }));
    navigate('/withdraw-processing');
    
    // Simulate API call processing
    setTimeout(() => {
      navigate('/withdraw-success');
    }, 1400);
  };

  return (
    <AppContext.Provider value={{ state, setState, setAmt, saveBank, doWithdraw }}>
      {children}
    </AppContext.Provider>
  );
};

export const useAppContext = () => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useAppContext must be used within an AppProvider');
  }
  return context;
};
