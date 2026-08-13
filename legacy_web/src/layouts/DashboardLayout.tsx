import React from 'react';
import { Home, Wallet, List } from 'lucide-react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { TransactionToast } from '../features/dashboard/TransactionToast';
import { SimulateRideButton } from '../features/dashboard/SimulateRideButton';

export const DashboardLayout: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const path = location.pathname;

  return (
    <div className="dashboard-layout">
      <TransactionToast />
      <SimulateRideButton />
      <div className="sidebar-nav glass">
        <div className="sidebar-brand">🚐 TransitWallet</div>
        <div className="sidebar-links">
          <div className={`nav-item-side ${path === '/home' ? 'active' : ''}`} onClick={() => navigate('/home')}>
            <Home size={20} className="nav-icon" /> Home
          </div>
          <div className={`nav-item-side ${path === '/wallet' ? 'active' : ''}`} onClick={() => navigate('/wallet')}>
            <Wallet size={20} className="nav-icon" /> Wallet
          </div>
          <div className={`nav-item-side ${path === '/history' ? 'active' : ''}`} onClick={() => navigate('/history')}>
            <List size={20} className="nav-icon" /> History
          </div>
        </div>
      </div>
      
      <div className="dashboard-content">
        <div className="screen with-nav animate-fade-up">
          <Outlet />
        </div>
      </div>

      <div className="bottom-nav glass">
        <div className={`nav-item ${path === '/home' ? 'active' : ''}`} onClick={() => navigate('/home')}>
          <Home className="nav-icon" /> Home
        </div>
        <div className={`nav-item ${path === '/wallet' ? 'active' : ''}`} onClick={() => navigate('/wallet')}>
          <Wallet className="nav-icon" /> Wallet
        </div>
        <div className={`nav-item ${path === '/history' ? 'active' : ''}`} onClick={() => navigate('/history')}>
          <List className="nav-icon" /> History
        </div>
      </div>
    </div>
  );
};
