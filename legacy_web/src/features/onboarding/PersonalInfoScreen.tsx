import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../core/store/useAuthStore';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import { ArrowLeft } from 'lucide-react';
import { Button } from '../../ui/Button';

export const PersonalInfoScreen: React.FC = () => {
  const navigate = useNavigate();
  const { user, updateUser, isLoading } = useAuthStore();
  
  const [formData, setFormData] = useState({
    first_name: user?.first_name || '',
    last_name: user?.last_name || '',
    dob: user?.dob || '',
    email: user?.email || '',
    address: user?.address || ''
  });

  const isFormValid = formData.first_name && formData.last_name && formData.dob;

  const handleSubmit = async () => {
    if (!isFormValid) return;
    await updateUser(formData);
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
            Personal Information
          </h2>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 16, flex: 1, overflowY: 'auto', paddingBottom: 24 }}>
          <div>
            <label style={labelStyle}>First Name *</label>
            <input 
              type="text" 
              value={formData.first_name}
              onChange={e => setFormData({...formData, first_name: e.target.value})}
              style={inputStyle}
              placeholder="e.g. Ibrahim"
            />
          </div>
          <div>
            <label style={labelStyle}>Last Name *</label>
            <input 
              type="text" 
              value={formData.last_name}
              onChange={e => setFormData({...formData, last_name: e.target.value})}
              style={inputStyle}
              placeholder="e.g. Musa"
            />
          </div>
          <div>
            <label style={labelStyle}>Date of Birth *</label>
            <input 
              type="date" 
              value={formData.dob}
              onChange={e => setFormData({...formData, dob: e.target.value})}
              style={{...inputStyle, colorScheme: 'dark'}}
            />
          </div>
          <div>
            <label style={labelStyle}>Email Address (Optional)</label>
            <input 
              type="email" 
              value={formData.email}
              onChange={e => setFormData({...formData, email: e.target.value})}
              style={inputStyle}
              placeholder="name@example.com"
            />
          </div>
          <div>
            <label style={labelStyle}>Home Address (Optional)</label>
            <input 
              type="text" 
              value={formData.address}
              onChange={e => setFormData({...formData, address: e.target.value})}
              style={inputStyle}
              placeholder="123 Example Street"
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
