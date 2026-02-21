
import type { PlayerProgress } from './types';

export const STORAGE_KEY = 'gridDashProgress';

// Helper to generate a UUID-like string for the user ID
const generateUUID = () => {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
};

// This migration function ensures old players' data is compatible with new versions
const migrateProgress = (progress: any): PlayerProgress => {
  // If progress has levelTimes, convert it to levelStats
  if (progress.levelTimes && !progress.levelStats) {
    progress.levelStats = {};
    for (const levelNum in progress.levelTimes) {
      progress.levelStats[levelNum] = {
        time: progress.levelTimes[levelNum],
        stars: 1, // Grant 1 star for previously completed levels
        bestScore: 0, // Initialize bestScore
      };
    }
  }
  delete progress.levelTimes; // Remove the old property
  delete progress.lastLogin; // Remove old property
  
  const oldSettings = progress.settings || {};
  const newSettings = {
    soundVolume: typeof oldSettings.sound === 'boolean' 
        ? (oldSettings.sound ? 0.7 : 0) 
        : (typeof oldSettings.soundVolume === 'number' ? oldSettings.soundVolume : 0.7),
    musicVolume: typeof oldSettings.musicVolume === 'number' ? oldSettings.musicVolume : 0.25,
    haptics: typeof oldSettings.haptics === 'boolean' ? oldSettings.haptics : true,
  };

  const levelStats = progress.levelStats || {};
  for (const level in levelStats) {
      if (typeof levelStats[level].bestScore !== 'number') {
          levelStats[level].bestScore = 0;
      }
  }

  const ONE_WEEK_MS = 7 * 24 * 60 * 60 * 1000;
  
  // Ensure userId exists
  const userId = progress.userId || generateUUID();

  return {
    userId: userId,
    playerName: progress.playerName || 'Player',
    highestLevelCompleted: progress.highestLevelCompleted || 0,
    levelStats: levelStats,
    hints: typeof progress.hints === 'number' ? progress.hints : 3,
    timeShifts: typeof progress.timeShifts === 'number' ? progress.timeShifts : 1,
    nextTimedRewardTime: progress.nextTimedRewardTime || Date.now(),
    earnedBadges: progress.earnedBadges || [],
    solverPieces: typeof progress.solverPieces === 'number' ? progress.solverPieces : 1,
    hasSeenTutorial: progress.hasSeenTutorial || false,
    settings: newSettings,
    gems: typeof progress.gems === 'number' ? progress.gems : 0,
    weeklyGems: typeof progress.weeklyGems === 'number' ? progress.weeklyGems : 0,
    lastWeeklyReset: typeof progress.lastWeeklyReset === 'number' ? progress.lastWeeklyReset : (Date.now() + ONE_WEEK_MS),
  };
};


export const loadProgress = (): PlayerProgress => {
  try {
    const saved = window.localStorage.getItem(STORAGE_KEY);
    if (saved) {
      const progress = JSON.parse(saved);
      return migrateProgress(progress);
    }
  } catch (error) {
    console.error('Failed to load progress from localStorage', error);
  }
  
  // Return default state for new players
  return {
    userId: generateUUID(),
    playerName: 'Player',
    highestLevelCompleted: 0,
    levelStats: {},
    hints: 3,
    timeShifts: 1,
    solverPieces: 1,
    nextTimedRewardTime: Date.now(),
    earnedBadges: [],
    hasSeenTutorial: false,
    settings: { soundVolume: 0.7, musicVolume: 0.25, haptics: true },
    gems: 0,
    weeklyGems: 0,
    lastWeeklyReset: Date.now() + (7 * 24 * 60 * 60 * 1000),
  };
};

export const saveProgress = (progress: PlayerProgress) => {
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
  } catch (error) {
    console.error('Failed to save progress to localStorage', error);
  }
};
