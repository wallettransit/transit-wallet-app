import { useNavigate } from 'react-router-dom';
import React from 'react';
import { useAppContext } from '../../context/AppContext';
import { Check } from 'lucide-react';

export const WithdrawSuccessScreen: React.FC = () => {
  const { state, setState } = useAppContext();
  const navigate = useNavigate();
  const amt = state.withdrawAmount || 0;
  const fmt = (n: number) => n.toLocaleString();

  return (
    <div className="light-screen center">
      <div style={{ width: 80, height: 80, borderRadius: '50%', background: 'rgba(34, 197, 94, 0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 24 }}>
        <Check size={40} color="var(--forest-green)" />
      </div>
      
      <div style={{ color: 'var(--ink)', fontSize: 24, fontWeight: 700, marginBottom: 16 }}>
        Sent
      </div>
      
      <div style={{ color: 'var(--ink)', fontSize: 56, fontWeight: 800, marginBottom: 24, letterSpacing: '-0.02em' }}>
        ₦{fmt(amt)}
      </div>
      
      <div className="hint-small">
        New balance: ₦{fmt(state.balance)}
      </div>

      <div style={{ flex: 1 }}></div>

      <button 
        className="primary-btn"
        style={{ width: '100%', marginBottom: 32 }} 
        onClick={() => {
          setState({ ...state, withdrawAmount: 0 });
          navigate('/wallet');
        }}
      >
        Done
      </button>
    </div>
  );
};
