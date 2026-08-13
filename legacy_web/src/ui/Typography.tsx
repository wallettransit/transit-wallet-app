import React from 'react';

type Variant = 'h1' | 'h2' | 'h3' | 'body' | 'caption' | 'eyebrow';
type Color = 'primary' | 'text' | 'muted' | 'success' | 'danger' | 'inherit';
type Align = 'left' | 'center' | 'right';

interface TypographyProps {
  variant?: Variant;
  color?: Color;
  align?: Align;
  className?: string;
  children: React.ReactNode;
  style?: React.CSSProperties;
}

const variantStyles: Record<Variant, React.CSSProperties> = {
  h1: { fontFamily: 'var(--font-display)', fontSize: 'var(--text-3xl)', margin: '0 0 var(--space-2) 0', fontWeight: 400 },
  h2: { fontFamily: 'var(--font-display)', fontSize: 'var(--text-xl)', margin: '0 0 var(--space-2) 0', fontWeight: 400 },
  h3: { fontFamily: 'var(--font-ui)', fontSize: 'var(--text-base)', fontWeight: 600 },
  body: { fontFamily: 'var(--font-sans)', fontSize: 'var(--text-sm)' },
  caption: { fontFamily: 'var(--font-sans)', fontSize: 'var(--text-xs)' },
  eyebrow: { fontFamily: 'var(--font-ui)', fontSize: 'var(--text-xs)', letterSpacing: '0.1em', textTransform: 'uppercase' },
};

const colorMap: Record<Color, string> = {
  primary: 'var(--color-primary)',
  text: 'var(--color-text)',
  muted: 'var(--color-text-muted)',
  success: 'var(--ok-green)',
  danger: 'var(--warn-rust)',
  inherit: 'inherit',
};

export const Typography: React.FC<TypographyProps> = ({
  variant = 'body',
  color = 'text',
  align = 'left',
  className = '',
  children,
  style,
}) => {
  const combinedStyle: React.CSSProperties = {
    ...variantStyles[variant],
    color: colorMap[color],
    textAlign: align,
    ...style,
  };

  const Component = variant.startsWith('h') ? variant : 'div';
  
  // @ts-ignore
  return <Component className={className} style={combinedStyle}>{children}</Component>;
};
