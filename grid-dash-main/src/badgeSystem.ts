import type { Badge, PlayerProgress } from './types';
import StarIcon from './components/icons/StarIcon';
import TrophyIcon from './components/icons/TrophyIcon';
import BoltIcon from './components/icons/BoltIcon';
import React from 'react';

const BadgeStarIcon: React.FC<{ className?: string }> = ({ className }) => {
  return React.createElement(StarIcon, { filled: true, size: 32, className });
};

export const allBadges: Badge[] = [
  {
    id: 'complete_level_1',
    name: 'İlk Adım',
    description: 'İlk seviyeyi tamamla.',
    icon: TrophyIcon,
  },
  {
    id: 'complete_level_10',
    name: 'Acemi Çözücü',
    description: '10 seviye tamamla.',
    icon: TrophyIcon,
  },
  {
    id: 'complete_level_25',
    name: 'Usta Çözücü',
    description: '25 seviye tamamla.',
    icon: TrophyIcon,
  },
  {
    id: 'star_collector_5',
    name: 'Yıldız Toplayıcısı',
    description: '5 farklı seviyede 3 yıldız kazan.',
    icon: BadgeStarIcon,
  },
  {
    id: 'star_collector_15',
    name: 'Süperstar',
    description: '15 farklı seviyede 3 yıldız kazan.',
    icon: BadgeStarIcon,
  },
  {
    id: 'speedster_15',
    name: 'Hız Canavarı',
    description: 'Bir seviyeyi 15 saniyenin altında bitir.',
    icon: BoltIcon,
  },
  {
    id: 'speedster_10',
    name: 'Işık Hızı',
    description: 'Bir seviyeyi 10 saniyenin altında bitir.',
    icon: BoltIcon,
  },
];

const badgeCheckers: { [key: string]: (progress: PlayerProgress) => boolean } = {
  complete_level_1: (progress) => progress.highestLevelCompleted >= 1,
  complete_level_10: (progress) => progress.highestLevelCompleted >= 10,
  complete_level_25: (progress) => progress.highestLevelCompleted >= 25,
  star_collector_5: (progress) => {
    const threeStarLevels = Object.values(progress.levelStats).filter(s => s.stars === 3);
    return threeStarLevels.length >= 5;
  },
  star_collector_15: (progress) => {
    const threeStarLevels = Object.values(progress.levelStats).filter(s => s.stars === 3);
    return threeStarLevels.length >= 15;
  },
  speedster_15: (progress) => {
    return Object.values(progress.levelStats).some(s => s.time < 15);
  },
  speedster_10: (progress) => {
    return Object.values(progress.levelStats).some(s => s.time < 10);
  },
};

export const checkAndAwardBadges = (progress: PlayerProgress): string[] => {
  const newlyEarned: string[] = [];
  const alreadyEarned = new Set(progress.earnedBadges || []);

  for (const badge of allBadges) {
    if (!alreadyEarned.has(badge.id)) {
      const checker = badgeCheckers[badge.id];
      if (checker && checker(progress)) {
        newlyEarned.push(badge.id);
      }
    }
  }

  return newlyEarned;
};