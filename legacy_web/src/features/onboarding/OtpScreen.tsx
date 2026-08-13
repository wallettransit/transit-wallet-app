import { useNavigate, useLocation } from 'react-router-dom';
import React, { useState } from 'react';
import { ProgressBar } from '../../components/ProgressBar';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import { useAuthStore } from '../../core/store/useAuthStore';
import { Button } from '../../ui/Button';
import Bg3 from '../../assets/bg3.png'; // Placeholder image

export const OtpScreen: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const phone = location.state?.phone || '';
  
  // Supabase sends 6 digit OTPs by default
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  
  const verifyOtpAction = useAuthStore(s => s.verifyOtp);
  const isLoading = useAuthStore(s => s.isLoading);
  const error = useAuthStore(s => s.error);

  // If someone navigates here directly without a phone number, send them back
  React.useEffect(() => {
    if (!phone) {
      navigate('/phone', { replace: true });
    }
  }, [phone, navigate]);

  const handleOtp = (i: number, v: string) => {
    const newOtp = [...otp];
    newOtp[i] = v;
    setOtp(newOtp);
    if (v && i < 5) {
      const nextInput = document.getElementById(`otp-${i + 1}`);
      nextInput?.focus();
    }
  };

  const formatPhone = (p: string) => {
    if (!p) return '';
    let f = p;
    if (f.length > 4) f = f.slice(0, 4) + ' ' + f.slice(4);
    if (f.length > 8) f = f.slice(0, 8) + ' ' + f.slice(8);
    return f;
  };

  const isComplete = otp.every(v => v !== '');

  const handleVerify = async () => {
    const otpCode = otp.join('');
    try {
      await verifyOtpAction(phone, otpCode);
      navigate('/onboarding/checklist');
    } catch (e) {
      console.error(e);
      // The store handles error state, we can display it
    }
  };

  return (
    <WhiteCardLayout imageSrc={Bg3} currentStep="otp">
      <ProgressBar done={2} total={6} />
      <div className="center" style={{ marginTop: 24, width: '100%' }}>
        <div><b style={{ fontFamily: 'var(--font-display)', fontSize: 24, color: 'var(--color-text)' }}>Enter the code</b></div>
        <div className="hint-small" style={{ color: 'var(--color-text-muted)' }}>Sent to {formatPhone(phone)}</div>
        
        {error && <div style={{ color: 'var(--warn-rust)', fontSize: 14, marginTop: 8 }}>{error}</div>}

        <div className="otp-boxes" style={{ gap: '8px' }}>
          {[0, 1, 2, 3, 4, 5].map(i => (
            <input 
              key={i} 
              id={`otp-${i}`} 
              className={`otp-box ${otp[i] ? 'filled' : ''}`} 
              style={{ width: '40px', height: '48px', fontSize: '20px' }}
              maxLength={1} 
              value={otp[i]} 
              onChange={(e) => handleOtp(i, e.target.value)} 
              disabled={isLoading}
            />
          ))}
        </div>
        <div style={{ width: '100%', marginTop: 'auto' }}>
          <Button 
            variant="primary"
            disabled={!isComplete || isLoading}
            onClick={handleVerify}
            fullWidth
            style={{ marginTop: 16 }}
          >
            {isLoading ? 'Verifying...' : 'Verify'}
          </Button>
        </div>
      </div>
    </WhiteCardLayout>
  );
};
