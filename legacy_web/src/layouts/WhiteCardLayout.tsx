import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';

import bg1 from '../assets/bg1.jpg'; // fallback

export const WhiteCardLayout: React.FC<{ imageSrc?: string; children: React.ReactNode; currentStep?: string }> = ({ imageSrc = bg1, children, currentStep }) => {
  return (
    <div className="carousel-container" style={{ background: '#000' }}>
      <AnimatePresence mode="wait">
        <motion.div
          key={currentStep || imageSrc}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.5 }}
          className="carousel-bg"
        >
          <img src={imageSrc} alt="background" />
        </motion.div>
      </AnimatePresence>

      <motion.div 
        className="carousel-card"
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        transition={{ type: 'spring', damping: 20, stiffness: 100 }}
        style={{ padding: '32px 24px 24px 24px', display: 'block', height: '60%' }} // increased height for form content
      >
        {children}
      </motion.div>
    </div>
  );
};
