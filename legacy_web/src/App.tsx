import React from 'react';
import { BrowserRouter, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { AppProvider } from './context/AppContext';
import { useAuthStore } from './core/store/useAuthStore';

// Layouts
import { OnboardingLayout } from './layouts/OnboardingLayout';
import { DashboardLayout } from './layouts/DashboardLayout';

// Features
import { OnboardingCarousel } from './features/onboarding/OnboardingCarousel';
import { PhoneScreen } from './features/onboarding/PhoneScreen';
import { OtpScreen } from './features/onboarding/OtpScreen';
import { VerificationChecklistScreen } from './features/onboarding/VerificationChecklistScreen';
import { PersonalInfoScreen } from './features/onboarding/PersonalInfoScreen';
import { DriverInfoScreen } from './features/onboarding/DriverInfoScreen';
import { LicenseScreen } from './features/onboarding/LicenseScreen';
import { VehicleScreen } from './features/onboarding/VehicleScreen';
import { PaymentAccountScreen } from './features/onboarding/PaymentAccountScreen';
import { RouteScreen } from './features/onboarding/RouteScreen';
import { StopsScreen } from './features/onboarding/StopsScreen';
import { LiveScreen } from './features/onboarding/LiveScreen';
import { HomeScreen } from './features/dashboard/HomeScreen';
import { WalletScreen } from './features/dashboard/WalletScreen';
import { HistoryScreen } from './features/dashboard/HistoryScreen';
import { WithdrawAmtScreen } from './features/wallet/WithdrawAmtScreen';
import { WithdrawBankScreen } from './features/wallet/WithdrawBankScreen';
import { WithdrawConfirmScreen } from './features/wallet/WithdrawConfirmScreen';
import { WithdrawProcessingScreen } from './features/wallet/WithdrawProcessingScreen';
import { WithdrawSuccessScreen } from './features/wallet/WithdrawSuccessScreen';

import './index.css';

const queryClient = new QueryClient();

const ProtectedRoute = ({ children, requireApproval = false }: { children: React.ReactElement, requireApproval?: boolean }) => {
  const isAuthenticated = useAuthStore(state => state.isAuthenticated);
  const user = useAuthStore(state => state.user);
  const location = useLocation();

  if (!isAuthenticated) {
    return <Navigate to="/welcome" state={{ from: location }} replace />;
  }
  
  if (requireApproval && user?.account_status !== 'approved') {
    return <Navigate to="/onboarding/checklist" replace />;
  }
  
  return children;
};

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AppProvider>
        <BrowserRouter>
          <div className="app-container">
            <Routes>
              {/* Redirect root to welcome */}
              <Route path="/" element={<Navigate to="/welcome" replace />} />

              {/* Welcome Screen without standard Onboarding Layout wrapper */}
              <Route path="/welcome" element={<OnboardingCarousel />} />

              {/* Onboarding Flow */}
              <Route element={<OnboardingLayout />}>
                <Route path="/phone" element={<PhoneScreen />} />
                <Route path="/otp" element={<OtpScreen />} />
                
                {/* Onboarding Profile Setup */}
                <Route path="/onboarding/checklist" element={<ProtectedRoute><VerificationChecklistScreen /></ProtectedRoute>} />
                <Route path="/onboarding/personal" element={<ProtectedRoute><PersonalInfoScreen /></ProtectedRoute>} />
                <Route path="/onboarding/driver" element={<ProtectedRoute><DriverInfoScreen /></ProtectedRoute>} />
                <Route path="/onboarding/license" element={<ProtectedRoute><LicenseScreen /></ProtectedRoute>} />
                <Route path="/onboarding/vehicle" element={<ProtectedRoute><VehicleScreen /></ProtectedRoute>} />
                <Route path="/onboarding/payment" element={<ProtectedRoute><PaymentAccountScreen /></ProtectedRoute>} />

                {/* Legacy Onboarding (Can be deprecated or moved) */}
                <Route path="/route" element={<ProtectedRoute><RouteScreen /></ProtectedRoute>} />
                <Route path="/stops" element={<ProtectedRoute><StopsScreen /></ProtectedRoute>} />
                <Route path="/live" element={<ProtectedRoute><LiveScreen /></ProtectedRoute>} />
              </Route>

              {/* Dashboard Flow */}
              <Route element={<ProtectedRoute requireApproval><DashboardLayout /></ProtectedRoute>}>
                <Route path="/home" element={<HomeScreen />} />
                <Route path="/wallet" element={<WalletScreen />} />
                <Route path="/history" element={<HistoryScreen />} />
                <Route path="/withdraw-amt" element={<WithdrawAmtScreen />} />
                <Route path="/withdraw-bank" element={<WithdrawBankScreen />} />
                <Route path="/withdraw-confirm" element={<WithdrawConfirmScreen />} />
                <Route path="/withdraw-processing" element={<WithdrawProcessingScreen />} />
                <Route path="/withdraw-success" element={<WithdrawSuccessScreen />} />
              </Route>
            </Routes>
          </div>
        </BrowserRouter>
      </AppProvider>
    </QueryClientProvider>
  );
}
