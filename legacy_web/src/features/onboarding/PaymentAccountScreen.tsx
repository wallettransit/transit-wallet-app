import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../core/store/useAuthStore';
import { api } from '../../core/api/api';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import { ArrowLeft } from 'lucide-react';
import { Button } from '../../ui/Button';

export const PaymentAccountScreen: React.FC = () => {
  const navigate = useNavigate();
  const { user, updateUser } = useAuthStore();
  const [submitting, setSubmitting] = useState(false);
  
  const [formData, setFormData] = useState({
    bank_name: '',
    account_number: '',
    account_name: ''
  });

  const isFormValid = formData.bank_name && formData.account_number.length >= 10 && formData.account_name;

  const handleSubmit = async () => {
    if (!isFormValid || !user) return;
    setSubmitting(true);
    try {
      await api.addPayoutAccount(user.id, formData);
      // Update account status to reflect progress
      if (user.account_status === 'vehicle_added' || user.account_status === 'phone_verified') {
        await updateUser({ account_status: 'payment_added' });
      }
      navigate('/onboarding/checklist');
    } catch (e) {
      console.error(e);
    } finally {
      setSubmitting(false);
    }
  };

  const inputStyle = { width: '100%', padding: '14px', borderRadius: 12, border: '1px solid var(--color-border)', fontSize: 16, background: 'var(--color-surface-raised)', color: 'var(--color-text)' };
  const labelStyle = { display: 'block', fontSize: 14, fontWeight: 500, color: 'var(--color-text-muted)', marginBottom: 8 };

  return (
    <WhiteCardLayout>
      <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
        <div style={{ display: 'flex', alignItems: 'center', marginBottom: 24 }}>
          <button onClick={() => navigate('/onboarding/checklist')} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0, marginRight: 16, color: 'var(--color-text)' }}>
            <ArrowLeft size={24} />
          </button>
          <h2 style={{ fontFamily: 'var(--font-display)', fontSize: 24, fontWeight: 700, color: 'var(--color-text)', margin: 0 }}>
            Payment Account
          </h2>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 16, flex: 1, overflowY: 'auto', paddingBottom: 24 }}>
          <div>
            <label style={labelStyle}>Bank Name *</label>
            <input 
              type="text" 
              value={formData.bank_name}
              onChange={e => setFormData({...formData, bank_name: e.target.value})}
              style={inputStyle}
              placeholder="e.g. GTBank"
            />
          </div>
          <div>
            <label style={labelStyle}>Account Number *</label>
            <input 
              type="text" 
              value={formData.account_number}
              onChange={e => setFormData({...formData, account_number: e.target.value.replace(/\D/g, '')})}
              maxLength={10}
              style={inputStyle}
              placeholder="10 digit account number"
            />
          </div>
          <div>
            <label style={labelStyle}>Account Name *</label>
            <input 
              type="text" 
              value={formData.account_name}
              onChange={e => setFormData({...formData, account_name: e.target.value})}
              style={inputStyle}
              placeholder="e.g. Ibrahim Musa"
            />
          </div>
        </div>

        <div style={{ marginTop: 'auto', paddingTop: 24 }}>
          <Button
            variant="primary"
            disabled={!isFormValid || submitting}
            onClick={handleSubmit}
            fullWidth
          >
            {submitting ? 'Saving...' : 'Save and Continue'}
          </Button>
        </div>
      </div>
    </WhiteCardLayout>
  );
};
