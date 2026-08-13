import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useShiftStore } from '../../core/store/useShiftStore';
import { Button } from '../../ui/Button';

export const TransactionToast: React.FC = () => {
  const { transactions, reverseTransaction, isReversing } = useShiftStore();
  const [visibleTx, setVisibleTx] = useState<string | null>(null);

  useEffect(() => {
    // Show the latest transaction if it's new and completed
    if (transactions.length > 0) {
      const latest = transactions[0];
      if (latest.status === 'completed') {
        setVisibleTx(latest.id);
        // Auto-hide after 10 seconds for demo purposes
        const timer = setTimeout(() => {
          setVisibleTx(null);
        }, 10000);
        return () => clearTimeout(timer);
      }
    }
  }, [transactions]);

  const handleReverse = async (id: string) => {
    await reverseTransaction(id);
    setVisibleTx(null);
  };

  const currentTx = transactions.find(t => t.id === visibleTx);

  return (
    <AnimatePresence>
      {currentTx && (
        <motion.div
          initial={{ opacity: 0, y: -50, scale: 0.9 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: -50, scale: 0.9 }}
          style={{
            position: 'absolute',
            top: 24,
            left: '50%',
            transform: 'translateX(-50%)',
            zIndex: 100,
            background: 'var(--asphalt-3)',
            borderRadius: 16,
            padding: 16,
            width: '90%',
            maxWidth: 400,
            boxShadow: '0 12px 32px rgba(0,0,0,0.3)',
            border: '1px solid var(--danfo-yellow)'
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <div>
              <div style={{ color: 'var(--danfo-yellow)', fontSize: 12, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                New Payment
              </div>
              <div style={{ color: 'white', fontSize: 24, fontWeight: 800 }}>
                +₦{currentTx.amount.toLocaleString()}
              </div>
            </div>
            <div style={{ color: 'var(--muted)', fontSize: 12, textAlign: 'right' }}>
              Passenger<br/>
              {currentTx.passengerId}
            </div>
          </div>
          
          <div style={{ display: 'flex', gap: 8 }}>
            <Button 
              variant="ghost" 
              fullWidth 
              onClick={() => handleReverse(currentTx.id)}
              disabled={isReversing}
            >
              {isReversing ? 'Reversing...' : 'Reverse'}
            </Button>
            <Button 
              fullWidth 
              onClick={() => setVisibleTx(null)}
            >
              Dismiss
            </Button>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};
