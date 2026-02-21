import React from 'react';
import DiamondIcon from './icons/DiamondIcon';

interface GridCellProps {
  row: number;
  col: number;
  color: string;
  draggable?: boolean;
  onDragStart?: (e: React.DragEvent<HTMLDivElement>) => void;
  onDragEnd?: (e: React.DragEvent<HTMLDivElement>) => void;
  isNewlyPlaced?: boolean;
  hasGem?: boolean;
}

const GridCell: React.FC<GridCellProps> = ({ row, col, color, draggable, onDragStart, onDragEnd, isNewlyPlaced, hasGem }) => {
  const baseClasses = "w-full h-full rounded-sm transition-colors duration-100 relative";
  
  let cellClasses = "bg-black/10 shadow-inner"; // Default empty
  if (color) {
      if (color === 'preview-valid') {
          cellClasses = 'bg-emerald-400/80';
      } else if (color === 'preview-invalid') {
          cellClasses = 'bg-rose-400/80';
      } else if (color === 'hint') {
          cellClasses = 'bg-amber-400/90 border-2 border-amber-300 animate-pulse';
      } else if (color === 'solving') {
          cellClasses = 'bg-teal-400/90 border-2 border-teal-300 animate-pulse';
      } else {
          cellClasses = `${color} ${draggable ? 'cursor-grab active:cursor-grabbing' : ''}`;
      }
  }

  const style = color && !['preview-valid', 'preview-invalid', 'hint', 'solving'].includes(color) 
    ? { filter: 'drop-shadow(0 1px 1px rgb(0 0 0 / 0.2))' } 
    : {};

  return (
    <div
      data-row={row}
      data-col={col}
      className={`${baseClasses} ${cellClasses} ${isNewlyPlaced ? 'animate-cell-place' : ''}`}
      style={style}
      draggable={draggable}
      onDragStart={onDragStart}
      onDragEnd={onDragEnd}
    >
      {hasGem && (
        <div className="absolute inset-0 flex items-center justify-center pointer-events-none z-10">
          <div className="w-2/3 h-2/3 animate-pulse">
            <DiamondIcon className="text-white drop-shadow-lg" style={{filter: 'drop-shadow(0 2px 3px rgba(0,0,0,0.5))'}} />
          </div>
        </div>
      )}
    </div>
  );
};

export default React.memo(GridCell);