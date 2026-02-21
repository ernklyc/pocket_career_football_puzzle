
import React, { useState, useMemo } from 'react';
import type { PlayerProgress, PlayerLevelStats } from '../types';
import { allBadges } from '../badgeSystem';
import ArrowLeftIcon from './icons/ArrowLeftIcon';
import TrophyIcon from './icons/TrophyIcon';
import StarIcon from './icons/StarIcon';
import PencilIcon from './icons/PencilIcon';
import ClockIcon from './icons/ClockIcon';
import DiamondIcon from './icons/DiamondIcon';
import FlagIcon from './icons/FlagIcon';
import GlobeIcon from './icons/GlobeIcon';
import useCountdown from '../hooks/useCountdown';

interface LeaderboardScreenProps {
  progress: PlayerProgress;
  onSaveName: (newName: string) => void;
  onBack: () => void;
}

const formatTotalTime = (totalSeconds: number): string => {
    if (isNaN(totalSeconds) || totalSeconds === 0) return '0sn';
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = Math.floor(totalSeconds % 60);

    const parts: string[] = [];
    if (hours > 0) parts.push(`${hours}s`);
    if (minutes > 0) parts.push(`${minutes}d`);
    if (seconds > 0 || parts.length === 0) parts.push(`${seconds}sn`);

    return parts.join(' ');
};

const AVATAR_STYLES = ['fun-emoji'];

const getAvatarStyle = (seed: string) => {
  if (!seed) return AVATAR_STYLES[0];
  const hash = seed.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
  return AVATAR_STYLES[hash % AVATAR_STYLES.length];
};

const statCardThemes = [
    { bg: 'bg-rose-100', iconBg: 'bg-rose-200', iconColor: 'text-rose-500' },
    { bg: 'bg-sky-100', iconBg: 'bg-sky-200', iconColor: 'text-sky-500' },
    { bg: 'bg-amber-100', iconBg: 'bg-amber-200', iconColor: 'text-amber-500' },
    { bg: 'bg-emerald-100', iconBg: 'bg-emerald-200', iconColor: 'text-emerald-500' },
];

const StatCard: React.FC<{ icon: React.ReactNode; label: string; value: string | number; index: number }> = ({ icon, label, value, index }) => {
    const theme = statCardThemes[index % statCardThemes.length];
    return (
        <div className={`${theme.bg} p-4 rounded-2xl flex flex-col items-center justify-center text-center shadow-inner-cute h-full`}>
            <div className={`w-12 h-12 ${theme.iconBg} ${theme.iconColor} rounded-full flex items-center justify-center mb-3`}>
                {icon}
            </div>
            <p className="text-2xl font-black text-slate-700">{value}</p>
            <p className="text-sm text-slate-500 font-medium truncate">{label}</p>
        </div>
    );
};

const PlayerStatsTab: React.FC<{ progress: PlayerProgress, onSaveName: (name: string) => void }> = ({ progress, onSaveName }) => {
    const [isEditing, setIsEditing] = useState(false);
    const [name, setName] = useState(progress.playerName);

    const handleSave = () => {
        if (name.trim()) {
            onSaveName(name.trim());
        }
        setIsEditing(false);
    };
    
    const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
        if (e.key === 'Enter') {
            handleSave();
        } else if (e.key === 'Escape') {
            setName(progress.playerName);
            setIsEditing(false);
        }
    }

    const { totalScore, totalStars, totalPlayTime, completedLevels, badgesEarned, averageStars } = useMemo(() => {
        const statsValues: PlayerLevelStats[] = Object.values(progress.levelStats || {});
        const playTime = statsValues.reduce((acc, stat) => acc + (stat.time || 0), 0);
        const stars = statsValues.reduce((acc, stat) => acc + (stat.stars || 0), 0);
        const levels = progress.highestLevelCompleted || 0;
        
        return {
          totalScore: statsValues.reduce((acc, stat) => acc + (stat.bestScore || 0), 0),
          totalStars: stars,
          totalPlayTime: playTime,
          completedLevels: levels,
          badgesEarned: progress.earnedBadges ? progress.earnedBadges.length : 0,
          averageStars: levels > 0 ? (stars / levels).toFixed(1) : '0.0'
        }
    }, [progress]);
    
    const playerAvatarStyle = getAvatarStyle(progress.playerName);
    const playerAvatarUrl = `https://api.dicebear.com/8.x/${playerAvatarStyle}/svg?seed=${progress.playerName}`;

    return (
        <div className="space-y-6">
            <div className="bg-white p-6 rounded-2xl shadow-lg border border-slate-200/50">
                <div className="flex items-center gap-4 mb-6">
                    <img alt="Your avatar" className="w-16 h-16 rounded-full border-2 border-slate-200 bg-slate-200" src={playerAvatarUrl} />
                    <div className="flex-1 min-w-0">
                        {isEditing ? (
                            <input 
                                type="text"
                                value={name}
                                onChange={(e) => setName(e.target.value)}
                                onKeyDown={handleKeyDown}
                                onBlur={handleSave}
                                className="w-full bg-transparent border-b-2 border-slate-300 p-0 text-slate-800 text-2xl font-bold focus:outline-none focus:ring-0 placeholder-slate-400"
                                autoFocus
                                maxLength={15}
                            />
                        ) : (
                            <div className="flex items-center gap-2 cursor-pointer" onClick={() => setIsEditing(true)}>
                                <h2 className="font-bold text-2xl truncate text-slate-800">{name}</h2>
                                <PencilIcon size={16} className="text-slate-500" />
                            </div>
                        )}
                        <p className="text-slate-500 font-semibold">Seviye {(progress.highestLevelCompleted || 0) + 1}</p>
                    </div>
                </div>
                
                <div className="grid grid-cols-3 gap-4 text-center">
                     <div>
                        <p className="text-sm text-slate-500">Toplam Elmas</p>
                        <p className="text-2xl font-bold text-slate-800">{progress.gems.toLocaleString()}</p>
                    </div>
                    <div>
                        <p className="text-sm text-slate-500">En Yüksek Seviye</p>
                        <p className="text-2xl font-bold text-slate-800">{completedLevels}</p>
                    </div>
                    <div>
                        <p className="text-sm text-slate-500">Toplam Yıldız</p>
                        <p className="text-2xl font-bold text-slate-800">{totalStars}</p>
                    </div>
                </div>
            </div>

            <div>
                <h3 className="text-sm font-bold text-slate-500 uppercase tracking-wider mb-2 px-2">Detaylar</h3>
                <div className="grid grid-cols-2 gap-4">
                    <StatCard index={0} icon={<DiamondIcon size={24} />} label="Toplam Puan" value={totalScore.toLocaleString()} />
                    <StatCard index={1} icon={<ClockIcon />} label="Toplam Oyun Süresi" value={formatTotalTime(totalPlayTime)} />
                    <StatCard index={2} icon={<TrophyIcon size={24} />} label="Kazanılan Başarım" value={`${badgesEarned} / ${allBadges.length}`} />
                    <StatCard index={3} icon={<StarIcon filled={true} size={24} />} label="Seviye Başına Yıldız" value={averageStars} />
                </div>
            </div>
        </div>
    );
};

const WeeklyRaceTab: React.FC<{ progress: PlayerProgress }> = ({ progress }) => {
    const { days, hours, minutes, seconds } = useCountdown(progress.lastWeeklyReset || Date.now());

    // MOCK DATA for Weekly Race - No DB required
    const leaderboardData = useMemo(() => {
        let players = [
            { name: 'Rüzgar', weeklyGems: 1250 },
            { name: 'Deniz', weeklyGems: 980 },
            { name: 'Toprak', weeklyGems: 850 },
            { name: 'Güneş', weeklyGems: 720 },
            { name: 'Bulut', weeklyGems: 600 },
        ];

        const mappedPlayers = players.map(p => {
            const style = getAvatarStyle(p.name);
            return {
                name: p.name,
                gems: p.weeklyGems || 0,
                avatar: `https://api.dicebear.com/8.x/${style}/svg?seed=${p.name}`,
                isPlayer: false
            };
        });

        // Add current player
        const playerAvatarStyle = getAvatarStyle(progress.playerName);
        mappedPlayers.push({
            name: progress.playerName,
            gems: progress.weeklyGems,
            avatar: `https://api.dicebear.com/8.x/${playerAvatarStyle}/svg?seed=${progress.playerName}`,
            isPlayer: true
        });

        return mappedPlayers
            .sort((a, b) => b.gems - a.gems)
            .map((player, index) => ({ ...player, rank: index + 1 }));
    }, [progress.playerName, progress.weeklyGems]);

    const timeParts = [
        days > 0 && `${days}g`,
        hours > 0 && `${String(hours).padStart(2, '0')}s`,
        `${String(minutes).padStart(2, '0')}d`,
        `${String(seconds).padStart(2, '0')}sn`
    ].filter(Boolean).slice(0, 3).join(' ');

    return (
        <div className="space-y-4">
            <div className="bg-gradient-to-br from-indigo-500 to-blue-600 p-4 rounded-2xl text-white text-center shadow-lg">
                <h3 className="text-sm font-bold opacity-80 uppercase tracking-wider">Haftalık Yarış</h3>
                <div className="flex flex-col items-center justify-center mt-1">
                    <p className="text-xs text-white/70 mb-1">Bitişine Kalan Süre</p>
                    <p className="text-3xl font-black font-mono tracking-tight">{timeParts}</p>
                </div>
            </div>
            <div className="space-y-2">
                {leaderboardData.map((player) => {
                    let rankClasses = '';
                    if (player.rank === 1) rankClasses = 'bg-gradient-to-br from-amber-400 to-yellow-500 text-white shadow-lg shadow-yellow-500/20';
                    else if (player.rank === 2) rankClasses = 'bg-gradient-to-br from-slate-400 to-gray-500 text-white shadow-lg shadow-gray-500/20';
                    else if (player.rank === 3) rankClasses = 'bg-gradient-to-br from-orange-600 to-amber-700 text-white shadow-lg shadow-amber-700/20';
                    else rankClasses = 'bg-slate-200 text-slate-600';

                    return (
                        <div key={player.rank} className={`group p-3 rounded-2xl flex items-center gap-4 transition-all duration-200 border transform ${player.isPlayer ? 'bg-indigo-100/80 border-indigo-400 ring-2 ring-indigo-300' : 'bg-white/60 backdrop-blur-xl border-white/20 shadow-sm'}`}>
                            <div className={`w-10 h-10 rounded-full flex-shrink-0 flex items-center justify-center font-black text-lg ${rankClasses}`}>
                                {player.rank}
                            </div>
                            <img alt={`${player.name}'s avatar`} className="w-12 h-12 rounded-full border-2 border-white/80 bg-slate-200" src={player.avatar} />
                            <div className="flex-1 text-left min-w-0">
                                <h3 className="font-bold text-lg text-slate-800 truncate">{player.name}{player.isPlayer ? <span className="text-indigo-600 font-semibold text-base"> (Siz)</span> : ''}</h3>
                            </div>
                             <div className="flex items-center gap-2 text-indigo-600 font-bold text-lg">
                                <DiamondIcon size={16} />
                                <span>{player.gems.toLocaleString()}</span>
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
};

const GlobalTab: React.FC<{ progress: PlayerProgress }> = ({ progress }) => {
    // MOCK DATA for Global Tab - No DB required
    const leaderboardData = useMemo(() => {
        let players = [
            { name: 'Efsane_Oyuncu', gems: 150000 },
            { name: 'Blok_Ustası', gems: 120000 },
            { name: 'Bulmaca_Kraliçesi', gems: 95000 },
            { name: 'Hız_Tutkunu', gems: 80000 },
            { name: 'Strateji_Devi', gems: 65000 },
        ];

        const mappedPlayers = players.map(p => {
            const style = getAvatarStyle(p.name);
            return {
                name: p.name,
                gems: p.gems || 0,
                avatar: `https://api.dicebear.com/8.x/${style}/svg?seed=${p.name}`,
                isPlayer: false
            };
        });

         // Add current player
         const playerAvatarStyle = getAvatarStyle(progress.playerName);
         mappedPlayers.push({
            name: progress.playerName,
            gems: progress.gems,
            avatar: `https://api.dicebear.com/8.x/${playerAvatarStyle}/svg?seed=${progress.playerName}`,
            isPlayer: true
         });

        return mappedPlayers
            .sort((a, b) => b.gems - a.gems)
            .map((player, index) => ({ ...player, rank: index + 1 }));
    }, [progress.playerName, progress.gems]);

    return (
        <div className="space-y-4">
            <div className="bg-gradient-to-br from-amber-500 to-orange-600 p-4 rounded-2xl text-white text-center shadow-lg border border-amber-400/50">
                <div className="flex items-center justify-center gap-2 mb-1">
                    <GlobeIcon size={24} className="text-amber-100" />
                    <h3 className="text-xl font-black uppercase tracking-wider">Global Sıralama</h3>
                    <GlobeIcon size={24} className="text-amber-100" />
                </div>
                <p className="text-sm text-white/80">Tüm zamanların en çok elmas toplayanları</p>
            </div>
            <div className="space-y-2">
                {leaderboardData.map((player) => {
                    let rankClasses = '';
                    if (player.rank === 1) rankClasses = 'bg-gradient-to-br from-amber-300 to-yellow-500 text-white shadow-lg shadow-yellow-500/30 ring-2 ring-yellow-200';
                    else if (player.rank === 2) rankClasses = 'bg-gradient-to-br from-slate-300 to-gray-400 text-white shadow-lg shadow-gray-500/20';
                    else if (player.rank === 3) rankClasses = 'bg-gradient-to-br from-orange-400 to-amber-600 text-white shadow-lg shadow-amber-700/20';
                    else rankClasses = 'bg-slate-200 text-slate-600';

                    return (
                        <div key={player.rank} className={`group p-3 rounded-2xl flex items-center gap-4 transition-all duration-200 border transform ${player.isPlayer ? 'bg-amber-50/90 border-amber-400 ring-2 ring-amber-300 scale-[1.02]' : 'bg-white/60 backdrop-blur-xl border-white/20 shadow-sm'}`}>
                            <div className={`w-10 h-10 rounded-full flex-shrink-0 flex items-center justify-center font-black text-lg ${rankClasses}`}>
                                {player.rank}
                            </div>
                            <img alt={`${player.name}'s avatar`} className="w-12 h-12 rounded-full border-2 border-white/80 bg-slate-200" src={player.avatar} />
                            <div className="flex-1 text-left min-w-0">
                                <h3 className="font-bold text-lg text-slate-800 truncate">{player.name}{player.isPlayer ? <span className="text-amber-600 font-semibold text-base"> (Siz)</span> : ''}</h3>
                            </div>
                             <div className="flex items-center gap-2 text-amber-600 font-bold text-lg">
                                <DiamondIcon size={16} />
                                <span>{player.gems.toLocaleString()}</span>
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
};

const LeaderboardScreen: React.FC<LeaderboardScreenProps> = ({ progress, onSaveName, onBack }) => {
    const [activeTab, setActiveTab] = useState<'stats' | 'race' | 'global'>('stats');

    return (
        <div className="flex flex-col h-[100svh] font-sans fade-in bg-slate-200">
            <div className="absolute inset-0 bg-gradient-to-br from-sky-100 via-blue-200 to-indigo-300"></div>
            <div className="relative w-full max-w-lg mx-auto flex flex-col h-full">
                <header className="sticky top-0 sm:top-2 z-20 w-full flex-shrink-0 flex items-center justify-center p-3 my-2 bg-white/60 backdrop-blur-xl border border-white/30 rounded-2xl shadow-lg">
                    <button onClick={onBack} className="absolute left-4 p-2 bg-black/5 hover:bg-black/10 rounded-full text-slate-600 transition-colors">
                       <ArrowLeftIcon />
                    </button>
                    <h1 className="text-2xl font-black text-slate-700">Profil & Sıralama</h1>
                </header>
                
                <main className="flex-1 overflow-y-auto scrollbar-hide px-2 pb-4">
                    <div className="p-1 bg-slate-200/80 backdrop-blur-sm rounded-xl flex gap-1 mb-4 shadow-inner">
                        <TabButton icon={<TrophyIcon size={16} />} text="İstatistik" isActive={activeTab === 'stats'} onClick={() => setActiveTab('stats')} />
                        <TabButton icon={<FlagIcon size={16} />} text="Haftalık" isActive={activeTab === 'race'} onClick={() => setActiveTab('race')} />
                        <TabButton icon={<GlobeIcon size={16} />} text="Global" isActive={activeTab === 'global'} onClick={() => setActiveTab('global')} />
                    </div>
                    {activeTab === 'stats' && <PlayerStatsTab progress={progress} onSaveName={onSaveName} />}
                    {activeTab === 'race' && <WeeklyRaceTab progress={progress} />}
                    {activeTab === 'global' && <GlobalTab progress={progress} />}
                </main>
            </div>
        </div>
    );
};

const TabButton: React.FC<{ icon: React.ReactNode; text: string; isActive: boolean; onClick: () => void; }> = ({ icon, text, isActive, onClick }) => (
    <button
        onClick={onClick}
        className={`w-full flex-1 flex flex-col sm:flex-row items-center justify-center gap-1 sm:gap-2 font-bold py-2 sm:py-2.5 px-1 rounded-lg transition-all duration-300 transform active:scale-95 focus:outline-none text-xs sm:text-sm ${
            isActive
                ? 'bg-white text-slate-800 shadow-md'
                : 'bg-transparent text-slate-500 hover:bg-white/50'
        }`}
    >
        <span className={isActive ? 'text-indigo-500' : 'text-slate-400'}>{icon}</span>
        <span>{text}</span>
    </button>
);

export default LeaderboardScreen;
