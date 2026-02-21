
import React, { useState, useEffect } from 'react';
import PlayIcon from './icons/PlayIcon';
import LeaderboardIcon from './icons/LeaderboardIcon';
import TrophyIcon from './icons/TrophyIcon';
import SettingsIcon from './icons/SettingsIcon';
import { useSound } from '../hooks/useSound';
import { useHaptics } from '../hooks/useHaptics';
import CartIcon from './icons/CartIcon';
import DiamondIcon from './icons/DiamondIcon';

interface MainMenuProps {
  onPlay: () => void;
  onLeaderboard: () => void;
  onBadges: () => void;
  onSettings: () => void;
  onShop: () => void;
  gems: number;
}

const shapes = [
    { type: 'square', color: 'bg-sky-400/50' },
    { type: 'square', color: 'bg-blue-500/50' },
    { type: 'square', color: 'bg-indigo-600/50' },
    { type: 'circle', color: 'bg-white/50' },
];

const AnimatedBackground: React.FC = React.memo(() => {
    const [particles, setParticles] = useState<any[]>([]);

    useEffect(() => {
        const newParticles = Array.from({ length: 20 }).map((_, i) => {
            const shape = shapes[Math.floor(Math.random() * shapes.length)];
            const size = Math.random() * 60 + 20; // 20px to 80px
            return {
                id: i,
                style: {
                    left: `${Math.random() * 100}%`,
                    width: `${size}px`,
                    height: `${size}px`,
                    animationDuration: `${Math.random() * 20 + 15}s`, // 15s to 35s
                    animationDelay: `${Math.random() * 15}s`,
                    opacity: Math.random() * 0.15 + 0.05, // 0.05 to 0.2
                    bottom: `-${size}px`,
                },
                className: `${shape.color} ${shape.type === 'circle' ? 'rounded-full' : 'rounded-lg'}`,
            };
        });
        setParticles(newParticles);
    }, []);

    return (
        <div className="absolute inset-0 z-0" aria-hidden="true">
            {particles.map(p => (
                <div
                    key={p.id}
                    className={`absolute animate-float-up ${p.className}`}
                    style={p.style}
                />
            ))}
        </div>
    );
});


const MainMenu: React.FC<MainMenuProps> = ({ onPlay, onLeaderboard, onBadges, onSettings, onShop, gems }) => {
  return (
    <div className="relative flex flex-col items-center justify-center h-[100svh] p-4 text-center bg-slate-200 overflow-hidden">
      <AnimatedBackground />
      <div className="absolute inset-0 bg-gradient-to-br from-sky-400 via-blue-500 to-indigo-600"></div>
      
      <div className="absolute top-4 right-4 z-20">
          <div className="flex items-center gap-2 px-4 py-2 rounded-xl text-white font-bold bg-black/20 backdrop-blur-md border border-white/20 shadow-md">
            <DiamondIcon size={20} />
            <span className="text-lg">{gems.toLocaleString()}</span>
          </div>
      </div>
      
      <div className="relative w-full max-w-sm">
        <h1 
            className="text-7xl md:text-8xl font-black text-white mb-2 leading-none animate-title-in"
            style={{ textShadow: '0 4px 15px rgba(0,0,0,0.1)' }}
        >
            Grid Dash
        </h1>
        <p className="text-lg text-white/90 mb-16 animate-title-in" style={{ animationDelay: '0.1s' }}>
            Blokları yerleştir, bulmacayı tamamla.
        </p>
        <div className="space-y-4">
            <div className="animate-button-in" style={{ animationDelay: '0.3s' }}>
              <MainMenuButton onClick={onPlay} icon={<PlayIcon />} text="Oyna" isPrimary />
            </div>
            <div className="animate-button-in" style={{ animationDelay: '0.4s' }}>
              <MainMenuButton onClick={onShop} icon={<CartIcon size={20} />} text="Dükkan" />
            </div>
            <div className="animate-button-in" style={{ animationDelay: '0.5s' }}>
              <MainMenuButton onClick={onLeaderboard} icon={<LeaderboardIcon size={20} />} text="Profilim" />
            </div>
            <div className="animate-button-in" style={{ animationDelay: '0.6s' }}>
              <MainMenuButton onClick={onBadges} icon={<TrophyIcon size={20} />} text="Başarımlar" />
            </div>
            <div className="animate-button-in" style={{ animationDelay: '0.7s' }}>
              <MainMenuButton onClick={onSettings} icon={<SettingsIcon size={20} />} text="Ayarlar" />
            </div>
        </div>
      </div>
    </div>
  );
};

interface MainMenuButtonProps {
    onClick: () => void;
    icon: React.ReactNode;
    text: string;
    isPrimary?: boolean;
    isDisabled?: boolean;
}

const MainMenuButton: React.FC<MainMenuButtonProps> = ({ onClick, icon, text, isPrimary, isDisabled }) => {
    const baseClasses = "w-full flex items-center justify-center gap-3 font-bold text-lg py-3.5 px-6 rounded-2xl transition-all duration-200 transform active:scale-95 focus:outline-none focus:ring-4";
    const { playSound } = useSound();
    const { vibrateClick } = useHaptics();

    const handleClick = () => {
        playSound('ui-click');
        vibrateClick();
        onClick();
    };

    if (isDisabled) {
        return (
            <button
                disabled
                className={`${baseClasses} bg-black/10 text-white/40 cursor-not-allowed`}
            >
                {icon}
                <span>{text}</span>
            </button>
        );
    }
    
    if (isPrimary) {
        return (
             <button
                onClick={handleClick}
                className={`${baseClasses} bg-white text-indigo-600 hover:bg-slate-50 focus:ring-indigo-200 shadow-2xl animate-subtle-pulse`}
            >
                {icon}
                <span className="text-xl">{text}</span>
            </button>
        )
    }

    return (
        <button
            onClick={handleClick}
            className={`${baseClasses} bg-black/10 backdrop-blur-lg border border-white/20 text-white hover:bg-black/20 focus:ring-white/50 hover:-translate-y-1`}
        >
            {icon}
            <span>{text}</span>
        </button>
    )
}


export default MainMenu;
