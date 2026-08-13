import { useNavigate } from 'react-router-dom';
import React, { useState } from 'react';
import { useAuthStore } from '../../core/store/useAuthStore';
import { ProgressBar } from '../../components/ProgressBar';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import { Button } from '../../ui/Button';
import Bg2 from '../../assets/bg2.png'; // Placeholder image

export const PhoneScreen: React.FC = () => {
  const [phone, setPhone] = useState('');
  const [localError, setLocalError] = useState('');
  const { requestOtp, isLoading, error } = useAuthStore();
  const navigate = useNavigate();

  const handleContinue = async () => {
    if (phone.length < 10) {
      setLocalError('Please enter a valid phone number');
      return;
    }
    
    setLocalError('');
    try {
      await requestOtp(phone);
      navigate('/otp', { state: { phone } });
    } catch (e: any) {
      console.error("Failed to send OTP", e);
    }
  };

  const handlePhoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    let val = e.target.value.replace(/\D/g, '');
    if (val.length > 11) val = val.slice(0, 11);
    setPhone(val);
  };

  const formatPhone = (phone: string) => {
    if (!phone) return '';
    let f = phone;
    if (f.length > 4) f = f.slice(0, 4) + ' ' + f.slice(4);
    if (f.length > 8) f = f.slice(0, 8) + ' ' + f.slice(8);
    return f;
  };

  return (
    <WhiteCardLayout imageSrc={Bg2} currentStep="phone">
      <ProgressBar done={1} total={6} />
      <div className="center" style={{ marginTop: 24, width: '100%' }}>
        <div><b style={{ fontFamily: 'var(--font-display)', fontSize: 24, color: 'var(--color-text)' }}>What's your number?</b></div>
        <input 
          type="tel"
          className="phone-input"
          placeholder="0800 000 0000"
          value={formatPhone(phone)}
          onChange={handlePhoneChange}
        />
        <div className="hint-small" style={{ color: 'var(--color-text-muted)' }}>We'll text a code to confirm it's you</div>
        
        <div style={{ marginTop: 'auto', display: 'flex', flexDirection: 'column', gap: 12, width: '100%' }}>
          {(localError || error) && (
            <div style={{ color: 'var(--warn-rust)', fontSize: 14, textAlign: 'center' }}>
              {localError || error}
            </div>
          )}
          
          <Button 
            variant="primary"
            onClick={handleContinue}
            disabled={phone.length < 10 || isLoading}
            style={{ marginTop: 16 }}
          >
            {isLoading ? 'Sending OTP...' : 'Continue'}
          </Button>
        </div>
      </div>
    </WhiteCardLayout>
  );
};
