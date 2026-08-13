import { useNavigate } from 'react-router-dom';
import React from 'react';
import { useAppContext } from '../../context/AppContext';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import { QrCode } from 'lucide-react';
import Bg1 from '../../assets/bg1.png'; // Placeholder image

export const LiveScreen: React.FC = () => {
  const { state } = useAppContext();
  const navigate = useNavigate();

  return (
    <WhiteCardLayout imageSrc={Bg1} currentStep="live">
      <div className="step-label" style={{ color: 'var(--ink)' }}>Your code</div>
      <div className="center" style={{ gap: 10, width: '100%' }}>
        <div style={{ padding: '24px', background: 'white', borderRadius: 16, border: '2px dashed var(--line)', marginBottom: 16 }}>
          <QrCode size={120} color="var(--forest-green)" strokeWidth={1.5} />
        </div>
        <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: '600', color: 'var(--ink)' }}>{state.routeStart} → {state.routeEnd || 'TBS'}</div>
        <div className="hint-small" style={{ fontSize: 13 }}>Plate LND 412 XA · Code #{state.generatedCode || 'DK-2291'}</div>
        <div style={{ marginTop: 24, width: '100%' }}>
          <button className="primary-btn" onClick={() => navigate('/home')}>Go to dashboard</button>
          <button className="ghost-btn" style={{ color: 'var(--ink)', borderColor: 'var(--ink)' }}>Download to print</button>
        </div>
      </div>
    </WhiteCardLayout>
  );
};
