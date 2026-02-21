

import React from 'react';
import type { PlayerProgress, Badge } from '../types';
import { allBadges } from '../badgeSystem';
import LockIcon from './icons/LockIcon';
import ArrowLeftIcon from './icons/ArrowLeftIcon';

interface BadgesScreenProps {
  progress: PlayerProgress;
  onBack: () => void;
}

const BadgeCard: React.FC<{ badge: Badge; isEarned: boolean }> = ({ badge, isEarned }) => {
  const Icon = badge.icon;
  
  if (isEarned) {
    // Vibrant card for earned achievements
    return (
      <div className="bg-white/80 backdrop-blur-xl border-2 border-sky-300 shadow-lg rounded-2xl p-4 flex flex-col items-center text-center transition-all h-48">
        <div className="w-16 h-16 bg-sky-100 rounded-full flex items-center justify-center mb-3 border-4 border-white shadow-md">
            <Icon className="text-sky-500 w-8 h-8" />
        </div>
        <div className="flex flex-col flex-grow items-center justify-center">
            <h3 className="font-bold text-base text-slate-800 leading-tight">{badge.name}</h3>
            <p className="text-xs text-slate-500 font-medium mt-1 px-1">{badge.description}</p>
        </div>
      </div>
    );
  }

  // Muted card for locked achievements
  return (
    <div className="bg-white/50 backdrop-blur-xl border border-white/20 shadow-sm rounded-2xl p-4 flex flex-col items-center justify-center text-center transition-all h-48 opacity-70">
        <div className="w-16 h-16 bg-slate-200 rounded-full flex items-center justify-center mb-3">
            <LockIcon size={32} className="text-slate-400" />
        </div>
        <div className="flex flex-col items-center justify-center">
            <h3 className="font-bold text-base text-slate-600 mb-1">Gizli Başarım</h3>
            <p className="text-xs text-slate-500">Kilidi açmak için oyna.</p>
        </div>
    </div>
  );
};


const BadgesScreen: React.FC<BadgesScreenProps> = ({ progress, onBack }) => {
  const earnedBadges = new Set(progress.earnedBadges || []);

  return (
    <div className="flex flex-col h-[100svh] font-display bg-slate-200">
      <div className="absolute inset-0 bg-gradient-to-br from-sky-100 via-blue-200 to-indigo-300"></div>
      <div className="relative w-full max-w-lg mx-auto flex flex-col h-full">
        <header className="sticky top-0 sm:top-2 z-20 w-full flex-shrink-0 flex items-center justify-center p-3 my-2 bg-white/60 backdrop-blur-xl border border-white/30 rounded-2xl shadow-lg">
            <button onClick={onBack} className="absolute left-4 p-2 bg-black/5 hover:bg-black/10 rounded-full text-slate-600 transition-colors">
                <ArrowLeftIcon />
            </button>
            <h1 className="text-2xl font-black text-slate-700">Başarımlar</h1>
        </header>

        <main className="flex-1 overflow-y-auto scrollbar-hide px-2 pb-4">
          <div className="grid grid-cols-2 gap-4">
            {allBadges.map((badge) => (
              <BadgeCard
                key={badge.id}
                badge={badge}
                isEarned={earnedBadges.has(badge.id)}
              />
            ))}
          </div>
        </main>
      </div>
    </div>
  );
};

export default BadgesScreen;