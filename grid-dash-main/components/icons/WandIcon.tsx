
import React from 'react';

const WandIcon: React.FC<{ size?: number }> = ({ size = 20 }) => (
  <svg 
    xmlns="http://www.w3.org/2000/svg" 
    width={size}
    height={size}
    viewBox="0 0 24 24" 
    fill="none" 
    stroke="currentColor" 
    strokeWidth="2.5" 
    strokeLinecap="round" 
    strokeLinejoin="round"
  >
    <path d="M15 4V2"/>
    <path d="M15 10V8"/>
    <path d="M12.5 7.5 14 9"/>
    <path d="M16 9l1.5-1.5"/>
    <path d="m19 5-8 8"/>
    <path d="M9 10.5 7.5 9"/>
    <path d="M9 15 3 21"/>
    <path d="M14 15h2"/>
    <path d="M20 15h2"/>
  </svg>
);

export default WandIcon;
