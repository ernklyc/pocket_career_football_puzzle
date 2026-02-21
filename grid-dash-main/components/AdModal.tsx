
import React from 'react';
import InfoIcon from './icons/InfoIcon';
import { useSound } from '../hooks/useSound';
import { useHaptics } from '../hooks/useHaptics';

interface AdModalProps {
    isOpen: boolean;
    onClose: () => void;
    onConfirm: () => void;
}

const AdModal: React.FC<AdModalProps> = ({ isOpen, onClose, onConfirm }) => {
    const { playSound } = useSound();
    const { vibrateClick } = useHaptics();

    if (!isOpen) return null;

    const handleClose = () => {
        playSound('ui-click');
        vibrateClick();
        onClose();
    };

    const handleConfirm = () => {
        playSound('ui-click');
        vibrateClick();
        onConfirm();
    };

    return (
        <div 
            className="fixed inset-0 bg-slate-900/50 backdrop-blur-lg flex items-center justify-center z-50 p-4"
            aria-modal="true"
            role="dialog"
        >
            <div className="bg-white/60 backdrop-blur-xl rounded-2xl p-6 sm:p-8 max-w-sm w-full text-center border border-white/30 shadow-lg modal-fade-in-scale">
                <div className="w-16 h-16 bg-sky-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <InfoIcon className="w-8 h-8 text-sky-600"/>
                </div>
                <h2 className="text-2xl font-black text-slate-800 mb-2">İpucun Kalmadı!</h2>
                <p className="text-slate-600 mb-8">
                    1 ücretsiz ipucu daha kazanmak için kısa bir reklam izlemek ister misin?
                </p>
                <div className="flex flex-col sm:flex-row justify-center gap-3">
                    <button
                        onClick={handleClose}
                        className="w-full bg-black/10 hover:bg-black/20 text-slate-700 font-bold py-3 px-6 rounded-xl transition-all duration-200 transform active:scale-95"
                    >
                        Vazgeç
                    </button>
                    <button
                        onClick={handleConfirm}
                        className="w-full bg-sky-500 hover:bg-sky-600 text-white font-bold py-3 px-6 rounded-xl transition-all duration-200 transform active:scale-95"
                    >
                        Reklam İzle
                    </button>
                </div>
            </div>
        </div>
    );
};

export default AdModal;