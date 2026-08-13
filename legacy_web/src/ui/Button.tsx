import React from 'react';
import { motion } from 'framer-motion';
import type { HTMLMotionProps } from 'framer-motion';

type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';

interface ButtonProps extends HTMLMotionProps<"button"> {
  variant?: ButtonVariant;
  fullWidth?: boolean;
  className?: string;
  children: React.ReactNode;
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  fullWidth = true,
  className = '',
  children,
  style,
  disabled,
  ...props
}) => {
  // We use the classes from index.css instead of inline styles
  let variantClass = '';
  switch (variant) {
    case 'primary': variantClass = 'btn-primary'; break;
    case 'secondary': variantClass = 'btn-secondary'; break;
    case 'ghost': variantClass = 'btn-secondary'; break; // Maps to secondary for now
    case 'danger': variantClass = 'btn-secondary'; break; // Maps to secondary for now
  }

  const combinedStyle: React.CSSProperties = {
    width: fullWidth ? '100%' : 'auto',
    opacity: disabled ? 0.5 : 1,
    cursor: disabled ? 'not-allowed' : 'pointer',
    ...style,
  };

  return (
    <motion.button
      className={`btn ${variantClass} ${className}`}
      style={combinedStyle}
      whileTap={!disabled ? { scale: 0.96 } : {}}
      disabled={disabled}
      {...props}
    >
      {children}
    </motion.button>
  );
};
