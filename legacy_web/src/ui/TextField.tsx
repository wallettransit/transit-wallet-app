import React from 'react';
import { Search, Phone, User, Key, MapPin } from 'lucide-react';

export type IconType = 'search' | 'phone' | 'user' | 'key' | 'map-pin';

interface TextFieldProps extends React.InputHTMLAttributes<HTMLInputElement> {
  icon?: IconType;
  error?: string;
}

const renderIcon = (icon?: IconType) => {
  switch (icon) {
    case 'search': return <Search size={18} color="#9ca3af" />;
    case 'phone': return <Phone size={18} color="#9ca3af" />;
    case 'user': return <User size={18} color="#9ca3af" />;
    case 'key': return <Key size={18} color="#9ca3af" />;
    case 'map-pin': return <MapPin size={18} color="#9ca3af" />;
    default: return null;
  }
};

export const TextField: React.FC<TextFieldProps> = ({ icon, error, className, ...props }) => {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4, width: '100%' }}>
      <div 
        style={{
          display: 'flex',
          alignItems: 'center',
          background: '#f9fafb',
          borderRadius: 12,
          padding: '14px 16px',
          border: `1px solid ${error ? '#ef4444' : '#e5e7eb'}`,
          transition: 'border-color 0.2s',
          gap: 12
        }}
      >
        {icon && renderIcon(icon)}
        <input 
          style={{
            flex: 1,
            background: 'transparent',
            border: 'none',
            outline: 'none',
            fontSize: 16,
            color: 'var(--ink)',
            fontFamily: 'Inter, sans-serif'
          }}
          className={className}
          {...props}
        />
      </div>
      {error && (
        <span style={{ fontSize: 12, color: '#ef4444', marginLeft: 4 }}>{error}</span>
      )}
    </div>
  );
};
