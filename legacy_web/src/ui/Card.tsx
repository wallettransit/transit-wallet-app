import React from 'react';

interface CardProps {
  children: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
  onClick?: () => void;
}

export const Card: React.FC<CardProps> = ({
  children,
  className = '',
  style,
  onClick
}) => {
  return (
    <div 
      className={`card ${className}`} 
      style={{
        background: 'var(--color-primary)',
        color: 'var(--ink)',
        borderRadius: 'var(--radius-lg)',
        padding: 'var(--space-5)',
        width: '100%',
        cursor: onClick ? 'pointer' : 'default',
        ...style
      }}
      onClick={onClick}
    >
      {children}
    </div>
  );
};
