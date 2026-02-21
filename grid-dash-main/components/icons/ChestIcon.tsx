
import React from 'react';

interface ChestIconProps {
  isOpen: boolean;
}

const ChestIcon: React.FC<ChestIconProps> = ({ isOpen }) => {
  return (
    <svg
      width="48"
      height="48"
      viewBox="0 0 64 64"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      {/* Chest Base */}
      <path d="M8 28 H56 V54 C56 56.2091 54.2091 58 52 58 H12 C9.79086 58 8 56.2091 8 54 V28 Z" fill="#A16207"/>
      <path d="M6 26 H58 V32 H6 V26 Z" fill="#FBBF24"/>
      <path d="M32 38m-4 0a4 4 0 0 1 8 0h-8Z" fill="#334155"/>
      <path d="M32 38m-2 0a2 2 0 0 1 4 0h-4Z" fill="#475569"/>

      {/* Chest Lid */}
      <g 
        className={`transition-transform duration-500 ease-in-out ${isOpen ? 'transform -rotate-12' : ''}`}
        style={{ transformOrigin: '8px 28px' }}
      >
        <path d="M8 28 C8 16.9543 16.9543 8 28 8 H36 C47.0457 8 56 16.9543 56 28 V28 H8 V28 Z" fill="#D97706"/>
        <path d="M6 22 H58 V28 H6 V22 Z" fill="#FBBF24"/>
      </g>
    </svg>
  );
};

export default ChestIcon;