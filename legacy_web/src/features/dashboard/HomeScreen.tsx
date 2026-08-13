import React from 'react';
import { useAppContext } from '../../context/AppContext';
import { motion } from 'framer-motion';
import { MapBackground } from '../../components/MapBackground';
import { Badge } from '../../ui/Badge';
import { Button } from '../../ui/Button';
import { QrCode, PlayCircle, StopCircle, ArrowRight } from 'lucide-react';
import { useShiftStore } from '../../core/store/useShiftStore';

export const HomeScreen: React.FC = () => {
  const { state } = useAppContext();
  const fmt = (n: number) => n.toLocaleString();

  const { activeShift, startShift, endShift, isLoading } = useShiftStore();

  return (
    <div style={{ width: '100%', height: '100%', position: 'relative', overflow: 'hidden' }}>
      <MapBackground />
      
      <motion.div 
        className="glass"
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        transition={{ type: 'spring', damping: 25, stiffness: 120 }}
        style={{
          position: 'absolute',
          bottom: 0,
          left: 0,
          right: 0,
          borderTopLeftRadius: 'var(--radius-xl)',
          borderTopRightRadius: 'var(--radius-xl)',
          borderBottom: 'none',
          padding: '32px 24px',
          display: 'flex',
          flexDirection: 'column',
          zIndex: 10
        }}
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
          <div style={{ color: 'var(--color-text)', display: 'flex', alignItems: 'center', gap: 12, fontWeight: 600, fontSize: 'var(--text-lg)' }}>
            <span style={{ width: 10, height: 10, borderRadius: '50%', background: 'var(--ok-green)', display: 'inline-block', boxShadow: '0 0 8px var(--ok-green)' }}></span>
            {state.routeStart || 'Oshodi'} <ArrowRight size={16} color="var(--muted)" /> {state.routeEnd || 'TBS'}
          </div>
          <div style={{ color: 'var(--muted)', fontWeight: 500, fontSize: 'var(--text-sm)', fontFamily: 'var(--font-display)' }}>
            {new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </div>
        </div>
        
        <div style={{ fontFamily: 'var(--font-display)', fontSize: 'var(--text-4xl)', fontWeight: 800, color: 'var(--danfo-yellow)', lineHeight: 1.1, textShadow: '0 4px 24px rgba(245, 179, 0, 0.2)' }}>
          ₦{fmt(activeShift ? activeShift.totalEarnings : 0)}
        </div>
        <div style={{ color: 'var(--muted)', fontSize: 'var(--text-sm)', fontWeight: 500, marginBottom: 32, textTransform: 'uppercase', letterSpacing: '0.05em' }}>
          Total Collected Today
        </div>
        
        {!activeShift ? (
          <motion.div 
            style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '16px 0', gap: 24 }}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
          >
            <div style={{ color: 'var(--muted)', textAlign: 'center', fontSize: 'var(--text-sm)', maxWidth: 260 }}>
              You are currently offline. Start your shift to accept digital payments.
            </div>
            <Button onClick={startShift} disabled={isLoading} variant="primary">
              {isLoading ? 'Connecting...' : (
                <>
                  <PlayCircle size={20} /> Start Shift
                </>
              )}
            </Button>
          </motion.div>
        ) : (
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ type: 'spring' }}
          >
            <motion.div 
              whileHover={{ scale: 1.02 }}
              style={{
                width: '100%', padding: 24, borderRadius: 'var(--radius-lg)',
                background: 'linear-gradient(135deg, rgba(0, 168, 107, 0.1) 0%, rgba(34, 197, 94, 0.1) 100%)',
                border: '1px solid rgba(34, 197, 94, 0.2)',
                position: 'relative', overflow: 'hidden'
              }}
            >
              <div style={{ position: 'absolute', top: -20, right: -20, width: 80, height: 80, background: 'var(--keke-green-glow)', borderRadius: '50%', filter: 'blur(20px)' }}></div>
              
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 20, alignItems: 'center' }}>
                <span style={{ fontSize: 'var(--text-sm)', fontWeight: 700, color: 'var(--ok-green)', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
                  Active Code
                </span>
                <Badge animated variant="success">LIVE</Badge>
              </div>
              
              <div style={{ fontSize: 'var(--text-3xl)', fontFamily: 'var(--font-display)', fontWeight: 900, letterSpacing: '0.05em', color: 'var(--color-text)' }}>
                <span style={{ color: 'var(--muted)', fontWeight: 500 }}>#</span>{state.generatedCode || 'DK-Y82H'}
              </div>
              
              <div style={{ marginTop: 12, fontSize: 'var(--text-sm)', color: 'var(--muted)', display: 'flex', alignItems: 'center', gap: 8 }}>
                <QrCode size={18} color="var(--danfo-yellow)" />
                Passengers scan or enter this code
              </div>
            </motion.div>

            <Button 
              variant="danger" 
              onClick={endShift}
              disabled={isLoading}
              style={{ marginTop: 24 }}
            >
              {isLoading ? 'Syncing...' : (
                <>
                  <StopCircle size={20} /> End Shift
                </>
              )}
            </Button>
          </motion.div>
        )}
      </motion.div>
    </div>
  );
};
