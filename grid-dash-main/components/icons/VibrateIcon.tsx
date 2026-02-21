
import React from 'react';

const VibrateIcon: React.FC<{ className?: string }> = ({ className }) => (
  <svg 
    xmlns="http://www.w3.org/2000/svg" 
    width="24" 
    height="24" 
    viewBox="0 0 24 24" 
    fill="none" 
    stroke="currentColor" 
    strokeWidth="2" 
    strokeLinecap="round" 
    strokeLinejoin="round" 
    className={className}
  >
    <path d="M18 8l3-3" />
    <path d="M18 12h4" />
    <path d="M18 16l3 3" />
    <path d="M6 8l-3-3" />
    <path d="M6 12H2" />
    <path d="M6 16l-3 3" />
    <rect x="8" y="4" width="8" height="16" rx="2" />
  </svg>
);

export default VibrateIcon;