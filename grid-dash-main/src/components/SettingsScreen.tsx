import React from 'react';
import { useSettings } from '../contexts/SettingsContext';
import ArrowLeftIcon from './icons/ArrowLeftIcon';
import SoundOnIcon from './icons/SoundOnIcon';
import SoundOffIcon from './icons/SoundOffIcon';
import VibrateIcon from './icons/VibrateIcon';
import MusicIcon from './icons/MusicIcon';
import { useHaptics } from '../hooks/useHaptics';
import TrashIcon from './icons/TrashIcon';

interface SettingsScreenProps {
  onBack: () => void;
  onResetProgress: () => void;
}

const SettingsScreen: React.FC<SettingsScreenProps> = ({ onBack, onResetProgress }) => {
  const { settings, updateSettings } = useSettings();
  const { isHapticsSupported } = useHaptics();

  const handleHapticsToggle = () => {
    if (isHapticsSupported) {
        updateSettings({ haptics: !settings.haptics });
    }
  };

  return (
    <div className="flex flex-col h-[100svh] p-2 sm:p-4 font-sans fade-in bg-background">
      <div className="absolute inset-0 bg-gradient-to-br from-sky-100 via-blue-200 to-indigo-300"></div>
      <div className="relative w-full max-w-md mx-auto flex flex-col h-full">
        <header className="sticky top-0 sm:top-2 z-20 w-full flex-shrink-0 flex items-center justify-center p-3 mb-4 bg-surface/60 backdrop-blur-xl border border-white/30 rounded-2xl shadow-lg">
          <button onClick={onBack} className="absolute left-4 p-2 bg-black/5 hover:bg-black/10 rounded-full text-text-primary transition-colors">
            <ArrowLeftIcon />
          </button>
          <h1 className="text-2xl font-black text-text-primary">Ayarlar</h1>
        </header>

        <main className="w-full flex-1 overflow-y-auto scrollbar-hide px-2 pb-4 space-y-4">
          <SettingsSlider
            label="Müzik"
            icon={<MusicIcon />}
            value={settings.musicVolume}
            onChange={(value) => updateSettings({ musicVolume: value })}
          />
          <SettingsSlider
            label="Ses Efektleri"
            icon={settings.soundVolume > 0 ? <SoundOnIcon /> : <SoundOffIcon />}
            value={settings.soundVolume}
            onChange={(value) => updateSettings({ soundVolume: value })}
          />
          <SettingsToggle
            label="Titreşimli Geri Bildirim"
            icon={<VibrateIcon />}
            isEnabled={settings.haptics}
            onToggle={handleHapticsToggle}
            isDisabled={!isHapticsSupported}
            disabledTooltip="Cihazınızda desteklenmiyor"
          />
          <div className="mt-8 pt-4 border-t border-slate-300/50">
             <SettingsButton
                label="İlerlemeyi Sıfırla"
                icon={<TrashIcon />}
                onClick={onResetProgress}
                isDanger
            />
          </div>
        </main>
      </div>
    </div>
  );
};

interface SettingsSliderProps {
    label: string;
    icon: React.ReactNode;
    value: number;
    onChange: (value: number) => void;
}

const SettingsSlider: React.FC<SettingsSliderProps> = ({ label, icon, value, onChange }) => {
    return (
        <div className="bg-surface/70 backdrop-blur-xl border border-white/20 shadow-md p-4 rounded-2xl">
            <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-4 text-text-primary">
                    {icon}
                    <span className="font-bold text-lg">{label}</span>
                </div>
                <span className="font-mono text-sm text-text-secondary bg-slate-200 px-2 py-1 rounded-md">
                    {Math.round(value * 100)}%
                </span>
            </div>
            <input
                type="range"
                min="0"
                max="1"
                step="0.01"
                value={value}
                onChange={(e) => onChange(parseFloat(e.target.value))}
                className="w-full h-2 bg-slate-200 rounded-lg appearance-none cursor-pointer range-slider"
                style={{'--value': `${value * 100}%`} as React.CSSProperties}
            />
             <style>{`
                .range-slider {
                    background-image: linear-gradient(to right, #60a5fa var(--value), #e2e8f0 var(--value));
                }
                .range-slider::-webkit-slider-thumb {
                    -webkit-appearance: none;
                    appearance: none;
                    width: 20px;
                    height: 20px;
                    background: white;
                    border-radius: 50%;
                    border: 2px solid #60a5fa;
                    cursor: pointer;
                    box-shadow: 0 0 5px rgba(0,0,0,0.1);
                }
                .range-slider::-moz-range-thumb {
                    width: 20px;
                    height: 20px;
                    background: white;
                    border-radius: 50%;
                    border: 2px solid #60a5fa;
                    cursor: pointer;
                    box-shadow: 0 0 5px rgba(0,0,0,0.1);
                }
            `}</style>
        </div>
    );
};


interface SettingsToggleProps {
    label: string;
    icon: React.ReactNode;
    isEnabled: boolean;
    onToggle: () => void;
    isDisabled?: boolean;
    disabledTooltip?: string;
}

const SettingsToggle: React.FC<SettingsToggleProps> = ({ label, icon, isEnabled, onToggle, isDisabled, disabledTooltip }) => {
    return (
        <div className={`flex items-center justify-between p-4 rounded-2xl transition-colors backdrop-blur-xl border border-white/20 shadow-md ${isDisabled ? 'bg-slate-200/60' : 'bg-surface/70'}`}>
            <div className={`flex items-center gap-4 ${isDisabled ? 'text-slate-400' : 'text-text-primary'}`}>
                {icon}
                <span className="font-bold text-lg">{label}</span>
            </div>
            <button
                role="switch"
                aria-checked={isEnabled}
                onClick={onToggle}
                disabled={isDisabled}
                title={isDisabled ? disabledTooltip : ''}
                className={`relative inline-flex items-center h-8 w-14 rounded-full transition-colors duration-300 ease-in-out focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-secondary ${
                    isEnabled ? 'bg-secondary' : 'bg-slate-300'
                } ${isDisabled ? 'cursor-not-allowed opacity-60' : ''}`}
            >
                <span
                    className={`inline-block w-6 h-6 transform bg-white rounded-full transition-transform duration-300 ease-in-out ${
                        isEnabled ? 'translate-x-7' : 'translate-x-1'
                    }`}
                />
            </button>
        </div>
    );
};

interface SettingsButtonProps {
    label: string;
    icon: React.ReactNode;
    onClick: () => void;
    isDanger?: boolean;
}

const SettingsButton: React.FC<SettingsButtonProps> = ({ label, icon, onClick, isDanger }) => {
    const textColor = isDanger ? 'text-danger' : 'text-text-primary';
    const bgColor = isDanger ? 'bg-rose-100/70' : 'bg-surface/70';
    const hoverBgColor = isDanger ? 'hover:bg-rose-100' : 'hover:bg-white';

    return (
        <button 
            onClick={onClick}
            className={`flex items-center justify-between p-4 rounded-2xl w-full transition-all duration-200 backdrop-blur-xl border border-white/20 shadow-md ${bgColor} ${hoverBgColor} active:scale-[0.98] transform`}
        >
            <div className={`flex items-center gap-4 ${textColor}`}>
                {icon}
                <span className="font-bold text-lg">{label}</span>
            </div>
        </button>
    );
};


export default SettingsScreen;