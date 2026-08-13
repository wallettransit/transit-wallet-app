import React from 'react';
import { useNavigate } from 'react-router-dom';

import { useAppContext } from '../../context/AppContext';

export const WithdrawAmtScreen: React.FC = () => {
  const { state, setAmt } = useAppContext();
  const navigate = useNavigate();
  
  return (
    <div className="light-screen">
      <div className="step-label">Amount</div>
      <div className="chip-row">
        <div className="chip" onClick={() => setAmt(5000)}>₦5k</div>
        <div className="chip" onClick={() => setAmt(10000)}>₦10k</div>
        <div className="chip" onClick={() => setAmt(state.balance)}>Max</div>
      </div>
      <div className="center" style={{ marginTop: 32 }}>
        <input 
          type="number" 
          className="big-input" 
          placeholder="0" 
          value={state.withdrawAmount || ''} 
          onChange={e => setAmt(parseInt(e.target.value) || 0)} 
        />
        <button 
          className="primary-btn" 
          disabled={!state.withdrawAmount} 
          style={{ opacity: !state.withdrawAmount ? 0.5 : 1, marginTop: 24, width: '100%' }} 
          onClick={() => state.hasBank ? navigate('/withdraw-confirm') : navigate('/withdraw-bank')}
        >Next</button>
      </div>
    </div>
  );
};
