import React from 'react';
import { motion } from 'framer-motion';

export type BadgeVariant = 'success' | 'warning' | 'neutral';

interface BadgeProps {
  children: React.ReactNode;
  variant?: BadgeVariant;
  animated?: boolean;
}

export const Badge: React.FC<BadgeProps> = ({ children, variant = 'success', animated = false }) => {
  let bg = 'rgba(34, 197, 94, 0.1)';
  let color = 'var(--ok-green)';
  let dotColor = 'var(--ok-green)';

  switch (variant) {
    case 'warning':
      bg = 'rgba(245, 158, 11, 0.1)';
      color = '#f59e0b';
      dotColor = '#f59e0b';
      break;
    case 'neutral':
      bg = 'rgba(156, 163, 175, 0.1)';
      color = '#6b7280';
      dotColor = '#9ca3af';
      break;
  }

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 6, background: bg, padding: '4px 10px', borderRadius: 12, width: 'fit-content' }}>
      {animated && (
        <motion.div 
          animate={{ opacity: [1, 0.4, 1] }} 
          transition={{ duration: 1.5, repeat: Infinity }}
          style={{ width: 8, height: 8, borderRadius: '50%', background: dotColor }}
        />
      )}
      {!animated && (
        <div style={{ width: 8, height: 8, borderRadius: '50%', background: dotColor }} />
      )}
      <span style={{ color: color, fontSize: 12, fontWeight: 700 }}>{children}</span>
    </div>
  );
};
