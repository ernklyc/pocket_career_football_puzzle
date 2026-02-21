
import React, { useState, useCallback, useEffect } from 'react';
import GameScreen from './components/GameScreen';
import MainMenu from './components/MainMenu';
import LevelMapScreen from './components/LevelMapScreen';
import LeaderboardScreen from './components/LeaderboardScreen';
import SettingsScreen from './components/SettingsScreen';
import ShopScreen from './components/ShopScreen';
import AdModal from './components/AdModal';
import LevelCompleteModal from './components/LevelCompleteModal';
import DailyRewardModal from './components/DailyRewardModal';
import BadgesScreen from './components/BadgesScreen';
import BadgeNotificationToast from './components/BadgeNotificationToast';
import { generateLevel, getLevelConfig } from './levelGenerator';
import type { Level, Screen, PlayerProgress, LevelStats, Badge } from './types';
import { loadProgress, saveProgress, STORAGE_KEY } from './storage';
import { checkAndAwardBadges, allBadges } from './badgeSystem';
import { generateLevelName } from './gemini';
import { SettingsProvider } from './contexts/SettingsContext';
import { useSound } from './hooks/useSound';
import BackgroundMusic from './components/BackgroundMusic';
import ConfirmationModal from './components/ConfirmationModal';
import { SHOP_ITEMS } from './components/ShopScreen';
import SplashScreen from './components/SplashScreen';

const DAILY_REWARD_COOLDOWN_MS = 24 * 60 * 60 * 1000; // 24 hours
const ONE_WEEK_MS = 7 * 24 * 60 * 60 * 1000;

const AppContent: React.FC = () => {
  const [isShowingSplash, setIsShowingSplash] = useState(true);
  const [screen, setScreen] = useState<Screen>('main-menu');
  const [currentLevel, setCurrentLevel] = useState<Level | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [progress, setProgress] = useState<PlayerProgress>(loadProgress());
  
  const [adModalOpen, setAdModalOpen] = useState(false);
  const [isWatchingAd, setIsWatchingAd] = useState(false);

  const [completedLevelInfo, setCompletedLevelInfo] = useState<{ levelNumber: number; levelName?: string; stats: LevelStats & { isNewRecord: boolean; isNewBestScore: boolean; noHintBonus: number; baseScore: number; timeMultiplier: number; timeBonus: number; } } | null>(null);
  const [isLevelCompleteModalOpen, setIsLevelCompleteModalOpen] = useState(false);
  const [isDailyRewardModalOpen, setIsDailyRewardModalOpen] = useState(false);
  const [isResetModalOpen, setIsResetModalOpen] = useState(false);
  const [newlyEarnedBadges, setNewlyEarnedBadges] = useState<Badge[]>([]);
  const { playSound } = useSound();

  useEffect(() => {
    const timer = setTimeout(() => {
        setIsShowingSplash(false);
    }, 2500); // Duration of the splash screen
    return () => clearTimeout(timer);
  }, []);

  // Save progress whenever it changes
  useEffect(() => {
    saveProgress(progress);
  }, [progress]);

  // Check for weekly reset on app load
  useEffect(() => {
    const now = Date.now();
    if (progress.lastWeeklyReset && now > progress.lastWeeklyReset) {
      setProgress(prev => ({
        ...prev,
        weeklyGems: 0,
        lastWeeklyReset: now + ONE_WEEK_MS,
      }));
    }
  }, []); // Run only on mount

  const handleSelectLevel = useCallback(async (levelNumber: number) => {
    setIsLoading(true);
    setCurrentLevel(null);
    setScreen('game');

    const config = getLevelConfig(levelNumber);
    const newLevel = generateLevel(config);
    // FIX: Removed defensive check for gemPositions, as it's now guaranteed by the generator.
    setCurrentLevel(newLevel);
    setIsLoading(false);

    try {
      const blockTypes = newLevel.blockTypes || getLevelConfig(levelNumber).blockTypes;
      const name = await generateLevelName(newLevel.gridSize, blockTypes);
      setCurrentLevel(prevLevel => (prevLevel && prevLevel.id === newLevel.id ? { ...prevLevel, name } : prevLevel));
    } catch (error) {
      console.error("Error fetching level name:", error);
    }
  }, []);

  const handleLevelComplete = useCallback((stats: { time: number, levelId: number, baseScore: number, hintsUsed: number, gemsCollectedInLevel: number}) => {
    if (!currentLevel || stats.levelId !== currentLevel.id) return;

    const { time, baseScore, hintsUsed, gemsCollectedInLevel } = stats;
    const levelNumber = currentLevel.levelNumber;
    const { threeStar, twoStar } = currentLevel.starThresholds;

    let timeMultiplier = 1.0;
    if (time <= threeStar) {
      timeMultiplier = 2.0;
    } else if (time <= twoStar) {
      timeMultiplier = 1.5;
    }
    const multipliedScore = Math.round(baseScore * timeMultiplier);
    const timeBonus = multipliedScore - baseScore;
    const noHintBonus = hintsUsed === 0 ? Math.round(baseScore * 0.25) : 0;
    const score = multipliedScore + noHintBonus;

    let stars = 1;
    if (time <= threeStar) stars = 3;
    else if (time <= twoStar) stars = 2;
    
    const gemsFromStars = stars;
    const totalGemsEarned = gemsFromStars + gemsCollectedInLevel;

    setProgress(prev => {
        const existingStats = prev.levelStats[levelNumber];
        const isNewRecord = !existingStats || time < existingStats.time;
        const bestTime = isNewRecord ? time : existingStats.time;
        const bestStars = Math.max(stars, existingStats?.stars || 0);

        const isNewBestScore = !existingStats || !existingStats.bestScore || score > existingStats.bestScore;
        const bestScore = isNewBestScore ? score : (existingStats.bestScore || 0);
        
        // FIX: Removed redundant local `gemsEarned` and used `totalGemsEarned` from the outer scope for clarity.
        setCompletedLevelInfo({ 
            levelNumber, 
            levelName: currentLevel.name, 
            stats: { 
                time, stars, bestTime, isNewRecord, 
                score, bestScore, isNewBestScore, 
                noHintBonus, baseScore, timeMultiplier, timeBonus, 
                gemsFromStars, gemsCollectedInLevel, gemsEarned: totalGemsEarned
            } 
        });
        setIsLevelCompleteModalOpen(true);

        const updatedStats = { ...prev.levelStats };
        updatedStats[levelNumber] = { time: bestTime, stars: bestStars, name: currentLevel.name, bestScore };

        const updatedProgress: PlayerProgress = {
            ...prev,
            highestLevelCompleted: Math.max(prev.highestLevelCompleted, levelNumber),
            levelStats: updatedStats,
            earnedBadges: prev.earnedBadges || [],
            gems: prev.gems + totalGemsEarned,
            weeklyGems: prev.weeklyGems + totalGemsEarned,
        };
        
        const newBadgeIds = checkAndAwardBadges(updatedProgress);
        
        if (newBadgeIds.length > 0) {
            const newBadges = allBadges.filter(b => newBadgeIds.includes(b.id));
            setNewlyEarnedBadges(current => {
              const currentIds = new Set(current.map(b => b.id));
              const filteredNewBadges = newBadges.filter(b => !currentIds.has(b.id));
              return [...current, ...filteredNewBadges];
            });

            return {
                ...updatedProgress,
                earnedBadges: [...new Set([...updatedProgress.earnedBadges, ...newBadgeIds])]
            };
        }

        return updatedProgress;
    });
    
  }, [currentLevel]);
  
  const handleSaveName = (newName: string) => {
    if (newName.trim()) {
        setProgress(prev => ({...prev, playerName: newName.trim()}));
    }
  };

  const handleUseHint = useCallback(() => {
    if (progress.hints > 0) {
      setProgress(prev => ({ ...prev, hints: prev.hints - 1 }));
      return true;
    }
    setAdModalOpen(true);
    return false;
  }, [progress.hints]);
  
  const handleUseTimeShift = useCallback(() => {
    if (progress.timeShifts > 0) {
      setProgress(prev => ({ ...prev, timeShifts: prev.timeShifts - 1 }));
      return true;
    }
    return false;
  }, [progress.timeShifts]);

  const handleUseSolverPiece = useCallback(() => {
    if (progress.solverPieces > 0) {
      setProgress(prev => ({ ...prev, solverPieces: prev.solverPieces - 1 }));
      return true;
    }
    return false;
  }, [progress.solverPieces]);

  const handleWatchAd = useCallback(() => {
    setAdModalOpen(false);
    setIsWatchingAd(true);
    setTimeout(() => {
      setProgress(prev => ({ ...prev, hints: prev.hints + 1 }));
      setIsWatchingAd(false);
    }, 2500);
  }, []);

  const handleClaimDailyReward = () => {
    if (Date.now() >= progress.nextTimedRewardTime) {
      playSound('ui-click');
      setIsDailyRewardModalOpen(true);
    }
  };

  const handleConfirmDailyRewardClaim = (reward: { hints?: number, timeShifts?: number, solverPieces?: number, gems?: number }) => {
    setProgress(prev => ({
      ...prev,
      hints: prev.hints + (reward.hints || 0),
      timeShifts: prev.timeShifts + (reward.timeShifts || 0),
      solverPieces: prev.solverPieces + (reward.solverPieces || 0),
      gems: prev.gems + (reward.gems || 0),
      weeklyGems: prev.weeklyGems + (reward.gems || 0),
      nextTimedRewardTime: Date.now() + DAILY_REWARD_COOLDOWN_MS,
    }));
  };
  
  const handleRequestResetProgress = () => {
    setIsResetModalOpen(true);
  };
  
  const handleConfirmResetProgress = () => {
    localStorage.removeItem(STORAGE_KEY);
    window.location.reload();
  };

  const handleDismissBadge = (badgeId: string) => {
      setNewlyEarnedBadges(current => current.filter(b => b.id !== badgeId));
  };

  const navigateTo = (newScreen: Screen) => {
    playSound('ui-click');
    if (newScreen !== 'game') {
        setCurrentLevel(null);
    }
    setScreen(newScreen);
  }
  
  const handleCloseCompleteModal = () => {
    setIsLevelCompleteModalOpen(false);
    setCompletedLevelInfo(null);
    navigateTo('level-map');
  };
  
  const handleReplay = () => {
    if (!completedLevelInfo) return;
    setIsLevelCompleteModalOpen(false);
    const levelToReplay = completedLevelInfo.levelNumber;
    setCompletedLevelInfo(null);
    handleSelectLevel(levelToReplay);
  };

  const handleNextLevel = () => {
     if (!completedLevelInfo) return;
    setIsLevelCompleteModalOpen(false);
    const nextLevelNumber = completedLevelInfo.levelNumber + 1;
    setCompletedLevelInfo(null);
    handleSelectLevel(nextLevelNumber);
  };
  
  const handleCollectGem = useCallback((gemValue: number) => {
      setProgress(prev => ({
          ...prev,
          gems: prev.gems + gemValue,
          weeklyGems: prev.weeklyGems + gemValue,
      }));
  }, []);
  
  const handlePurchase = (itemId: keyof typeof SHOP_ITEMS) => {
    const item = SHOP_ITEMS[itemId];
    if (!item) return;

    setProgress(prev => {
        if (prev.gems < item.price) {
            playSound('purchase-fail');
            return prev;
        }

        playSound('purchase-success');
        
        const powerUpKey = item.powerUpKey as 'hints' | 'timeShifts' | 'solverPieces';
        const currentPowerUpCount = prev[powerUpKey];

        return {
            ...prev,
            gems: prev.gems - item.price,
            [powerUpKey]: currentPowerUpCount + 1,
        };
    });
  };

  const handlePurchaseGems = useCallback((gemAmount: number) => {
    playSound('purchase-success');
    setProgress(prev => ({
      ...prev,
      gems: prev.gems + gemAmount,
      weeklyGems: prev.weeklyGems + gemAmount,
    }));
  }, [playSound]);

  const handleTutorialComplete = () => {
    setProgress(prev => ({ ...prev, hasSeenTutorial: true }));
  };

  if (isShowingSplash) {
      return <SplashScreen />;
  }


  const renderScreen = () => {
      switch (screen) {
        case 'game':
          if (isLoading || !currentLevel) {
            return (
              <div className="flex flex-col items-center justify-center min-h-screen p-4 text-center">
                <div className="w-12 h-12 border-4 border-sky-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                <h2 className="text-2xl font-bold text-slate-700">Seviye Oluşturuluyor...</h2>
              </div>
            );
          }
          return (
            <GameScreen
              key={currentLevel.id}
              level={currentLevel}
              onLevelComplete={handleLevelComplete}
              onBack={() => navigateTo('main-menu')}
              hints={progress.hints}
              onUseHint={handleUseHint}
              timeShifts={progress.timeShifts}
              onUseTimeShift={handleUseTimeShift}
              solverPieces={progress.solverPieces}
              onUseSolverPiece={handleUseSolverPiece}
              gems={progress.gems}
              onCollectGem={handleCollectGem}
              hasSeenTutorial={progress.hasSeenTutorial}
              onTutorialComplete={handleTutorialComplete}
            />
          );
        case 'level-map':
          return <LevelMapScreen 
            progress={progress} 
            onSelectLevel={handleSelectLevel} 
            onBack={() => navigateTo('main-menu')} 
            onClaimDailyReward={handleClaimDailyReward}
          />;
        case 'leaderboard':
          return <LeaderboardScreen progress={progress} onSaveName={handleSaveName} onBack={() => navigateTo('main-menu')} />;
        case 'badges':
          return <BadgesScreen progress={progress} onBack={() => navigateTo('main-menu')} />;
        case 'settings':
            return <SettingsScreen onBack={() => navigateTo('main-menu')} onResetProgress={handleRequestResetProgress} />;
        case 'shop':
            return <ShopScreen 
                progress={progress} 
                onPurchase={handlePurchase} 
                onPurchaseGems={handlePurchaseGems} 
                onBack={() => navigateTo('main-menu')} 
            />;
        default:
          return (
            <MainMenu 
                onPlay={() => navigateTo('level-map')}
                onLeaderboard={() => navigateTo('leaderboard')}
                onBadges={() => navigateTo('badges')}
                onSettings={() => navigateTo('settings')}
                onShop={() => navigateTo('shop')}
                gems={progress.gems}
            />
          );
      }
  }

  return (
    <div className="antialiased">
      <div className="relative z-10">
        {renderScreen()}
      </div>
      <BadgeNotificationToast badges={newlyEarnedBadges} onDismiss={handleDismissBadge} />
      <AdModal 
        isOpen={adModalOpen}
        onClose={() => setAdModalOpen(false)}
        onConfirm={handleWatchAd}
      />
      {isLevelCompleteModalOpen && completedLevelInfo && (
        <LevelCompleteModal 
          key={completedLevelInfo.levelNumber}
          isOpen={isLevelCompleteModalOpen}
          levelNumber={completedLevelInfo.levelNumber}
          levelName={completedLevelInfo.levelName}
          stats={completedLevelInfo.stats}
          onNext={handleNextLevel}
          onReplay={handleReplay}
          onMap={handleCloseCompleteModal}
        />
      )}
       <DailyRewardModal 
        isOpen={isDailyRewardModalOpen}
        onClaim={handleConfirmDailyRewardClaim}
        onClose={() => setIsDailyRewardModalOpen(false)}
      />
      <ConfirmationModal
        isOpen={isResetModalOpen}
        onClose={() => setIsResetModalOpen(false)}
        onConfirm={handleConfirmResetProgress}
        title="İlerlemeyi Sıfırla"
        message="Tüm seviye verilerin, puanların ve başarımların silinecek. Bu işlem geri alınamaz. Emin misin?"
        confirmText="Sıfrla"
        cancelText="İptal"
      />
      {isWatchingAd && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex flex-col items-center justify-center z-[60]">
          <div className="w-12 h-12 border-4 border-sky-500 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-white text-lg mt-4">Ödülünüz hazırlanıyor...</p>
        </div>
      )}
    </div>
  );
};

const App: React.FC = () => {
    const [progress, setProgress] = useState<PlayerProgress>(loadProgress());

    return (
        <SettingsProvider progress={progress} setProgress={setProgress}>
            <BackgroundMusic />
            <AppContent />
        </SettingsProvider>
    );
};

export default App;