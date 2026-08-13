import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../core/store/useAuthStore';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import { ArrowLeft } from 'lucide-react';
import { Button } from '../../ui/Button';

export const DriverInfoScreen: React.FC = () => {
  const navigate = useNavigate();
  const { user, updateUser, isLoading } = useAuthStore();
  
  const [formData, setFormData] = useState({
    driver_type: user?.driver_type || 'Danfo',
    experience_years: user?.experience_years?.toString() || '',
    operating_location: user?.operating_location || '',
    primary_route: user?.primary_route || ''
  });

  const isFormValid = formData.driver_type && formData.operating_location;

  const handleSubmit = async () => {
    if (!isFormValid) return;
    await updateUser({
      ...formData,
      experience_years: parseInt(formData.experience_years) || 0
    });
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
            Driver Information
          </h2>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 16, flex: 1, overflowY: 'auto', paddingBottom: 24 }}>
          <div>
            <label style={labelStyle}>Driver Type *</label>
            <select 
              value={formData.driver_type}
              onChange={e => setFormData({...formData, driver_type: e.target.value})}
              style={inputStyle}
            >
              <option value="Danfo">Danfo</option>
              <option value="Keke">Keke</option>
              <option value="Okada">Okada</option>
              <option value="Bus">Bus</option>
              <option value="Other">Other</option>
            </select>
          </div>
          <div>
            <label style={labelStyle}>Years of Experience</label>
            <input 
              type="number" 
              value={formData.experience_years}
              onChange={e => setFormData({...formData, experience_years: e.target.value})}
              style={inputStyle}
              placeholder="e.g. 5"
            />
          </div>
          <div>
            <label style={labelStyle}>Operating Location *</label>
            <input 
              type="text" 
              value={formData.operating_location}
              onChange={e => setFormData({...formData, operating_location: e.target.value})}
              style={inputStyle}
              placeholder="e.g. Lagos Mainland"
            />
          </div>
          <div>
            <label style={labelStyle}>Primary Route</label>
            <input 
              type="text" 
              value={formData.primary_route}
              onChange={e => setFormData({...formData, primary_route: e.target.value})}
              style={inputStyle}
              placeholder="e.g. Yaba - CMS"
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
