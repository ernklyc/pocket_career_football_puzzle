
import React from 'react';

export type Shape = number[][];

export interface Block {
  id: string;
  shape: Shape;
  color: string;
  initialShape: Shape;
}

export interface PlacedBlock extends Block {
  row: number;
  col: number;
}

export interface Level {
  id: number;
  levelNumber: number;
  name?: string;
  gridSize: { rows: number; cols: number };
  blocks: Block[];
  blockTypes?: string[];
  solution: { [blockId: string]: { row: number; col: number; shape: Shape } };
  starThresholds: { threeStar: number; twoStar: number };
  gemPositions: { row: number, col: number }[];
}

export type Screen = 'main-menu' | 'level-map' | 'game' | 'leaderboard' | 'badges' | 'settings' | 'shop';

export interface LevelStats {
  time: number;
  stars: number;
  bestTime?: number;
  score: number;
  bestScore?: number;
  gemsFromStars: number;
  gemsCollectedInLevel: number;
  gemsEarned: number;
  // Modal'da skor dökümünü göstermek için
  noHintBonus?: number;
  baseScore?: number;
  timeMultiplier?: number;
  timeBonus?: number;
}

export interface LogEntry {
  id: number;
  message: string;
  type: 'score' | 'powerup' | 'event' | 'bonus' | 'gem';
  icon?: React.FC<{className?: string, size?: number}>;
}


export interface Badge {
  id: string;
  name: string;
  description: string;
  icon: React.FC<{className?: string}>;
}

export interface PlayerLevelStats {
  time: number;
  stars: number;
  name?: string;
  bestScore?: number;
}

export interface Settings {
  soundVolume: number; // 0 to 1
  musicVolume: number; // 0 to 1
  haptics: boolean;
}

export interface PlayerProgress {
  userId: string; // New field for Firebase synchronization
  playerName: string;
  highestLevelCompleted: number;
  levelStats: { [level: string]: PlayerLevelStats };
  hints: number;
  timeShifts: number;
  nextTimedRewardTime: number; // timestamp
  earnedBadges: string[];
  solverPieces: number;
  hasSeenTutorial: boolean;
  settings: Settings;
  gems: number;
  weeklyGems: number;
  lastWeeklyReset: number;
}
