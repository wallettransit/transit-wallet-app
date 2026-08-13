import { useNavigate } from 'react-router-dom';
import React from 'react';
import { motion } from 'framer-motion';
import { MapPin, Navigation, ArrowRight } from 'lucide-react';
import { useAppContext } from '../../context/AppContext';
import { ProgressBar } from '../../components/ProgressBar';
import { WhiteCardLayout } from '../../layouts/WhiteCardLayout';
import Bg5 from '../../assets/bg5.jpg'; // Placeholder image

export const RouteScreen: React.FC = () => {
  const { state, setState } = useAppContext();
  const navigate = useNavigate();

  const isComplete = state.routeStart && state.routeEnd;

  return (
    <WhiteCardLayout imageSrc={Bg5} currentStep="route">
      <ProgressBar done={3} total={6} />
      
      <div style={{ padding: '0 8px' }}>
        <motion.div 
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4 }}
          className="step-label" 
          style={{ color: 'var(--ink)', fontSize: 13, letterSpacing: '0.1em', marginBottom: 24, marginTop: 12 }}
        >
          SET YOUR ROUTE
        </motion.div>

        {/* Premium Route Input Box */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.4, delay: 0.1 }}
          style={{ 
            background: 'white', 
            borderRadius: 20, 
            padding: 20, 
            boxShadow: '0 12px 32px rgba(0,0,0,0.06)',
            border: '1px solid #f3f4f6',
            position: 'relative',
            marginBottom: 32
          }}
        >
          {/* Connecting Line */}
          <div style={{ position: 'absolute', left: 31, top: 44, bottom: 44, width: 2, background: 'linear-gradient(to bottom, #10b981, #f59e0b)', opacity: 0.3, borderRadius: 2 }} />

          {/* Start Point */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 20 }}>
            <div style={{ width: 24, height: 24, borderRadius: '50%', background: 'rgba(16, 185, 129, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 2 }}>
              <div style={{ width: 8, height: 8, borderRadius: '50%', background: '#10b981' }} />
            </div>
            <input 
              style={{ flex: 1, border: 'none', outline: 'none', fontSize: 16, fontWeight: 600, color: 'var(--ink)', padding: '8px 0', background: 'transparent' }}
              placeholder="Starting point"
              value={state.routeStart} 
              onChange={e => setState({ ...state, routeStart: e.target.value })} 
            />
          </div>

          <div style={{ height: 1, background: '#f3f4f6', marginLeft: 40, marginBottom: 20 }} />

          {/* End Point */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <div style={{ width: 24, height: 24, borderRadius: '50%', background: 'rgba(245, 158, 11, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 2 }}>
              <Navigation size={12} color="#f59e0b" fill="#f59e0b" style={{ transform: 'rotate(135deg)' }} />
            </div>
            <input 
              style={{ flex: 1, border: 'none', outline: 'none', fontSize: 16, fontWeight: 600, color: 'var(--ink)', padding: '8px 0', background: 'transparent' }}
              placeholder="Where to?"
              value={state.routeEnd} 
              onChange={e => setState({ ...state, routeEnd: e.target.value })} 
            />
          </div>
        </motion.div>

        {/* Action Button */}
        <motion.button 
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4, delay: 0.2 }}
          whileHover={isComplete ? { scale: 1.02, boxShadow: '0 8px 24px rgba(4, 75, 48, 0.25)' } : {}}
          whileTap={isComplete ? { scale: 0.98 } : {}}
          style={{ 
            width: '100%', 
            background: isComplete ? 'var(--forest-green)' : '#e5e7eb',
            color: isComplete ? 'white' : '#9ca3af',
            border: 'none',
            borderRadius: 16,
            padding: '18px',
            fontSize: 16,
            fontWeight: 700,
            cursor: isComplete ? 'pointer' : 'not-allowed',
            transition: 'all 0.3s ease',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 8,
            marginBottom: 32
          }}
          disabled={!isComplete}
          onClick={() => navigate('/stops')}
        >
          Continue
          {isComplete && <ArrowRight size={18} />}
        </motion.button>

        {/* Suggestions */}
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.3 }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: '#6b7280', textTransform: 'uppercase', letterSpacing: '0.05em', marginBottom: 12 }}>
            Suggested routes from Ikorodu
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {['TBS', 'Maryland'].map((dest) => (
              <motion.div 
                key={dest}
                whileHover={{ scale: 1.01, backgroundColor: '#f9fafb' }}
                whileTap={{ scale: 0.99 }}
                onClick={() => { setState({ ...state, routeEnd: dest }); navigate('/stops'); }}
                style={{ 
                  display: 'flex', 
                  alignItems: 'center', 
                  justifyContent: 'space-between',
                  padding: '16px 20px', 
                  background: 'white', 
                  borderRadius: 16, 
                  border: '1px solid #f3f4f6',
                  cursor: 'pointer',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.02)'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <MapPin size={18} color="#9ca3af" />
                  <span style={{ fontSize: 15, fontWeight: 600, color: 'var(--ink)' }}>{dest}</span>
                </div>
                <ArrowRight size={16} color="#d1d5db" />
              </motion.div>
            ))}
          </div>
        </motion.div>
      </div>
    </WhiteCardLayout>
  );
};
