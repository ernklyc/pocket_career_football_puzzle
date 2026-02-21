import React, { useEffect } from 'react';
import type { LevelStats } from '../types';
import StarIcon from './icons/StarIcon';
import ReplayIcon from './icons/ReplayIcon';
import MapIcon from './icons/MapIcon';
import NextIcon from './icons/NextIcon';
import { useSound } from '../hooks/useSound';
import { useHaptics } from '../hooks/useHaptics';
import DiamondIcon from './icons/DiamondIcon';

interface LevelCompleteModalProps {
  isOpen: boolean;
  levelNumber: number;
  levelName?: string;
  stats: LevelStats & { isNewRecord: boolean; isNewBestScore: boolean; noHintBonus: number; baseScore: number; timeMultiplier: number; timeBonus: number; };
  onNext: () => void;
  onReplay: () => void;
  onMap: () => void;
}

const StatRow: React.FC<{ label: string; value: string | number; isBonus?: boolean; isTotal?: boolean; isNewBest?: boolean; icon?: React.ReactNode }> = ({ label, value, isBonus, isTotal, isNewBest, icon }) => (
  <div className={`flex justify-between items-baseline ${isTotal ? 'py-3 my-1 border-t border-b border-slate-700/80' : ''}`}>
    <span className="text-slate-400 text-base flex items-center gap-2">
        {icon}
        {label}
    </span>
    <span className={`font-bold font-mono ${
      isTotal ? 'text-3xl text-sky-400' : 'text-xl'
    } ${
      isNewBest ? 'text-sky-300 animate-pulse' : isBonus ? 'text-emerald-400' : 'text-white'
    }`}>
      {value}
    </span>
  </div>
);

const LevelCompleteModal: React.FC<LevelCompleteModalProps> = ({
  isOpen,
  levelNumber,
  levelName,
  stats,
  onNext,
  onReplay,
  onMap,
}) => {
  const { playSound } = useSound();

  useEffect(() => {
    if (isOpen) {
      playSound('level-complete');
    }
  }, [isOpen, playSound]);

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 bg-slate-900/50 backdrop-blur-lg flex items-center justify-center z-50 p-4"
      aria-modal="true"
      role="dialog"
    >
      <div className="bg-gradient-to-br from-slate-800 via-slate-900 to-black rounded-2xl p-6 sm:p-8 max-w-sm w-full text-center border-2 border-sky-400/50 shadow-2xl modal-fade-in-scale animate-level-complete-glow">
        <div className="animate-scale-in">
          {levelName ? (
            <>
              <h2 className="text-3xl sm:text-4xl font-black text-sky-400 leading-tight">{levelName}</h2>
              <p className="text-slate-300 text-lg mt-1">Seviye {levelNumber} Tamamlandı</p>
            </>
          ) : (
            <>
              <h2 className="text-3xl sm:text-4xl font-black text-sky-400">Tebrikler!</h2>
              <p className="text-slate-300 text-lg mt-1">Seviye {levelNumber} Tamamlandı</p>
            </>
          )}
        </div>
        
        <div className="my-6 flex justify-center gap-4 h-12">
          {[...Array(3)].map((_, i) => (
            <div
              key={i}
              className="animate-star-pop-in"
              style={{ animationDelay: `${0.3 + i * 0.15}s` }}
            >
              <StarIcon filled={i < stats.stars} size={48} isWhite={true} />
            </div>
          ))}
        </div>
        
        <div className="my-6 bg-slate-800/50 border border-slate-700 rounded-xl p-4 space-y-2 animate-slide-in-up-fade" style={{ animationDelay: '0.8s' }}>
            <StatRow label="Temel Puan" value={stats.baseScore.toLocaleString()} />
            {stats.timeBonus > 0 && (
                <StatRow label="Zaman Bonusu" value={`+${stats.timeBonus.toLocaleString()}`} isBonus />
            )}
            {stats.noHintBonus > 0 && (
                <StatRow label="İpuçsuz Bonus" value={`+${stats.noHintBonus.toLocaleString()}`} isBonus />
            )}
            <StatRow label="Toplam Puan" value={stats.score.toLocaleString()} isTotal isNewBest={stats.isNewBestScore} />
            <StatRow 
              label="Kazanılan Elmas" 
              value={`+${stats.gemsEarned}`} 
              isBonus 
              icon={<DiamondIcon size={16} className="text-slate-400" />}
            />
        </div>
        
        {(stats.isNewRecord || stats.isNewBestScore) && (
           <div className="text-sky-400 font-bold text-center animate-pulse text-base mb-6 animate-scale-in flex flex-col items-center" style={{animationDelay: '1.3s'}}>
                {stats.isNewRecord && <span>Yeni Süre Rekoru!</span>}
                {stats.isNewBestScore && <span>Yeni Puan Rekoru!</span>}
            </div>
        )}

        <div className="mt-6 grid grid-cols-3 gap-3 animate-slide-in-up-fade" style={{animationDelay: '1.4s'}}>
          <IconButton onClick={onReplay} icon={<ReplayIcon />} text="Tekrar" />
          <IconButton onClick={onMap} icon={<MapIcon />} text="Harita" />
          <IconButton onClick={onNext} icon={<NextIcon />} text="Sonraki" isPrimary />
        </div>
      </div>
      <style>{`
        .animate-star-pop-in {
            animation: star-pop-in 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
            opacity: 0; 
            transform: scale(0);
        }
        @keyframes star-pop-in {
          to { transform: scale(1); opacity: 1; }
        }
      `}</style>
    </div>
  );
};


interface IconButtonProps {
  onClick: () => void;
  icon: React.ReactNode;
  text: string;
  isPrimary?: boolean;
}

const IconButton: React.FC<IconButtonProps> = ({ onClick, text, icon, isPrimary }) => {
  const baseClasses = "w-full flex flex-col items-center justify-center gap-2 font-semibold py-3 px-2 sm:px-4 rounded-xl transition-all duration-200 transform active:scale-90 focus:outline-none focus:ring-4";
  const { playSound } = useSound();
  const { vibrateClick } = useHaptics();

  const handleClick = () => {
    playSound('ui-click');
    vibrateClick();
    onClick();
  };

  if (isPrimary) {
    return (
      <button onClick={handleClick} className={`${baseClasses} bg-sky-500 hover:bg-sky-600 text-white focus:ring-sky-300/50`}>
        {icon}
        <span>{text}</span>
      </button>
    );
  }

  return (
    <button onClick={handleClick} className={`${baseClasses} bg-slate-700/80 hover:bg-slate-700 text-slate-200 focus:ring-slate-600`}>
      {icon}
      <span>{text}</span>
    </button>
  );
};


export default LevelCompleteModal;