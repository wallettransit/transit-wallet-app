import { useNavigate } from 'react-router-dom';
import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Button } from '../../ui/Button';
import Bg1 from '../../assets/bg1.jpg';
import Bg2 from '../../assets/bg2.jpg';
import Bg3 from '../../assets/bg3.jpg';
import Bg4 from '../../assets/bg4.jpg';
import Bg5 from '../../assets/bg5.jpg';

const slides = [
  {
    image: Bg1,
    title: 'Welcome to Nigeriicon',
    subtitle: 'Smarter transport. Better rides. Less stress.',
  },
  {
    image: Bg2,
    title: 'Tap or Scan to Pay',
    subtitle: 'No cash. No change issues. Just scan, pay and go.',
  },
  {
    image: Bg3,
    title: 'Track Every Ride',
    subtitle: 'See where your money goes. Know your spending.',
  },
  {
    image: Bg4,
    title: 'Set & Save',
    subtitle: 'Create a budget. Save more. Travel smarter.',
  },
  {
    image: Bg5,
    title: 'Find Better Rides',
    subtitle: 'See cheaper options. Ride with others going your way.',
  }
];

export const OnboardingCarousel: React.FC = () => {
  const navigate = useNavigate();
  const [step, setStep] = useState(0);

  const nextStep = () => {
    if (step < slides.length - 1) {
      setStep(step + 1);
    } else {
      navigate('/phone');
    }
  };

  const slide = slides[step];

  return (
    <div className="carousel-container">
      <AnimatePresence mode="wait">
        <motion.div
          key={step}
          initial={{ opacity: 0, scale: 1.1 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.95 }}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
          className="carousel-bg"
        >
          <img src={slide.image} alt={slide.title} />
          <div className="carousel-overlay" />
        </motion.div>
      </AnimatePresence>

      <motion.div 
        className="carousel-card"
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        transition={{ type: 'spring', damping: 20, stiffness: 100 }}
      >
        <AnimatePresence mode="wait">
          <motion.div
            key={step}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.3 }}
            style={{ textAlign: 'center', width: '100%' }}
          >
            <h2 style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '8px' }}>
              {step === 0 ? (
                <>
                  Welcome to <br />
                  <span style={{ fontSize: '32px' }}>TransitWallet</span>
                </>
              ) : slide.title}
            </h2>
            <p style={{ color: '#6b7280', fontSize: '14px', lineHeight: '1.5' }}>{slide.subtitle}</p>
          </motion.div>
        </AnimatePresence>

        <div className="carousel-dots">
          {slides.map((_, i) => (
            <div key={i} className={`dot ${i === step ? 'active' : ''}`} />
          ))}
        </div>

        <Button variant="primary" onClick={nextStep}>
          {step === 0 ? 'Get Started' : 'Next'}
        </Button>

        <button className="skip-btn" onClick={() => navigate('/phone')}>
          Skip
        </button>
      </motion.div>
    </div>
  );
};
