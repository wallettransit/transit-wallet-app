import React from 'react';
import { useAppContext } from '../../context/AppContext';
import { Loader2 } from 'lucide-react';

export const WithdrawProcessingScreen: React.FC = () => {
  const { state } = useAppContext();

  return (
    <div className="light-screen center">
      <Loader2 className="spinner-icon" size={48} color="var(--forest-green)" />
      <div className="hint-small" style={{ marginTop: 24 }}>Sending to {state.bankName}…</div>
    </div>
  );
};
