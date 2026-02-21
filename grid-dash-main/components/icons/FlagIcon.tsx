import React from 'react';

const FlagIcon: React.FC<{ size?: number, className?: string }> = ({ size = 24, className }) => (
    <svg 
        xmlns="http://www.w3.org/2000/svg" 
        width={size}
        height={size}
        viewBox="0 0 24 24" 
        fill="none" 
        stroke="currentColor" 
        strokeWidth="2" 
        strokeLinecap="round" 
        strokeLinejoin="round" 
        className={className}
    >
        <path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"></path>
        <line x1="4" y1="22" x2="4" y2="15"></line>
    </svg>
);

export default FlagIcon;