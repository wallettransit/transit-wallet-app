import React from 'react';
import { useAppContext } from '../../context/AppContext';
import { useNavigate } from 'react-router-dom';

export const WithdrawBankScreen: React.FC = () => {
  const { state, setState, saveBank } = useAppContext();
  const navigate = useNavigate();

  return (
    <div className="light-screen">
      <div className="step-label">Where should this go?</div>
      <div className="hint-small" style={{ marginBottom: 32 }}>Add your bank once — we'll remember it for next time.</div>
      
      <div style={{ display: 'flex', flexDirection: 'column', gap: 16, width: '100%' }}>
        <input 
          className="phone-input"
          placeholder="Bank name" 
          value={state.bankName}
          onChange={e => setState({ ...state, bankName: e.target.value })}
        />
        <input 
          className="phone-input"
          placeholder="Account number" 
          value={state.bankAcct}
          onChange={e => setState({ ...state, bankAcct: e.target.value })}
        />
        <input 
          className="phone-input"
          placeholder="Full name (for BVN match)" 
        />
      </div>

      <button 
        className="primary-btn" 
        style={{ marginTop: 32, width: '100%' }} 
        onClick={() => saveBank(navigate)}
      >
        Save and continue
      </button>
    </div>
  );
};
