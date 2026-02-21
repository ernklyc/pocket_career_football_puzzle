
import React, { useEffect, useRef, useCallback } from 'react';
import type { Badge } from '../types';
import XIcon from './icons/XIcon';

interface BadgeNotificationToastProps {
    badges: Badge[];
    onDismiss: (badgeId: string) => void;
}

const BadgeNotification: React.FC<{ badge: Badge; onDismiss: (id: string) => void }> = ({ badge, onDismiss }) => {
    const toastRef = useRef<HTMLDivElement>(null);
    const interactionRef = useRef({ isDragging: false, startX: 0, currentTranslateX: 0 });
    const autoDismissTimerRef = useRef<number | null>(null);

    const handleDismiss = useCallback(() => {
        const element = toastRef.current;
        if (!element || element.dataset.dismissed === 'true') return;
        
        element.dataset.dismissed = 'true';
        if (autoDismissTimerRef.current) clearTimeout(autoDismissTimerRef.current);

        element.style.transform = 'translateX(110%)';
        element.style.opacity = '0';
        
        setTimeout(() => onDismiss(badge.id), 500);
    }, [badge.id, onDismiss]);
    
    useEffect(() => {
        const element = toastRef.current;
        if (element) {
            requestAnimationFrame(() => {
                element.style.transform = 'translateX(0)';
                element.style.opacity = '1';
            });
        }
        autoDismissTimerRef.current = window.setTimeout(handleDismiss, 5000);
        return () => { if (autoDismissTimerRef.current) clearTimeout(autoDismissTimerRef.current); };
    }, [handleDismiss]);
    
    const onPointerDown = useCallback((e: React.PointerEvent<HTMLDivElement>) => {
        if ((e.target as HTMLElement).closest('button')) return;
        interactionRef.current = { ...interactionRef.current, isDragging: true, startX: e.clientX };
        if(toastRef.current) {
            toastRef.current.style.transition = 'none';
            toastRef.current.setPointerCapture(e.pointerId);
        }
        if (autoDismissTimerRef.current) clearTimeout(autoDismissTimerRef.current);
    }, []);

    const onPointerMove = useCallback((e: React.PointerEvent<HTMLDivElement>) => {
        if (!interactionRef.current.isDragging || !toastRef.current) return;
        const deltaX = e.clientX - interactionRef.current.startX;
        if (deltaX > 0) {
            interactionRef.current.currentTranslateX = deltaX;
            toastRef.current.style.transform = `translateX(${deltaX}px)`;
        }
    }, []);

    const onPointerUp = useCallback((e: React.PointerEvent<HTMLDivElement>) => {
        if (!interactionRef.current.isDragging || !toastRef.current) return;
        
        toastRef.current.releasePointerCapture(e.pointerId);
        toastRef.current.style.transition = 'transform 0.3s ease-out, opacity 0.5s ease';
        
        if (interactionRef.current.currentTranslateX > toastRef.current.offsetWidth / 3) {
            handleDismiss();
        } else {
            toastRef.current.style.transform = 'translateX(0)';
            autoDismissTimerRef.current = window.setTimeout(handleDismiss, 5000);
        }
        interactionRef.current = { isDragging: false, startX: 0, currentTranslateX: 0 };
    }, [handleDismiss]);

    const Icon = badge.icon;

    return (
        <div
            ref={toastRef}
            onPointerDown={onPointerDown}
            onPointerMove={onPointerMove}
            onPointerUp={onPointerUp}
            onPointerCancel={onPointerUp}
            style={{ transform: 'translateX(110%)', opacity: '0' }}
            className="relative w-full bg-white rounded-xl border border-slate-200 p-4 flex items-center gap-4 shadow-lg cursor-grab active:cursor-grabbing touch-none transition-transform duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] transition-opacity"
        >
            <div className="p-3 rounded-full bg-sky-100 shrink-0">
                <Icon className="w-8 h-8 text-sky-600" />
            </div>
            <div className="flex-grow min-w-0">
                <p className="text-slate-500 text-sm font-semibold">Başarım Kazanıldı!</p>
                <h3 className="text-slate-800 font-bold text-lg truncate">{badge.name}</h3>
            </div>
            <button
                onClick={handleDismiss}
                className="absolute top-2 right-2 p-1.5 rounded-full text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors z-10"
                aria-label="Bildirimi kapat"
            >
                <XIcon size={16} />
            </button>
        </div>
    );
};


const BadgeNotificationToast: React.FC<BadgeNotificationToastProps> = ({ badges, onDismiss }) => {
    if (!badges || badges.length === 0) {
        return null;
    }
    
    return (
        <div className="fixed top-4 right-4 z-[100] flex flex-col gap-3 w-96 max-w-[calc(100vw-2rem)]">
           {badges.map(badge => (
               <BadgeNotification key={badge.id} badge={badge} onDismiss={onDismiss} />
           ))}
        </div>
    );
};

export default BadgeNotificationToast;
