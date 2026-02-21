
import React from 'react';
import PlayIcon from './icons/PlayIcon';
import HomeIcon from './icons/HomeIcon';
import { useSound } from '../hooks/useSound';
import { useHaptics } from '../hooks/useHaptics';

interface PauseModalProps {
    onResume: () => void;
    onExit: () => void;
}

const PauseModal: React.FC<PauseModalProps> = ({ onResume, onExit }) => {
    const { playSound } = useSound();
    const { vibrateClick } = useHaptics();

    const handleResume = () => {
        playSound('ui-click');
        vibrateClick();
        onResume();
    };

    const handleExit = () => {
        playSound('ui-click');
        vibrateClick();
        onExit();
    };

    return (
        <div 
            className="fixed inset-0 bg-slate-900/50 backdrop-blur-lg flex items-center justify-center z-50 p-4"
            aria-modal="true"
            role="dialog"
        >
            <div className="bg-white/60 backdrop-blur-xl rounded-2xl p-6 sm:p-8 max-w-sm w-full text-center border border-white/30 shadow-lg modal-fade-in-scale">
                <h2 className="text-3xl font-black text-slate-800 mb-8">Oyun Duraklatıldı</h2>
                
                <div className="flex flex-col justify-center gap-3">
                    <button
                        onClick={handleResume}
                        className="w-full flex items-center justify-center gap-3 bg-sky-500 hover:bg-sky-600 text-white font-bold py-3.5 px-6 rounded-xl transition-all duration-200 transform active:scale-95 text-lg"
                    >
                        <PlayIcon size={20} />
                        <span>Devam Et</span>
                    </button>
                     <button
                        onClick={handleExit}
                        className="w-full flex items-center justify-center gap-3 bg-black/10 hover:bg-black/20 text-slate-700 font-bold py-3 px-6 rounded-xl transition-all duration-200 transform active:scale-95"
                    >
                        <HomeIcon size={20} />
                        <span>Çıkış</span>
                    </button>
                </div>
            </div>
        </div>
    );
};

export default PauseModal;