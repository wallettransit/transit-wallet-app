import React from 'react';
import { FileX } from 'lucide-react';

export const EmptyState: React.FC<{ message: string; subMessage?: string }> = ({ message, subMessage }) => {
  return (
    <div className="center" style={{ padding: '48px 16px', opacity: 0.6, marginTop: 32 }}>
      <FileX size={48} color="var(--ink)" style={{ marginBottom: 16 }} />
      <div style={{ fontFamily: 'Inter', fontSize: 16, fontWeight: 600, color: 'var(--ink)' }}>{message}</div>
      {subMessage && <div className="hint-small" style={{ marginTop: 8 }}>{subMessage}</div>}
    </div>
  );
};
