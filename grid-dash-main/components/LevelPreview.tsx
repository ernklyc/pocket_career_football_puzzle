import React from 'react';
import { BLOCKS_DEFINITIONS } from '../constants';

interface LevelPreviewProps {
  gridSize: { rows: number; cols: number };
  blockTypes: string[];
}

const LevelPreview: React.FC<LevelPreviewProps> = ({ gridSize, blockTypes }) => {
  return (
    <div
      className="absolute right-full mr-4 top-1/2 -translate-y-1/2 w-max p-3 bg-white/95 backdrop-blur-md rounded-lg shadow-lg border border-slate-200 pointer-events-none z-20 animate-level-preview"
      role="tooltip"
    >
      <h4 className="text-xs font-bold text-slate-500 mb-2 border-b pb-1">Önizleme</h4>
      <div className="flex items-start gap-4">
        <div>
          <p className="text-[10px] text-slate-400 text-center mb-1">{`${gridSize.rows}x${gridSize.cols}`}</p>
          <div
            className="grid gap-px bg-slate-300 p-px rounded-sm"
            style={{
              gridTemplateColumns: `repeat(${gridSize.cols}, 1fr)`,
            }}
          >
            {Array.from({ length: gridSize.rows * gridSize.cols }).map((_, i) => (
              <div key={i} className="w-2.5 h-2.5 bg-slate-100 shadow-inner" />
            ))}
          </div>
        </div>

        {blockTypes.length > 0 && (
          <div className="border-l pl-4">
            <p className="text-[10px] text-slate-400 mb-1">Bloklar</p>
            <div className="grid grid-cols-4 gap-2 items-center">
              {blockTypes.slice(0, 8).map((name, index) => {
                const def = BLOCKS_DEFINITIONS[name];
                if (!def) return null;
                return (
                  <div key={`${name}-${index}`} className="flex flex-col gap-px">
                    {def.shape.map((row, r) => (
                      <div key={r} className="flex gap-px">
                        {row.map((cell, c) => (
                          <div
                            key={c}
                            className={`w-1.5 h-1.5 rounded-px ${cell ? `${def.color.split(' ')[0]}` : 'opacity-0'}`}
                          />
                        ))}
                      </div>
                    ))}
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </div>
       <style>{`
        @keyframes level-preview-anim {
            from { opacity: 0; transform: translateY(-50%) scale(0.95) translateX(10px); }
            to { opacity: 1; transform: translateY(-50%) scale(1) translateX(0); }
        }
        .animate-level-preview { 
            animation: level-preview-anim 0.2s cubic-bezier(0.22, 1, 0.36, 1) forwards;
        }
      `}</style>
    </div>
  );
};

export default LevelPreview;