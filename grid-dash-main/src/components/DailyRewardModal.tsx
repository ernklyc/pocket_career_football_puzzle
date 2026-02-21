
import React, { useState, useRef, useCallback } from 'react';
import { useSound } from '../hooks/useSound';
import { useHaptics } from '../hooks/useHaptics';
import LightbulbIcon from './icons/LightbulbIcon';
import HourglassIcon from './icons/HourglassIcon';
import WandIcon from './icons/WandIcon';
import TrophyIcon from './icons/TrophyIcon';
import XIcon from './icons/XIcon';
import ParticleSystem, { ParticleEvent } from './ParticleSystem';
import DiamondIcon from './icons/DiamondIcon';

type RewardValue = { hints?: number; timeShifts?: number; solverPieces?: number; gems?: number };
interface Reward {
  id: string;
  label: string;
  value: RewardValue;
  icon: React.FC<{className?: string, size?: number}>;
  color: string;
}

const rewards: Reward[] = [
    { id: 'hint_2', label: '+2 İpucu', value: { hints: 2 }, icon: LightbulbIcon, color: '#a855f7' },
    { id: 'timeShift_1', label: '+1 Zaman', value: { timeShifts: 1 }, icon: HourglassIcon, color: '#3b82f6' },
    { id: 'solver_1', label: '+1 Çözücü', value: { solverPieces: 1 }, icon: WandIcon, color: '#14b8a6' },
    { id: 'gems_50', label: '+50 Elmas', value: { gems: 50 }, icon: DiamondIcon, color: '#0ea5e9' },
    { id: 'jackpot', label: 'JACKPOT', value: { hints: 2, timeShifts: 1, solverPieces: 1 }, icon: TrophyIcon, color: '#f97316' },
    { id: 'timeShift_2', label: '+2 Zaman', value: { timeShifts: 2 }, icon: HourglassIcon, color: '#0ea5e9' },
    { id: 'solver_2', label: '+2 Çözücü', value: { solverPieces: 2 }, icon: WandIcon, color: '#10b981' },
    { id: 'hint_3', label: '+3 İpucu', value: { hints: 3 }, icon: LightbulbIcon, color: '#d946ef' },
];

const SLICE_COUNT = rewards.length;
const SLICE_DEGREE = 360 / SLICE_COUNT;

interface DailyRewardModalProps {
  isOpen: boolean;
  onClaim: (reward: RewardValue) => void;
  onClose: () => void;
}

export const DailyRewardModal: React.FC<DailyRewardModalProps> = ({ isOpen, onClaim, onClose }) => {
    const [rotation, setRotation] = useState(0);
    const [isSpinning, setIsSpinning] = useState(false);
    const [wonReward, setWonReward] = useState<Reward | null>(null);
    const { playSound } = useSound();
    const { vibrateClick } = useHaptics();

    const particleIdCounter = useRef(0);
    const [particles, setParticles] = useState<ParticleEvent[]>([]);

    const triggerParticles = useCallback((x: number, y: number, type: ParticleEvent['type'], color?: string) => {
        const newParticle: ParticleEvent = {
            id: particleIdCounter.current++,
            x, y, color, type,
        };
        setParticles(prev => [...prev, newParticle]);
        setTimeout(() => {
            setParticles(prev => prev.filter(p => p.id !== newParticle.id));
        }, 4000); 
    }, []);

    const handleSpin = () => {
        if (isSpinning || wonReward) return;

        playSound('ui-click');
        vibrateClick();
        setIsSpinning(true);
        
        const winnerIndex = Math.floor(Math.random() * SLICE_COUNT);
        const randomOffset = Math.random() * SLICE_DEGREE * 0.8 - (SLICE_DEGREE * 0.4);
        const targetRotation = (360 * 6) + (360 - (winnerIndex * SLICE_DEGREE)) - (SLICE_DEGREE / 2) + randomOffset;
        
        setRotation(prev => prev + targetRotation);

        setTimeout(() => {
            const finalReward = rewards[winnerIndex];
            setWonReward(finalReward);
            setIsSpinning(false);
            onClaim(finalReward.value);

            // Delay celebration for the animations to play out
            setTimeout(() => {
              playSound('level-complete');
              triggerParticles(0, 0, 'confetti');
            }, 500); // Corresponds to the pop-in animation duration

            setTimeout(() => {
                handleClose(true); // Auto-closing
            }, 4000);
        }, 5000); // Corresponds to transition duration
    };

    const handleClose = (isAutoClose = false) => {
        if (isSpinning) return;
        if (!isAutoClose) {
            playSound('ui-click');
            vibrateClick();
        }
        onClose();
    };
    
    const renderWonRewardText = () => {
        if (!wonReward) return null;
        if (wonReward.id === 'jackpot') {
            const parts = [];
            if (wonReward.value.hints) parts.push(`+${wonReward.value.hints} İpucu`);
            if (wonReward.value.timeShifts) parts.push(`+${wonReward.value.timeShifts} Zaman`);
            if (wonReward.value.solverPieces) parts.push(`+${wonReward.value.solverPieces} Çözücü`);
            if (wonReward.value.gems) parts.push(`+${wonReward.value.gems} Elmas`);

            return (
                <>
                    <p className="text-2xl font-bold text-orange-400 mt-1">{wonReward.label}</p>
                    <p className="text-slate-300 text-sm mt-1">
                        {parts.join(', ')} kazandın!
                    </p>
                </>
            );
        }
        return <p className="text-2xl font-bold text-sky-400 mt-1">{wonReward.label}</p>;
    };

    if (!isOpen) return null;

    return (
    <div
      className="fixed inset-0 bg-slate-900/50 backdrop-blur-lg flex items-center justify-center z-50 p-4"
      aria-modal="true"
      role="dialog"
    >
        <div className="relative bg-[radial-gradient(ellipse_at_center,_var(--tw-gradient-stops))] from-indigo-700 via-slate-900 to-black rounded-2xl p-6 sm:p-8 max-w-md w-full text-center border-2 border-sky-400/50 shadow-2xl modal-fade-in-scale overflow-hidden">
            <ParticleSystem particles={particles} />
            <button onClick={() => handleClose()} className="absolute top-4 right-4 text-slate-500 hover:text-white transition-colors z-20">
                <XIcon />
            </button>
            <h1 className="text-4xl font-black text-center mb-2 text-transparent bg-clip-text bg-gradient-to-b from-sky-300 to-blue-500" style={{ textShadow: '0 2px 10px rgba(56, 189, 248, 0.3)' }}>
                GÜNLÜK ÇARK
            </h1>
            <p className="text-lg text-slate-400/90 mb-4">Çevir ve harika ödüller kazan!</p>

            <div className="wheel-container">
                <div className="pointer"></div>
                <div className="wheel" style={{ transform: `rotate(${rotation}deg)` }}>
                    {rewards.map((reward, i) => {
                        const isWon = wonReward && wonReward.id === reward.id;
                        return (
                            <div
                                key={reward.id}
                                className="slice"
                                style={{ '--slice-bg': reward.color, transform: `rotate(${i * SLICE_DEGREE}deg)` } as React.CSSProperties}
                            >
                                <div className="slice-content">
                                    <reward.icon
                                        className={`transition-all duration-500 ease-in-out text-white ${isWon ? 'icon-won' : ''}`}
                                        size={32}
                                    />
                                    <span className={isWon ? 'label-won' : ''}>
                                        {reward.label}
                                    </span>
                                </div>
                            </div>
                        );
                    })}
                </div>
                <div className="spin-button-container">
                    {!wonReward && (
                        <button className="spin-button font-display" onClick={handleSpin} disabled={isSpinning}>
                            {isSpinning ? '...' : 'ÇEVİR'}
                        </button>
                    )}
                </div>
            </div>

            <div className="h-16 mt-6 flex items-center justify-center">
                {wonReward && !isSpinning && (
                    <div className="text-center animate-pop-in">
                        <p className="text-slate-400">Tebrikler, kazandın:</p>
                        {renderWonRewardText()}
                    </div>
                )}
            </div>
        </div>

        <style>{`
            .wheel-container {
                position: relative;
                width: 320px;
                height: 320px;
                margin: 1rem auto;
            }
            .wheel {
                width: 100%;
                height: 100%;
                border-radius: 50%;
                position: relative;
                overflow: hidden;
                border: 8px solid #475569;
                box-shadow: 0 0 20px rgba(0,0,0,0.5), inset 0 0 15px rgba(0,0,0,0.7);
                transition: transform 5s cubic-bezier(0.25, 1, 0.5, 1);
            }
            .slice {
                position: absolute;
                width: 50%;
                height: 50%;
                background-color: var(--slice-bg);
                transform-origin: 100% 100%;
                clip-path: polygon(0 0, 100% 0, 100% 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                border-left: 1px solid rgba(255, 255, 255, 0.1);
                border-top: 1px solid rgba(255, 255, 255, 0.1);
            }
            .slice-content {
                transform: rotate(${-SLICE_DEGREE / 2}deg) translate(-50%, -50%);
                position: absolute;
                left: 75%;
                top: 25%;
                text-align: center;
                color: white;
                font-size: 0.8rem;
                font-weight: 600;
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 4px;
            }
            .slice-content .material-symbols-outlined {
                font-size: 2rem;
                filter: drop-shadow(0 0 5px rgba(255, 255, 255, 0.5));
            }
            .pointer {
                position: absolute;
                top: -12px;
                left: 50%;
                transform: translateX(-50%);
                width: 0;
                height: 0;
                border-left: 20px solid transparent;
                border-right: 20px solid transparent;
                border-top: 30px solid #f59e0b;
                filter: drop-shadow(0 -2px 4px rgba(0, 0, 0, 0.5));
                z-index: 10;
            }
            .pointer::before {
                content: '';
                position: absolute;
                top: -34px;
                left: -12px;
                width: 24px;
                height: 24px;
                background: #fbbf24;
                border-radius: 50%;
                border: 3px solid #f59e0b;
                box-shadow: 0 0 8px #f59e0b;
            }
            .spin-button-container {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                z-index: 5;
            }
            .spin-button {
                width: 90px;
                height: 90px;
                border-radius: 50%;
                background-image: radial-gradient(circle, #38bdf8, #0ea5e9);
                color: white;
                font-weight: 800;
                font-size: 1.5rem;
                border: 5px solid white;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                text-transform: uppercase;
                box-shadow: 0 0 20px #0ea5e9, inset 0 0 10px rgba(255, 255, 255, 0.6);
                text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
                transition: all 0.2s ease;
            }
            .spin-button:not(:disabled):hover {
                transform: scale(1.05);
            }
             .spin-button:disabled {
                background-image: radial-gradient(circle, #64748b, #475569);
                cursor: not-allowed;
                box-shadow: none;
            }
            .slice-content .icon-won {
                animation: pop-and-glow 1.2s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
            }
            .slice-content .label-won {
                font-weight: 800;
            }
            @keyframes pop-and-glow {
                0% {
                    transform: scale(1);
                    filter: drop-shadow(0 0 5px rgba(255, 255, 255, 0.5));
                }
                50% {
                    transform: scale(1.4);
                    filter: drop-shadow(0 0 15px rgba(255, 255, 255, 1));
                }
                100% {
                    transform: scale(1.2);
                    filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.7));
                }
            }
            .animate-pop-in {
                animation: pop-in-anim 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
            }
            @keyframes pop-in-anim {
                0% { transform: scale(0.7); opacity: 0; }
                80% { transform: scale(1.1); opacity: 1; }
                100% { transform: scale(1); opacity: 1; }
            }
        `}</style>
    </div>
  );
};

export default DailyRewardModal;
