import React from 'react';
import { useShiftStore } from '../../core/store/useShiftStore';
import { Plus } from 'lucide-react';

export const SimulateRideButton: React.FC = () => {
  const { activeShift, simulateTransaction } = useShiftStore();

  if (!activeShift) return null;

  return (
    <button
      onClick={() => simulateTransaction(Math.floor(Math.random() * 500) + 500)} // Random amount between 500 and 1000
      style={{
        position: 'absolute',
        bottom: 80,
        right: 16,
        width: 56,
        height: 56,
        borderRadius: '50%',
        background: 'var(--danfo-yellow)',
        color: 'var(--ink)',
        border: 'none',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        boxShadow: '0 4px 12px rgba(0,0,0,0.2)',
        cursor: 'pointer',
        zIndex: 50,
      }}
      title="Simulate Passenger Ride"
    >
      <Plus size={24} />
    </button>
  );
};
