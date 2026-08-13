import React from 'react';
import { useAppContext } from '../../context/AppContext';
import { useNavigate } from 'react-router-dom';

export const WithdrawConfirmScreen: React.FC = () => {
  const { state, doWithdraw } = useAppContext();
  const navigate = useNavigate();
  const amt = state.withdrawAmount || 0;
  const fmt = (n: number) => n.toLocaleString();

  return (
    <div className="light-screen">
      <div className="step-label">Confirm withdrawal</div>
      
      <div className="confirm-box" style={{ width: '100%', marginTop: 16 }}>
        <div className="confirm-row">
          <span>Amount</span>
          <span style={{ fontWeight: 600 }}>₦{fmt(amt)}</span>
        </div>
        <div className="confirm-row">
          <span>To</span>
          <span style={{ fontWeight: 600 }}>{state.bankName} •••• {state.bankAcct.slice(-4) || '4821'}</span>
        </div>
        <div className="confirm-row">
          <span>Arrives</span>
          <span style={{ fontWeight: 600 }}>Within minutes</span>
        </div>
        
        <div className="confirm-row net" style={{ borderTop: '1px solid #e5e7eb', marginTop: 8, paddingTop: 16 }}>
          <span style={{ color: 'var(--forest-green)', fontSize: 16, fontWeight: 700 }}>You'll receive</span>
          <span style={{ color: 'var(--forest-green)', fontSize: 16, fontWeight: 800 }}>₦{fmt(amt)}</span>
        </div>
      </div>

      <button 
        className="primary-btn"
        style={{ marginTop: 32, width: '100%' }} 
        onClick={() => doWithdraw(navigate)}
      >
        Confirm withdrawal
      </button>
    </div>
  );
};
