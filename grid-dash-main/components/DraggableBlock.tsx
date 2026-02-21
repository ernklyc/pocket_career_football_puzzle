import React, { forwardRef } from 'react';
import type { Block } from '../types';
import RotateIcon from './icons/RotateIcon';
import FlipIcon from './icons/FlipIcon';
import { useSound } from '../hooks/useSound';
import { useHaptics } from '../hooks/useHaptics';

interface DraggableBlockProps {
  block: Block;
  onRotate: (blockId: string) => void;
  onFlip: (blockId: string) => void;
  onDragStart: (offsetX: number, offsetY: number) => void;
  onDragEnd: () => void;
  isHinted?: boolean;
  isSolving?: boolean;
}

const DraggableBlock = forwardRef<HTMLDivElement, DraggableBlockProps>(({ block, onRotate, onFlip, onDragStart, onDragEnd, isHinted, isSolving }, ref) => {
  const { playSound } = useSound();
  const { vibrateClick } = useHaptics();

  const handleDragStart = (e: React.DragEvent<HTMLDivElement>, r: number, c: number) => {
    e.dataTransfer.setData('application/json', JSON.stringify({ blockId: block.id }));
    e.dataTransfer.effectAllowed = 'move';
    onDragStart(c, r);
  };

  const handleRotateClick = () => {
    playSound('rotate');
    vibrateClick();
    onRotate(block.id);
  };

  const handleFlipClick = () => {
    playSound('rotate');
    vibrateClick();
    onFlip(block.id);
  };
  
  const containerClasses = `relative group flex flex-col justify-between p-2 bg-slate-50 rounded-xl transition-all duration-300 border w-full lg:w-auto draggable-block-hover
    ${isHinted 
        ? 'border-amber-400 scale-105 shadow-2xl shadow-amber-400/50 animate-pulse' 
        : 'border-slate-200 shadow-lg'
    }
    ${isSolving ? 'opacity-0 scale-75 -translate-y-4 pointer-events-none' : ''}
    `;

  return (
    <div ref={ref} className={containerClasses}>
      <div 
        className="cursor-grab active:cursor-grabbing flex-grow flex items-center justify-center h-[7.5rem]"
      >
        <div className="flex flex-col gap-px" style={{ filter: 'drop-shadow(0 1px 1px rgb(0 0 0 / 0.2))' }}>
            {block.shape.map((row, r) => (
            <div key={r} className="flex gap-px">
                {row.map((cell, c) => (
                <div
                    key={c}
                    draggable={!!cell}
                    onDragStart={(e) => handleDragStart(e, r, c)}
                    onDragEnd={onDragEnd}
                    className={`rounded-sm transition-opacity duration-200 ${
                    cell ? block.color : 'opacity-0 pointer-events-none'
                    }`}
                    style={{
                      width: `1.5rem`,
                      height: `1.5rem`,
                    }}
                />
                ))}
            </div>
            ))}
        </div>
      </div>
      <div className="flex justify-between items-center pt-2 border-t border-slate-200 mt-2">
          <button 
            onClick={handleFlipClick}
            className="flex-1 flex justify-center items-center gap-2 bg-slate-100 text-slate-600 p-2 rounded-lg transition-all duration-200 transform hover:scale-105 hover:bg-sky-100 hover:text-sky-700 focus:outline-none focus:ring-2 focus:ring-sky-400"
            aria-label="Bloku Çevir"
          >
            <FlipIcon />
          </button>
          <div className="w-px h-6 bg-slate-200 mx-1"></div>
          <button 
            onClick={handleRotateClick}
            className="flex-1 flex justify-center items-center gap-2 bg-slate-100 text-slate-600 p-2 rounded-lg transition-all duration-200 transform hover:scale-105 hover:bg-sky-100 hover:text-sky-700 focus:outline-none focus:ring-2 focus:ring-sky-400"
            aria-label="Bloku Döndür"
          >
            <RotateIcon />
          </button>
      </div>
    </div>
  );
});

export default DraggableBlock;
