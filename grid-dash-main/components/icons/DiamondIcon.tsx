
import React from 'react';

const DiamondIcon: React.FC<{className?: string, size?: number}> = ({className, size = 24}) => (
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
        <path d="M2.7 10.3a2.41 2.41 0 0 0 0 3.41l7.59 7.59a2.41 2.41 0 0 0 3.41 0l7.59-7.59a2.41 2.41 0 0 0 0-3.41L13.7 2.71a2.41 2.41 0 0 0-3.41 0z" />
        <path d="m12 2.72 7.59 7.59" />
        <path d="M12 21.29 4.41 13.7" />
        <path d="m2.7 13.71 18.6 0" />
    </svg>
);

export default DiamondIcon;
