
import React from 'react';
import useCountdown from '../hooks/useCountdown';
import ChestIcon from './icons/ChestIcon';
import ClockIcon from './icons/ClockIcon';

interface DailyRewardIndicatorProps {
  nextRewardTime: number;
  onClaim: () => void;
}

const DailyRewardIndicator: React.FC<DailyRewardIndicatorProps> = ({ nextRewardTime, onClaim }) => {
  const { formattedTime, isFinished } = useCountdown(nextRewardTime);

  if (isFinished) {
    return (
      <button
        onClick={onClaim}
        className="w-full bg-gradient-to-br from-sky-400 to-indigo-500 p-4 rounded-2xl flex items-center gap-4 text-white shadow-lg border-2 border-sky-300/80 hover:scale-[1.02] active:scale-100 transition-transform duration-200"
      >
        <div className="relative">
          <ChestIcon isOpen={true} />
        </div>
        <div className="flex-1 text-left">
            <h3 className="text-lg font-black">Günlük Ödülün Hazır!</h3>
            <p className="text-sm text-white/90">Almak için dokun.</p>
        </div>
        <span className="text-sm font-bold bg-white/20 px-3 py-1.5 rounded-lg">AL</span>
      </button>
    );
  }

  return (
    <div className="bg-white/70 backdrop-blur-xl border border-white/20 shadow-md p-4 rounded-2xl flex items-center justify-between">
      <div className="flex items-center gap-4">
        <div className="text-slate-400">
          <ClockIcon />
        </div>
        <div>
          <h3 className="font-bold text-slate-700">Günlük Ödül</h3>
          <p className="text-sm text-slate-500">Sonraki ödül</p>
        </div>
      </div>
      <div className="font-mono text-xl text-sky-600 font-bold bg-sky-100 px-3 py-1 rounded-md">
        {formattedTime}
      </div>
    </div>
  );
};

export default DailyRewardIndicator;
