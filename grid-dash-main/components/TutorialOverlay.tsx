

import React, { useState, useEffect, useLayoutEffect, useRef } from 'react';
import PlayIcon from './icons/PlayIcon';
import ArrowRightIcon from './icons/ArrowRightIcon';
import RotateIcon from './icons/RotateIcon';
import FlipIcon from './icons/FlipIcon';

interface TutorialTargets {
    grid: HTMLElement | null;
    palette: HTMLElement | null;
    firstBlock: HTMLElement | null;
    powerUps: HTMLElement | null;
}

interface TutorialOverlayProps {
    onNext: () => void;
    onClose: () => void;
    stepIndex: number;
    targets: TutorialTargets;
    onSimulateAction: (action: 'rotate' | 'flip') => void;
}

interface TutorialStep {
    id: string;
    target: keyof TutorialTargets | 'none';
    title: string;
    content: string;
    placement: 'top' | 'bottom' | 'left' | 'right' | 'center';
}

export const tutorialSteps: TutorialStep[] = [
    { id: 'welcome', target: 'grid', title: "Grid Dash'e Hoş Geldin!", content: "Amaç basit: verilen bloklarla alanı tamamen doldurmak.", placement: 'bottom' },
    { id: 'palette', target: 'palette', title: "Blokların", content: "Kullanabileceğin tüm bloklar burada. Paletten alana sürükle.", placement: 'left' },
    { id: 'actions', target: 'firstBlock', title: "Döndür ve Çevir", content: "Mükemmel uyumu bulmak için bu düğmeleri kullanarak blokları döndür ve çevir.", placement: 'left' },
    { id: 'powerups', target: 'powerUps', title: "Yardıma mı ihtiyacın var?", content: "Takılırsan, sana yardımcı olması için İpuçları ve diğer özel eşyaları kullan.", placement: 'bottom' },
    { id: 'ready', target: 'none', title: "Oynamaya Hazır mısın?", content: "İyi şanslar ve bulmacayı çözerken eğlen!", placement: 'center' },
];

const TutorialOverlay: React.FC<TutorialOverlayProps> = ({ onNext, onClose, stepIndex, targets, onSimulateAction }) => {
    const [isVisible, setIsVisible] = useState(false);
    
    const [highlightRect, setHighlightRect] = useState<DOMRect | null>(null);
    const [infoBoxStyle, setInfoBoxStyle] = useState<React.CSSProperties>({ opacity: 0 });
    const infoBoxRef = useRef<HTMLDivElement>(null);

    const currentStep = tutorialSteps[stepIndex];
    const isLastStep = stepIndex === tutorialSteps.length - 1;

    useEffect(() => {
        const timer = setTimeout(() => setIsVisible(true), 10);
        return () => clearTimeout(timer);
    }, []);

    useLayoutEffect(() => {
        const targetElement = currentStep.target !== 'none' ? targets[currentStep.target] : null;
        const infoBoxElement = infoBoxRef.current;
        if (!infoBoxElement) return;

        const target = targetElement?.getBoundingClientRect();
        const info = infoBoxElement.getBoundingClientRect();
        const vpw = window.innerWidth;
        const vph = window.innerHeight;
        const VIEWPORT_PADDING = 10;
        const MARGIN = 16;
        
        if (!target) {
            setHighlightRect(null);
            setInfoBoxStyle({
                top: vph / 2 - info.height / 2,
                left: vpw / 2 - info.width / 2,
                opacity: 1,
            });
            return;
        }

        setHighlightRect(target);
        
        const getPositions = () => ({
            bottom: { top: target.bottom + MARGIN, left: target.left + target.width / 2 - info.width / 2 },
            top: { top: target.top - info.height - MARGIN, left: target.left + target.width / 2 - info.width / 2 },
            left: { top: target.top + target.height / 2 - info.height / 2, left: target.left - info.width - MARGIN },
            right: { top: target.top + target.height / 2 - info.height / 2, left: target.right + MARGIN },
        });

        const isFit = (pos: { top: number, left: number }) => {
            return pos.top >= VIEWPORT_PADDING && pos.left >= VIEWPORT_PADDING && (pos.top + info.height) <= (vph - VIEWPORT_PADDING) && (pos.left + info.width) <= (vpw - VIEWPORT_PADDING);
        };

        const placementOrder = [currentStep.placement, ...(['bottom', 'top', 'left', 'right'] as const).filter(p => p !== currentStep.placement)];
        let bestPos = null;
        
        for (const placement of placementOrder) {
            const pos = getPositions()[placement];
            if (isFit(pos)) {
                bestPos = pos;
                break;
            }
        }
        
        if (!bestPos) {
            bestPos = getPositions()[currentStep.placement];
            if (bestPos.left < VIEWPORT_PADDING) bestPos.left = VIEWPORT_PADDING;
            if (bestPos.top < VIEWPORT_PADDING) bestPos.top = VIEWPORT_PADDING;
            if (bestPos.left + info.width > vpw - VIEWPORT_PADDING) bestPos.left = vpw - info.width - VIEWPORT_PADDING;
            if (bestPos.top + info.height > vph - VIEWPORT_PADDING) bestPos.top = vph - info.height - VIEWPORT_PADDING;
        }

        setInfoBoxStyle({ top: `${bestPos.top}px`, left: `${bestPos.left}px`, opacity: 1 });

    }, [stepIndex, targets, currentStep.target, currentStep.placement, isVisible]);

    const HIGHLIGHT_PADDING = 10;
    const RADIUS = 16;
    const highlightStyle = highlightRect ? {
        x: highlightRect.left - HIGHLIGHT_PADDING,
        y: highlightRect.top - HIGHLIGHT_PADDING,
        width: highlightRect.width + HIGHLIGHT_PADDING * 2,
        height: highlightRect.height + HIGHLIGHT_PADDING * 2,
        rx: RADIUS,
    } : { x: 0, y: 0, width: 0, height: 0, rx: 0 };
    
    return (
        <div className={`fixed inset-0 z-[100] transition-opacity duration-300 ${isVisible ? 'opacity-100' : 'opacity-0'}`}>
            <svg className="absolute inset-0 w-full h-full" aria-hidden="true">
                <defs>
                    <mask id="tutorial-mask">
                        <rect x="0" y="0" width="100%" height="100%" fill="white" />
                        {highlightRect && (
                            <rect {...highlightStyle} fill="black" className="transition-all duration-300 ease-in-out" />
                        )}
                    </mask>
                </defs>
                <rect x="0" y="0" width="100%" height="100%" fill="rgba(15, 23, 42, 0.8)" mask="url(#tutorial-mask)" />
            </svg>

            <div 
                ref={infoBoxRef} 
                className={`absolute p-6 bg-white rounded-2xl shadow-2xl w-80 text-slate-800 modal-fade-in-scale transition-all duration-300 ease-in-out`}
                style={infoBoxStyle}
            >
                <h3 className="text-xl font-black text-sky-600 mb-2">{currentStep.title}</h3>
                <p className="text-slate-600 mb-6">{currentStep.content}</p>

                {currentStep.id === 'actions' && (
                    <div className="flex gap-2 mb-4 border-t border-b border-slate-200 py-3">
                        <button
                            onClick={() => onSimulateAction('rotate')}
                            className="flex-1 flex justify-center items-center gap-2 bg-slate-100 text-slate-600 p-2 rounded-lg transition-all duration-200 transform hover:scale-105 hover:bg-sky-100 hover:text-sky-700 focus:outline-none focus:ring-2 focus:ring-sky-400"
                        >
                            <RotateIcon />
                            <span>Döndürmeyi Dene</span>
                        </button>
                        <button
                            onClick={() => onSimulateAction('flip')}
                            className="flex-1 flex justify-center items-center gap-2 bg-slate-100 text-slate-600 p-2 rounded-lg transition-all duration-200 transform hover:scale-105 hover:bg-sky-100 hover:text-sky-700 focus:outline-none focus:ring-2 focus:ring-sky-400"
                        >
                            <FlipIcon />
                            <span>Çevirmeyi Dene</span>
                        </button>
                    </div>
                )}
                
                <div className="flex justify-between items-center gap-4">
                    {!isLastStep ? (
                        <button 
                            onClick={onClose}
                            className="text-sm text-slate-500 hover:text-slate-700 font-semibold transition-colors hover:underline"
                        >
                            Eğitimi Atla
                        </button>
                    ) : (
                        <div /> // Placeholder for alignment
                    )}
                    <div className="flex items-center gap-4">
                        <span className="text-sm text-slate-400 font-bold">{stepIndex + 1} / {tutorialSteps.length}</span>
                        <button 
                            onClick={onNext} 
                            className="flex items-center gap-2 bg-sky-500 hover:bg-sky-600 text-white font-bold py-3 px-5 rounded-xl transition-all duration-200 transform active:scale-95"
                        >
                            <span>{isLastStep ? "Hadi Başlayalım" : "İleri"}</span>
                            {isLastStep ? <PlayIcon size={16} /> : <ArrowRightIcon />}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default TutorialOverlay;