import React from 'react';

export const ProgressBar: React.FC<{ done: number; total: number }> = ({ done, total }) => {
  return (
    <div className="progress">
      {Array.from({ length: total }).map((_, i) => (
        <div key={i} className={`progress-seg ${i < done ? 'done' : ''}`}></div>
      ))}
    </div>
  );
};
