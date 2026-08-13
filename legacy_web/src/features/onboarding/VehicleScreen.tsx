import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../core/store/useAuthStore';
import { api } from '../../core/api/api';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import { ArrowLeft } from 'lucide-react';
import { Button } from '../../ui/Button';

export const VehicleScreen: React.FC = () => {
  const navigate = useNavigate();
  const { user, updateUser } = useAuthStore();
  const [submitting, setSubmitting] = useState(false);
  
  const [formData, setFormData] = useState({
    type: 'Danfo',
    registration_number: '',
    color: '',
    model: '',
    year: ''
  });

  const isFormValid = formData.registration_number && formData.model;

  const handleSubmit = async () => {
    if (!isFormValid || !user) return;
    setSubmitting(true);
    try {
      await api.registerVehicle(user.id, {
        ...formData,
        year: parseInt(formData.year) || null
      });
      // Update account status to reflect progress if not already past this point
      if (user.account_status === 'phone_verified') {
        await updateUser({ account_status: 'vehicle_added' });
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
            Vehicle Registration
          </h2>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 16, flex: 1, overflowY: 'auto', paddingBottom: 24 }}>
          <div>
            <label style={labelStyle}>Vehicle Type *</label>
            <select 
              value={formData.type}
              onChange={e => setFormData({...formData, type: e.target.value})}
              style={inputStyle}
            >
              <option value="Danfo">Danfo</option>
              <option value="Keke">Keke</option>
              <option value="Okada">Okada</option>
              <option value="Bus">Bus</option>
            </select>
          </div>
          <div>
            <label style={labelStyle}>Registration Number *</label>
            <input 
              type="text" 
              value={formData.registration_number}
              onChange={e => setFormData({...formData, registration_number: e.target.value})}
              style={inputStyle}
              placeholder="e.g. KJA-123XD"
            />
          </div>
          <div>
            <label style={labelStyle}>Model *</label>
            <input 
              type="text" 
              value={formData.model}
              onChange={e => setFormData({...formData, model: e.target.value})}
              style={inputStyle}
              placeholder="e.g. Volkswagen Transporter"
            />
          </div>
          <div>
            <label style={labelStyle}>Color</label>
            <input 
              type="text" 
              value={formData.color}
              onChange={e => setFormData({...formData, color: e.target.value})}
              style={inputStyle}
              placeholder="e.g. Yellow"
            />
          </div>
          <div>
            <label style={labelStyle}>Year</label>
            <input 
              type="number" 
              value={formData.year}
              onChange={e => setFormData({...formData, year: e.target.value})}
              style={inputStyle}
              placeholder="e.g. 2008"
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
