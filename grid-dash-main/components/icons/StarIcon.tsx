
import React from 'react';

interface StarIconProps {
  filled: boolean;
  size?: number;
  isWhite?: boolean;
}

const StarIcon: React.FC<StarIconProps> = ({ filled, size = 20, isWhite }) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 24 24"
    stroke="currentColor"
    strokeWidth="1.5"
    strokeLinecap="round"
    strokeLinejoin="round"
    className={`transition-all duration-300 ${
        isWhite 
            ? (filled ? 'text-white fill-white' : 'text-white/60 fill-white/40')
            : (filled ? 'text-amber-400 fill-amber-400' : 'text-slate-200 fill-slate-200')
    }`}
  >
    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
  </svg>
);

export default StarIcon;