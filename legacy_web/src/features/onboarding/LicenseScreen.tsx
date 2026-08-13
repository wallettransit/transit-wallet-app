import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../core/store/useAuthStore';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import { ArrowLeft } from 'lucide-react';
import { Button } from '../../ui/Button';

export const LicenseScreen: React.FC = () => {
  const navigate = useNavigate();
  const { user, updateUser, isLoading } = useAuthStore();
  
  const [formData, setFormData] = useState({
    license_number: user?.license_number || ''
  });

  const isFormValid = formData.license_number.length > 5;

  const handleSubmit = async () => {
    if (!isFormValid) return;
    await updateUser({ license_number: formData.license_number });
    navigate('/onboarding/checklist');
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
            Driver License
          </h2>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 16, flex: 1 }}>
          <p style={{ color: 'var(--color-text-muted)', fontSize: 15, marginBottom: 8 }}>
            Please provide your driving license number for verification. (Document upload skipped for MVP).
          </p>
          <div>
            <label style={labelStyle}>License Number *</label>
            <input 
              type="text" 
              value={formData.license_number}
              onChange={e => setFormData({ license_number: e.target.value })}
              style={inputStyle}
              placeholder="e.g. ABC1234567"
            />
          </div>
        </div>

        <div style={{ marginTop: 'auto', paddingTop: 24 }}>
          <Button
            variant="primary"
            disabled={!isFormValid || isLoading}
            onClick={handleSubmit}
            fullWidth
          >
            {isLoading ? 'Saving...' : 'Save and Continue'}
          </Button>
        </div>
      </div>
    </WhiteCardLayout>
  );
};
