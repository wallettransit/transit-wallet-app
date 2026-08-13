import { useNavigate } from 'react-router-dom';
import React from 'react';
import { motion } from 'framer-motion';
import { Typography } from '../../ui/Typography';
import { Button } from '../../ui/Button';
import Danfo3DImg from '../../assets/danfo_3d.png';

export const WelcomeScreen: React.FC = () => {
  const navigate = useNavigate();
  const bounceTransition = { type: 'spring', damping: 10, stiffness: 120 };

  return (
    <motion.div key="welcome" className="center" exit={{ opacity: 0, scale: 0.9, y: 50 }} transition={{ duration: 0.3 }}>
      <motion.div 
        initial={{ y: -100, opacity: 0, scale: 0.8 }}
        animate={{ y: 0, opacity: 1, scale: 1 }}
        transition={{ type: 'spring', damping: 12, stiffness: 100, delay: 0.1 } as any}
        style={{ width: '220px', height: '220px', margin: '0 auto var(--space-6)', overflow: 'hidden' }}
      >
        <img src={Danfo3DImg} alt="3D Danfo Bus" style={{ width: '100%', height: '100%', objectFit: 'contain', mixBlendMode: 'screen' }} />
      </motion.div>

      <motion.div
        initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ ...bounceTransition, delay: 0.3 } as any}
      >
        <Typography variant="h1" color="primary">TransitWallet</Typography>
      </motion.div>
      <motion.div 
        initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ ...bounceTransition, delay: 0.4 } as any}
      >
        <Typography variant="body" color="muted" align="center" style={{ marginBottom: 'var(--space-6)' }}>
          For drivers. Get paid without the wahala of change.
        </Typography>
      </motion.div>
      <motion.div style={{ width: '100%' }} initial={{ opacity: 0, y: 50 }} animate={{ opacity: 1, y: 0 }} transition={{ ...bounceTransition, delay: 0.5 } as any}>
        <Button onClick={() => navigate('/phone')}>Get started</Button>
      </motion.div>
    </motion.div>
  );
};
