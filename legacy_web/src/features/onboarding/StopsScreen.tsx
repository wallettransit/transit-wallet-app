import { useNavigate } from 'react-router-dom';
import React from 'react';
import { useAppContext } from '../../context/AppContext';
import { ProgressBar } from '../../components/ProgressBar';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import Bg4 from '../../assets/bg4.png'; // Placeholder image

export const StopsScreen: React.FC = () => {
  const { state, setState } = useAppContext();
  const navigate = useNavigate();

  const handleFareChange = (id: number, val: number) => {
    setState(prev => ({
      ...prev,
      stops: prev.stops.map(st => st.id === id ? { ...st, fare: val } : st)
    }));
  };

  const generateCode = () => {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = 'DK-';
    for (let i = 0; i < 4; i++) code += chars.charAt(Math.floor(Math.random() * chars.length));
    setState(prev => ({ ...prev, generatedCode: code }));
    navigate('/live');
  };

  return (
    <WhiteCardLayout imageSrc={Bg4} currentStep="stops">
      <ProgressBar done={4} total={6} />
      <div className="step-label" style={{ color: 'var(--ink)' }}>Confirm fares</div>
      <div className="hint-small" style={{ marginBottom: 16 }}>Tap a fare to adjust it</div>
      <div className="card" style={{ width: '100%' }}>
        <div className="stops-list">
          {state.stops.map(stop => (
            <div key={stop.id} className="stop-item" style={{ color: 'var(--ink)' }}>
              <div className="stop-name"><div className="stop-dot"></div>{stop.name}</div>
              <input 
                type="number" 
                className="fare-input" 
                value={stop.fare} 
                onChange={e => handleFareChange(stop.id, parseInt(e.target.value) || 0)} 
              />
            </div>
          ))}
        </div>
      </div>
      <button className="primary-btn" onClick={generateCode}>Confirm & Generate Code</button>
    </WhiteCardLayout>
  );
};
