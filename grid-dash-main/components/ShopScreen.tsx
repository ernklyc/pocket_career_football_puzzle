
import React, { useState } from 'react';
import type { PlayerProgress } from '../types';
import ArrowLeftIcon from './icons/ArrowLeftIcon';
import DiamondIcon from './icons/DiamondIcon';
import LightbulbIcon from './icons/LightbulbIcon';
import HourglassIcon from './icons/HourglassIcon';
import WandIcon from './icons/WandIcon';
import { useHaptics } from '../hooks/useHaptics';

export const SHOP_ITEMS = {
  hint: { name: 'İpucu', price: 50, icon: LightbulbIcon, powerUpKey: 'hints', description: 'Tahtada bir bloğun doğru yerini gösterir.' },
  timeShift: { name: 'Zaman Kaydırma', price: 75, icon: HourglassIcon, powerUpKey: 'timeShifts', description: 'Zamanı 5 saniyeliğine yavaşlatır.' },
  solverPiece: { name: 'Çözücü Parça', price: 100, icon: WandIcon, powerUpKey: 'solverPieces', description: 'Bir bloğu anında doğru yerine yerleştirir.' },
};

export const GEM_PACKAGES = [
  { id: 'gems_100', amount: 100, price: '₺29,99', icon: DiamondIcon, color: 'bg-sky-200 text-sky-600', bestValue: false },
  { id: 'gems_550', amount: 550, price: '₺149,99', icon: DiamondIcon, color: 'bg-emerald-200 text-emerald-600', bestValue: true },
  { id: 'gems_1200', amount: 1200, price: '₺299,99', icon: DiamondIcon, color: 'bg-amber-200 text-amber-600', bestValue: false },
  { id: 'gems_2500', amount: 2500, price: '₺599,99', icon: DiamondIcon, color: 'bg-rose-200 text-rose-600', bestValue: false },
];

interface ShopScreenProps {
  progress: PlayerProgress;
  onPurchase: (itemId: keyof typeof SHOP_ITEMS) => void;
  onPurchaseGems: (gemAmount: number) => void;
  onBack: () => void;
}

const AssetDisplay: React.FC<{ icon: React.ReactNode, label: string, value: number }> = ({ icon, label, value }) => (
  <div>
    <div className="w-10 h-10 bg-slate-200/70 rounded-full flex items-center justify-center mx-auto mb-1.5 text-slate-600">{icon}</div>
    <p className="text-lg font-bold text-slate-700">{value.toLocaleString()}</p>
    <p className="text-xs text-slate-500 font-medium">{label}</p>
  </div>
);

const ShopScreen: React.FC<ShopScreenProps> = ({ progress, onPurchase, onPurchaseGems, onBack }) => {
  const [shakeGems, setShakeGems] = useState(false);
  const { vibrateFailure } = useHaptics();

  const handleBuyPowerUp = (itemId: keyof typeof SHOP_ITEMS) => {
    const item = SHOP_ITEMS[itemId];
    if (progress.gems < item.price) {
      vibrateFailure();
      setShakeGems(true);
      setTimeout(() => setShakeGems(false), 400);
    } else {
      onPurchase(itemId);
    }
  };

  const handleBuyGems = (amount: number) => {
    onPurchaseGems(amount);
  };

  return (
    <div className="flex flex-col h-[100svh] p-2 sm:p-4 font-sans fade-in bg-slate-200">
      <div className="absolute inset-0 bg-gradient-to-br from-sky-100 via-blue-200 to-indigo-300"></div>
      <div className="relative w-full max-w-md mx-auto flex flex-col h-full">
        <header className="sticky top-0 sm:top-2 z-20 w-full flex-shrink-0 flex items-center justify-center p-3 mb-4 bg-white/60 backdrop-blur-xl border border-white/30 rounded-2xl shadow-lg">
          <button onClick={onBack} className="absolute left-4 p-2 bg-black/5 hover:bg-black/10 rounded-full text-slate-600 transition-colors">
            <ArrowLeftIcon />
          </button>
          <h1 className="text-2xl font-black text-slate-700">Dükkan</h1>
        </header>

        <main className="w-full flex-1 overflow-y-auto scrollbar-hide px-2 pb-4 space-y-6">
          <div className={`bg-white/70 backdrop-blur-xl border border-white/20 shadow-md p-4 rounded-2xl transition-transform duration-300 ${shakeGems ? 'animate-shake' : ''}`} onAnimationEnd={() => setShakeGems(false)}>
            <h2 className="text-sm font-bold text-slate-500 uppercase tracking-wider mb-3 px-1">Varlıklarım</h2>
            <div className="grid grid-cols-4 gap-2 text-center">
              <AssetDisplay icon={<DiamondIcon size={20} className="text-indigo-500"/>} label="Elmas" value={progress.gems} />
              <AssetDisplay icon={<LightbulbIcon />} label="İpucu" value={progress.hints} />
              <AssetDisplay icon={<HourglassIcon />} label="Zaman" value={progress.timeShifts} />
              <AssetDisplay icon={<WandIcon />} label="Çözücü" value={progress.solverPieces} />
            </div>
          </div>
          
          <div>
            <h2 className="text-sm font-bold text-slate-500 uppercase tracking-wider mb-2 px-2">Elmas Satın Al</h2>
            <div className="grid grid-cols-2 gap-3">
              {GEM_PACKAGES.map(pack => (
                <div key={pack.id} className="relative bg-white/70 backdrop-blur-xl border border-white/20 shadow-md p-4 rounded-2xl flex flex-col items-center text-center">
                  {pack.bestValue && <div className="absolute top-0 -mt-2.5 bg-rose-500 text-white text-xs font-bold px-3 py-1 rounded-full uppercase shadow-lg">En İyi Değer</div>}
                  <div className={`w-16 h-16 ${pack.color} rounded-xl flex items-center justify-center mb-3`}>
                    <pack.icon size={32} />
                  </div>
                  <p className="text-2xl font-black text-slate-800">{pack.amount.toLocaleString()}</p>
                  <p className="text-sm text-slate-500 font-semibold mb-3">Elmas</p>
                  <button
                    onClick={() => handleBuyGems(pack.amount)}
                    className="w-full bg-indigo-500 text-white font-bold px-4 py-2 rounded-lg transition-all duration-200 transform active:scale-95 hover:bg-indigo-600 shadow-md"
                  >
                    {pack.price}
                  </button>
                </div>
              ))}
            </div>
          </div>
          
          <div>
            <h2 className="text-sm font-bold text-slate-500 uppercase tracking-wider mb-2 px-2">Güçlendirmeler</h2>
            <div className="space-y-3">
              {Object.entries(SHOP_ITEMS).map(([id, item]) => {
                const Icon = item.icon;
                return (
                  <div key={id} className="bg-white/70 backdrop-blur-xl border border-white/20 shadow-md p-4 rounded-2xl flex items-center gap-4">
                    <div className="w-16 h-16 bg-sky-100 rounded-xl flex items-center justify-center text-sky-500 flex-shrink-0">
                      <Icon />
                    </div>
                    <div className="flex-grow min-w-0">
                      <h3 className="font-bold text-lg text-slate-800">{item.name}</h3>
                      <p className="text-sm text-slate-600 mt-1">{item.description}</p>
                    </div>
                    <button 
                      onClick={() => handleBuyPowerUp(id as keyof typeof SHOP_ITEMS)}
                      className="flex flex-col items-center justify-center gap-1 bg-sky-500 text-white font-bold px-4 py-2 rounded-xl transition-all duration-200 transform active:scale-95 hover:bg-sky-600 shadow-md"
                    >
                      <div className="flex items-center gap-2">
                        <DiamondIcon size={14} />
                        <span>{item.price}</span>
                      </div>
                      <span className="text-xs font-semibold uppercase">Satın Al</span>
                    </button>
                  </div>
                );
              })}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
};

export default ShopScreen;
