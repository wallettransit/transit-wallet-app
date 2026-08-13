import React from 'react';
import { Outlet } from 'react-router-dom';

export const OnboardingLayout: React.FC = () => {
  return (
    <div className="onboarding-layout">
      <div className="onboarding-hero" style={{ 
        backgroundImage: 'url(/src/assets/bg5.jpg)', 
        backgroundSize: 'cover', 
        backgroundPosition: 'center', 
        position: 'relative' 
      }}>
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(135deg, rgba(4, 75, 48, 0.9), rgba(28, 25, 19, 0.8))' }} />
        <div className="hero-content" style={{ position: 'relative', zIndex: 10, background: 'rgba(255,255,255,0.05)', backdropFilter: 'blur(16px)', padding: '32px', borderRadius: '32px', border: '1px solid rgba(255,255,255,0.1)', boxShadow: '0 24px 60px rgba(0,0,0,0.4)', textAlign: 'left', maxWidth: '400px' }}>
          <div className="big-icon" style={{ fontSize: 48, marginBottom: 16 }}>🚐</div>
          <div style={{ fontSize: '36px', fontWeight: 900, color: 'white', lineHeight: 1.1 }}>Drive.<br/><span style={{color: 'var(--danfo-yellow)'}}>Earn.</span><br/>Zero Wahala.</div>
          <div style={{ fontSize: '16px', color: 'rgba(255,255,255,0.8)', marginTop: '16px', lineHeight: 1.5 }}>The easiest way for drivers to get paid without the stress of exact change.</div>
        </div>
      </div>
      <div className="onboarding-form">
        <div className="screen">
          <Outlet />
        </div>
      </div>
    </div>
  );
};
