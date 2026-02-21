

import React, { useState, useRef, useMemo } from 'react';
import type { PlayerProgress, LevelStats } from '../types';
import StarIcon from './icons/StarIcon';
import DailyRewardIndicator from './TimedRewardChest';
import CheckIcon from './icons/CheckIcon';
import PlayIcon from './icons/PlayIcon';
import { getLevelConfig } from '../levelGenerator';
import LevelPreview from './LevelPreview';
import LockIcon from './icons/LockIcon';
import ArrowLeftIcon from './icons/ArrowLeftIcon';
import TrophyIcon from './icons/TrophyIcon';

interface LevelMapScreenProps {
  progress: PlayerProgress;
  onSelectLevel: (levelNumber: number) => void;
  onBack: () => void;
  onClaimDailyReward: () => void;
}

const formatTime = (seconds: number) => new Date(seconds * 1000).toISOString().substr(14, 5);

interface LevelCardProps {
    levelNum: number;
    isUnlocked: boolean;
    isCurrent: boolean;
    isCompleted: boolean;
    stats: { name?: string; stars: number; time: number; bestScore?: number } | undefined;
    onSelect: (level: number) => void;
    onPreviewStart: (level: number) => void;
    onPreviewEnd: () => void;
    isPreviewing: boolean;
}

const LevelCard: React.FC<LevelCardProps> = ({
    levelNum, isUnlocked, isCurrent, isCompleted, stats, onSelect, onPreviewStart, onPreviewEnd, isPreviewing
}) => {
    const levelConfig = useMemo(() => getLevelConfig(levelNum), [levelNum]);

    return (
        <div
            className="w-full z-10 relative"
            onMouseEnter={() => isUnlocked && onPreviewStart(levelNum)}
            onMouseLeave={onPreviewEnd}
            onTouchStart={() => isUnlocked && onPreviewStart(levelNum)}
            onTouchEnd={onPreviewEnd}
        >
            <button
                className="w-full group disabled:pointer-events-none"
                onClick={() => onSelect(levelNum)}
                disabled={!isUnlocked}
                aria-label={`Seviye ${levelNum}`}
            >
                <div className={`
                    w-full p-4 rounded-2xl flex items-center gap-4 transition-all duration-200 transform
                    ${!isUnlocked ? 'bg-slate-300/70' : 'bg-white/70 backdrop-blur-xl border border-white/20 shadow-md group-hover:shadow-lg group-active:scale-95'}
                    ${isCurrent ? 'animate-pulse-glow' : ''}
                    ${isCompleted ? 'bg-gradient-to-br from-indigo-500 to-blue-600 text-white shadow-lg' : ''}
                `}>
                    <div className={`
                        w-12 h-12 rounded-full flex-shrink-0 flex items-center justify-center font-black text-xl transition-colors
                        ${isCompleted ? 'bg-white/25' : ''}
                        ${isCurrent ? 'bg-sky-500 text-white' : ''}
                        ${!isCurrent && !isCompleted && isUnlocked ? 'bg-slate-100 text-slate-600' : ''}
                        ${!isUnlocked ? 'bg-slate-400/50 text-slate-500' : ''}
                    `}>
                        {isCompleted ? <CheckIcon /> : <span>{levelNum}</span>}
                    </div>

                    <div className="flex-1 text-left min-w-0">
                        <h3 className={`font-bold text-lg truncate ${!isUnlocked ? 'text-slate-500' : isCompleted ? 'text-white' : 'text-slate-800'}`}>
                          {(isCompleted && stats?.name) ? stats.name : `Seviye ${levelNum}`}
                        </h3>
                        {isCompleted ? (
                            <div className="flex items-center gap-3 text-sm mt-1">
                                <div className="flex">
                                    {[...Array(3)].map((_, i) => <StarIcon key={i} filled={i < (stats?.stars || 0)} size={16} isWhite={true} />)}
                                </div>
                                <span className="font-mono text-base text-white/90">{formatTime(stats?.time || 0)}</span>
                                <div className="flex items-center gap-1.5 text-white/90">
                                    <TrophyIcon size={14} className="text-white/70" /> 
                                    <span className="font-mono text-base">{(stats?.bestScore || 0).toLocaleString()}</span>
                                </div>
                            </div>
                        ) : isCurrent ? (
                            <p className="text-sm text-sky-600 font-semibold">Sıradaki Macera!</p>
                        ) : isUnlocked ? (
                            <p className="text-sm text-slate-500">Oynamaya Hazır</p>
                        ) : (
                            <p className="text-sm text-slate-500">Kilitli</p>
                        )}
                    </div>
                    {isUnlocked && !isCompleted && <div className="text-sky-500 opacity-30 group-hover:opacity-100 transition-opacity"><PlayIcon size={28}/></div>}
                    {!isUnlocked && <div className="text-slate-500/50"><LockIcon /></div>}
                </div>
            </button>
            {isPreviewing && (
                <LevelPreview 
                    key={levelNum}
                    gridSize={levelConfig.gridSize} 
                    blockTypes={levelConfig.blockTypes || []} 
                />
            )}
        </div>
    );
};


const LevelMapScreen: React.FC<LevelMapScreenProps> = ({ progress, onSelectLevel, onBack, onClaimDailyReward }) => {
  const { highestLevelCompleted, levelStats, nextTimedRewardTime } = progress;
  const currentLevelNumber = highestLevelCompleted + 1;
  
  const [previewingLevel, setPreviewingLevel] = useState<number | null>(null);
  const previewTimeoutRef = useRef<number | null>(null);

  const handlePreviewStart = (levelNum: number) => {
    if (previewTimeoutRef.current) clearTimeout(previewTimeoutRef.current);
    previewTimeoutRef.current = window.setTimeout(() => {
        setPreviewingLevel(levelNum);
    }, 100);
  };
  
  const handlePreviewEnd = () => {
    if (previewTimeoutRef.current) clearTimeout(previewTimeoutRef.current);
    setPreviewingLevel(null);
  };
  
  const completedLevels = Array.from({ length: highestLevelCompleted }, (_, i) => highestLevelCompleted - i);

  return (
    <div className="flex flex-col h-[100svh] p-2 sm:p-4 font-sans fade-in bg-slate-200">
       <div className="absolute inset-0 bg-gradient-to-br from-sky-200 via-blue-300 to-indigo-400"></div>
      <div className="relative w-full flex flex-col h-full">
        <main className="flex-1 overflow-y-auto scrollbar-hide">
            <header className="sticky top-0 sm:top-2 z-20 flex items-center justify-center p-3 mb-4 shrink-0 bg-white/60 backdrop-blur-xl border border-white/30 rounded-2xl shadow-lg w-full max-w-md md:max-w-2xl mx-auto">
              <button onClick={onBack} className="absolute left-4 p-2 bg-black/5 hover:bg-black/10 rounded-full text-slate-600 transition-colors">
                <ArrowLeftIcon />
              </button>
              <h1 className="text-2xl font-black text-slate-700">Seviyeler</h1>
            </header>
            
            <div className="flex flex-col items-center gap-6 relative px-2 py-4 w-full max-w-md md:max-w-2xl mx-auto">
                <div className="w-full">
                    <DailyRewardIndicator 
                        nextRewardTime={nextTimedRewardTime}
                        onClaim={onClaimDailyReward}
                    />
                </div>
                
                {/* Current Level */}
                <div className="w-full">
                    <h2 className="text-sm font-bold text-sky-600 uppercase tracking-wider mb-2 px-2">Sıradaki Seviye</h2>
                    <LevelCard
                        levelNum={currentLevelNumber}
                        isUnlocked={true}
                        isCurrent={true}
                        isCompleted={false}
                        stats={undefined}
                        onSelect={onSelectLevel}
                        onPreviewStart={handlePreviewStart}
                        onPreviewEnd={handlePreviewEnd}
                        isPreviewing={previewingLevel === currentLevelNumber}
                    />
                </div>

                {/* Completed Levels */}
                {completedLevels.length > 0 && (
                    <div className="w-full">
                        <h2 className="text-sm font-bold text-slate-500 uppercase tracking-wider mb-2 px-2">Tamamlananlar</h2>
                        <div className="flex flex-col gap-3">
                            {completedLevels.map(levelNum => (
                                <LevelCard
                                    key={levelNum}
                                    levelNum={levelNum}
                                    isUnlocked={true}
                                    isCurrent={false}
                                    isCompleted={true}
                                    stats={levelStats[levelNum]}
                                    onSelect={onSelectLevel}
                                    onPreviewStart={handlePreviewStart}
                                    onPreviewEnd={handlePreviewEnd}
                                    isPreviewing={previewingLevel === levelNum}
                                />
                            ))}
                        </div>
                    </div>
                )}
            </div>
        </main>
      </div>
    </div>
  );
};

export default LevelMapScreen;
