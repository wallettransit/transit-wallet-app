import React from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { useAuthStore } from '../../core/store/useAuthStore';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import { CheckCircle2, Circle, ChevronRight } from 'lucide-react';

export const VerificationChecklistScreen: React.FC = () => {
  const navigate = useNavigate();
  const { user, updateUser, logout } = useAuthStore();
  
  if (!user) return null;

  // Determine what is complete based on user state
  const isPhoneComplete = true; // They got here, so phone is verified
  const isPersonalComplete = !!user.first_name && !!user.last_name && !!user.dob;
  const isDriverComplete = !!user.driver_type && !!user.operating_location;
  const isLicenseComplete = !!user.license_number;
  // For vehicle & payment we'd ideally check the DB, but for MVP we use account_status progression
  const isVehicleComplete = ['vehicle_added', 'payment_added', 'verification_pending', 'approved'].includes(user.account_status);
  const isPaymentComplete = ['payment_added', 'verification_pending', 'approved'].includes(user.account_status);
  
  const allComplete = isPersonalComplete && isDriverComplete && isLicenseComplete && isVehicleComplete && isPaymentComplete;

  const handleSimulateApproval = async () => {
    await updateUser({ account_status: 'approved' });
    navigate('/home');
  };

  return (
    <WhiteCardLayout>
      <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
        <h2 style={{ fontFamily: 'var(--font-display)', fontSize: 24, fontWeight: 700, color: 'var(--color-text)', marginBottom: 8 }}>
          Setup your account
        </h2>
        <p style={{ color: 'var(--color-text-muted)', fontSize: 15, marginBottom: 32 }}>
          Complete these steps to start accepting payments on TransitWallet.
        </p>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 16, flex: 1, paddingBottom: 24 }}>
          <ChecklistItem 
            title="Phone Verification" 
            isComplete={isPhoneComplete} 
            onClick={() => {}} 
          />
          <ChecklistItem 
            title="Personal Information" 
            isComplete={isPersonalComplete} 
            onClick={() => navigate('/onboarding/personal')} 
          />
          <ChecklistItem 
            title="Driver Information" 
            isComplete={isDriverComplete} 
            onClick={() => navigate('/onboarding/driver')} 
          />
          <ChecklistItem 
            title="Driver License" 
            isComplete={isLicenseComplete} 
            onClick={() => navigate('/onboarding/license')} 
          />
          <ChecklistItem 
            title="Vehicle Registration" 
            isComplete={isVehicleComplete} 
            onClick={() => navigate('/onboarding/vehicle')} 
          />
          <ChecklistItem 
            title="Payment Account" 
            isComplete={isPaymentComplete} 
            onClick={() => navigate('/onboarding/payment')} 
          />
        </div>

        <div style={{ marginTop: 'auto', paddingTop: 24, display: 'flex', flexDirection: 'column', gap: 12 }}>
          {allComplete && user.account_status !== 'approved' && (
            <motion.button
              whileTap={{ scale: 0.98 }}
              onClick={handleSimulateApproval}
              style={{
                width: '100%',
                padding: '16px',
                borderRadius: 12,
                border: 'none',
                backgroundColor: 'var(--ok-green)',
                color: 'white',
                fontSize: 16,
                fontWeight: 600,
                cursor: 'pointer'
              }}
            >
              Simulate Admin Approval
            </motion.button>
          )}

          {user.account_status === 'approved' && (
            <motion.button
              whileTap={{ scale: 0.98 }}
              onClick={() => navigate('/home')}
              className="btn btn-primary"
            >
              Go to Dashboard
            </motion.button>
          )}

          <button
            onClick={logout}
            style={{
              width: '100%',
              padding: '16px',
              borderRadius: 12,
              border: 'none',
              backgroundColor: 'transparent',
              color: 'var(--warn-rust)',
              fontSize: 16,
              fontWeight: 600,
              cursor: 'pointer'
            }}
          >
            Log Out
          </button>
        </div>
      </div>
    </WhiteCardLayout>
  );
};

const ChecklistItem = ({ title, isComplete, onClick }: { title: string, isComplete: boolean, onClick: () => void }) => {
  return (
    <div 
      onClick={onClick}
      style={{ 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'space-between',
        padding: '16px',
        backgroundColor: 'var(--color-surface-raised)',
        borderRadius: 12,
        cursor: 'pointer',
        border: '1px solid var(--color-border)'
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        {isComplete ? (
          <CheckCircle2 color="var(--ok-green)" size={24} />
        ) : (
          <Circle color="var(--color-text-muted)" size={24} />
        )}
        <span style={{ fontSize: 16, fontWeight: 500, color: 'var(--color-text)' }}>{title}</span>
      </div>
      {!isComplete && <ChevronRight color="var(--color-text-muted)" size={20} />}
    </div>
  );
};
