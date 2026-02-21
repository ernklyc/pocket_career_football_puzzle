import React, { useState, useCallback, useMemo, useEffect, useRef } from 'react';
import type { Level, Block, Shape, PlacedBlock, LogEntry } from '../types';
import DraggableBlock from './DraggableBlock';
import GridCell from './GridCell';
import useTimer from '../hooks/useTimer';
import LightbulbIcon from './icons/LightbulbIcon';
import HourglassIcon from './icons/HourglassIcon';
import HomeIcon from './icons/HomeIcon';
import WandIcon from './icons/WandIcon';
import { CELL_SIZE_REM, CELL_GAP_PX } from '../constants';
import TutorialOverlay, { tutorialSteps } from './TutorialOverlay';
import PauseIcon from './icons/PauseIcon';
import PauseModal from './PauseModal';
import { useSound } from '../hooks/useSound';
import { useHaptics } from '../hooks/useHaptics';
import TrophyIcon from './icons/TrophyIcon';
import ClipboardListIcon from './icons/ClipboardListIcon';
import EyeIcon from './icons/EyeIcon';
import EyeOffIcon from './icons/EyeOffIcon';
import ParticleSystem, { ParticleEvent } from './ParticleSystem';
import DiamondIcon from './icons/DiamondIcon';

// A map from Tailwind CSS background color classes to hex codes for particle effects.
const tailwindColorMap: Record<string, string> = {
    'bg-sky-500': '#0ea5e9', 'bg-amber-400': '#facc15', 'bg-purple-500': '#a855f7',
    'bg-orange-500': '#f97316', 'bg-blue-500': '#3b82f6', 'bg-emerald-500': '#10b981',
    'bg-rose-500': '#f43f5e', 'bg-green-500': '#22c55e', 'bg-red-500': '#ef4444',
    'bg-indigo-500': '#6366f1', 'bg-cyan-500': '#06b6d4', 'bg-fuchsia-500': '#d946ef',
    'bg-lime-500': '#84cc16', 'bg-teal-500': '#14b8a6', 'bg-violet-500': '#8b5cf6',
    'bg-pink-500': '#ec4899', 'bg-amber-600': '#d97706',
};

const getHexFromTailwindClass = (className: string): string => {
    const bgColorClass = className.split(' ').find(cls => cls.startsWith('bg-'));
    return bgColorClass ? tailwindColorMap[bgColorClass] || '#ffffff' : '#ffffff';
};

interface TutorialTargets {
    grid: HTMLElement | null;
    palette: HTMLElement | null;
    firstBlock: HTMLElement | null;
    powerUps: HTMLElement | null;
}

interface GameScreenProps {
  level: Level;
  onLevelComplete: (stats: { time: number; levelId: number; baseScore: number; hintsUsed: number; gemsCollectedInLevel: number; }) => void;
  onBack: () => void;
  hints: number;
  onUseHint: () => boolean;
  timeShifts: number;
  onUseTimeShift: () => boolean;
  solverPieces: number;
  onUseSolverPiece: () => boolean;
  gems: number;
  hasSeenTutorial: boolean;
  onTutorialComplete: () => void;
  onCollectGem: (gemValue: number) => void;
}

const rotateShapeClockwise = (shape: Shape): Shape => {
  const rows = shape.length;
  const cols = shape[0].length;
  const newShape: Shape = Array.from({ length: cols }, () => Array(rows).fill(0));
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      newShape[c][rows - 1 - r] = shape[r][c];
    }
  }
  return newShape;
};

const flipShapeHorizontal = (shape: Shape): Shape => {
  return shape.map(row => [...row].reverse());
};

interface GridCellState {
  color: string;
  blockId: string;
}

type HintInfo = {
  blockId: string;
  position: { row: number; col: number };
  shape: Shape;
};

type SolvingInfo = HintInfo;

const GameScreen: React.FC<GameScreenProps> = ({ level, onLevelComplete, onBack, hints, onUseHint, timeShifts, onUseTimeShift, solverPieces, onUseSolverPiece, gems, hasSeenTutorial, onTutorialComplete, onCollectGem }) => {
  const { gridSize } = level;
  const [placedBlocks, setPlacedBlocks] = useState<PlacedBlock[]>([]);
  const [availableBlocks, setAvailableBlocks] = useState<Block[]>(level.blocks);
  const [dragPreview, setDragPreview] = useState<{ row: number; col: number; isValid: boolean } | null>(null);
  const [hintInfo, setHintInfo] = useState<HintInfo | null>(null);
  const [solvingInfo, setSolvingInfo] = useState<SolvingInfo | null>(null);
  const [isTimeShiftActive, setIsTimeShiftActive] = useState(false);
  const [tutorialStep, setTutorialStep] = useState(hasSeenTutorial ? -1 : 0);
  const [lastPlacedBlockId, setLastPlacedBlockId] = useState<string | null>(null);
  const [isPaused, setIsPaused] = useState(false);
  const isCompletingRef = useRef(false);
  const { playSound } = useSound();
  const { vibrateClick, vibrateSuccess, vibrateFailure } = useHaptics();
  
  const [currentScore, setCurrentScore] = useState(0);
  const [scoreAnimations, setScoreAnimations] = useState<{ id: number; value: number; x: number; y: number }[]>([]);
  const scoreAnimationId = useRef(0);
  
  const hintsUsedThisLevel = useRef(0);
  const gemsCollectedThisLevel = useRef(0);
  const [gemsOnGrid, setGemsOnGrid] = useState(level.gemPositions || []);
  const [displayGems, setDisplayGems] = useState(gems);

  const [logEntries, setLogEntries] = useState<LogEntry[]>([]);
  const logIdCounter = useRef(0);
  const [isLogVisible, setIsLogVisible] = useState(true);

  // State for visual feedback
  const [particles, setParticles] = useState<ParticleEvent[]>([]);
  const particleIdCounter = useRef(0);
  const [activePowerUp, setActivePowerUp] = useState<string | null>(null);


  // Refs for tutorial and particle effect positioning
  const paletteRef = useRef<HTMLDivElement>(null);
  const powerUpsRef = useRef<HTMLDivElement>(null);
  const firstBlockRef = useRef<HTMLDivElement>(null);
  const gridContainerRef = useRef<HTMLDivElement>(null);
  const dropContainerRef = useRef<HTMLDivElement>(null);
  const hintButtonRef = useRef<HTMLButtonElement>(null);
  const timeShiftButtonRef = useRef<HTMLButtonElement>(null);
  const solverButtonRef = useRef<HTMLButtonElement>(null);

  const [tutorialTargets, setTutorialTargets] = useState<TutorialTargets>({
    grid: null,
    palette: null,
    firstBlock: null,
    powerUps: null,
  });


  const draggingItem = useRef<{
    block: Block;
    offsetX: number;
    offsetY: number;
    source: 'palette' | PlacedBlock;
// FIX: Corrected initialization of useRef. It was referencing itself before declaration.
  } | null>(null);

  const { time, stopTimer, startTimer, resetTimer, setSpeed } = useTimer();
  
  const isTutorialActive = tutorialStep >= 0;

  const triggerParticles = useCallback((x: number, y: number, type: ParticleEvent['type'], color?: string) => {
    const newParticle: ParticleEvent = {
        id: particleIdCounter.current++,
        x,
        y,
        color,
        type,
    };
    setParticles(prev => [...prev, newParticle]);
    setTimeout(() => {
        setParticles(prev => prev.filter(p => p.id !== newParticle.id));
    }, 4000); // Long enough for all animations to finish
  }, []);

  const addLogEntry = useCallback((message: string, type: LogEntry['type'], icon?: LogEntry['icon']) => {
    const id = logIdCounter.current++;
    const newEntry: LogEntry = { id, message, type, icon };
    setLogEntries(prev => [newEntry, ...prev].slice(0, 5));
  }, []);

  const addScore = useCallback((points: number, clientX: number, clientY: number) => {
    setCurrentScore(prev => prev + points);
    
    if (!dropContainerRef.current) return;
    const rect = dropContainerRef.current.getBoundingClientRect();

    const newAnimation = {
        id: scoreAnimationId.current++,
        value: points,
        x: clientX - rect.left,
        y: clientY - rect.top,
    };
    
    setScoreAnimations(prev => [...prev, newAnimation]);
    
    setTimeout(() => {
        setScoreAnimations(prev => prev.filter(anim => anim.id !== newAnimation.id));
    }, 1000);
  }, []);

  useEffect(() => {
    if (isTutorialActive) {
      setTutorialTargets({
          grid: gridContainerRef.current,
          palette: paletteRef.current,
          firstBlock: firstBlockRef.current,
          powerUps: powerUpsRef.current,
      });
    }
  }, [isTutorialActive, tutorialStep]);


  useEffect(() => {
    resetTimer();
    if (isTutorialActive) {
        stopTimer();
    } else {
        addLogEntry('Seviye başladı!', 'event');
    }
    return () => {
        stopTimer();
    };
  }, [level.id, resetTimer, stopTimer, isTutorialActive, addLogEntry]);


  const totalGridCells = useMemo(() => gridSize.rows * gridSize.cols, [gridSize]);
  
  const filledGridCells = useMemo(() => {
      return placedBlocks.reduce((acc, block) => {
          return acc + block.shape.flat().filter(cell => cell === 1).length;
      }, 0);
  }, [placedBlocks]);

  useEffect(() => {
    if (!isCompletingRef.current && totalGridCells > 0 && filledGridCells === totalGridCells && availableBlocks.length === 0) {
      isCompletingRef.current = true;
      stopTimer();
      addLogEntry('Seviye Tamamlandı!', 'event', TrophyIcon);
      if (gridContainerRef.current && dropContainerRef.current) {
        const gridRect = gridContainerRef.current.getBoundingClientRect();
        const dropRect = dropContainerRef.current.getBoundingClientRect();
        const x = (gridRect.left - dropRect.left) + gridRect.width / 2;
        const y = (gridRect.top - dropRect.top) + gridRect.height / 2;
        triggerParticles(x, y, 'confetti');
      }
      setTimeout(() => onLevelComplete({
        time, 
        levelId: level.id, 
        baseScore: currentScore, 
        hintsUsed: hintsUsedThisLevel.current,
        gemsCollectedInLevel: gemsCollectedThisLevel.current
      }), 1500);
    }
  }, [filledGridCells, totalGridCells, onLevelComplete, stopTimer, time, availableBlocks.length, level.id, currentScore, addLogEntry, triggerParticles]);
  
  const staticGrid = useMemo(() => {
    const newGrid: (GridCellState | null)[][] = Array.from({ length: gridSize.rows }, () => Array(gridSize.cols).fill(null));
    for (const pBlock of placedBlocks) {
      for (let r = 0; r < pBlock.shape.length; r++) {
        for (let c = 0; c < pBlock.shape[0].length; c++) {
          if (pBlock.shape[r][c]) {
            const gridRow = pBlock.row + r;
            const gridCol = pBlock.col + c;
            if (gridRow < gridSize.rows && gridCol < gridSize.cols) {
              newGrid[gridRow][gridCol] = { color: pBlock.color, blockId: pBlock.id };
            }
          }
        }
      }
    }
    return newGrid;
  }, [placedBlocks, gridSize]);

  const isPlacementValid = useCallback((block: Block, row: number, col: number): boolean => {
    for (let r = 0; r < block.shape.length; r++) {
      for (let c = 0; c < block.shape[0].length; c++) {
        if (block.shape[r][c]) {
          const gridRow = row + r;
          const gridCol = col + c;
          if (
            gridRow < 0 || gridRow >= gridSize.rows ||
            gridCol < 0 || gridCol >= gridSize.cols ||
            staticGrid[gridRow][gridCol] !== null
          ) {
            return false;
          }
        }
      }
    }
    return true;
  }, [gridSize, staticGrid]);
  
  const handleTutorialClose = useCallback(() => {
    if (isTutorialActive) {
      onTutorialComplete();
      startTimer();
      setTutorialStep(-1);
    }
  }, [isTutorialActive, onTutorialComplete, startTimer]);
  
  const handleTutorialNext = useCallback(() => {
    setTutorialStep(prev => {
      if (prev >= tutorialSteps.length - 1) {
        handleTutorialClose();
        return -1;
      }
      return prev + 1;
    });
  }, [handleTutorialClose]);

  const advanceTutorialIfOnStep = useCallback((stepId: string) => {
    if (isTutorialActive && tutorialSteps[tutorialStep]?.id === stepId) {
      handleTutorialNext();
    }
  }, [isTutorialActive, tutorialStep, handleTutorialNext]);
  
  const handleDragStart = (block: Block, offsetX: number, offsetY: number, source: 'palette' | PlacedBlock) => {
      advanceTutorialIfOnStep('palette');
      if (source !== 'palette') {
          setPlacedBlocks(prev => prev.filter(b => b.id !== source.id));
      }
      draggingItem.current = { block, offsetX, offsetY, source };
  };

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    if (!draggingItem.current || !gridContainerRef.current) return;

    const gridContainer = gridContainerRef.current;
    const rect = gridContainer.getBoundingClientRect();
    
    const gridWidthValue = gridContainer.clientWidth;
    const gridHeightValue = gridContainer.clientHeight;
    
    const gap = CELL_GAP_PX;
    const cellWidth = (gridWidthValue - (gridSize.cols - 1) * gap) / gridSize.cols;
    const cellHeight = (gridHeightValue - (gridSize.rows - 1) * gap) / gridSize.rows;

    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const col = Math.floor(x / (cellWidth + gap));
    const row = Math.floor(y / (cellHeight + gap));
    
    const { block, offsetX, offsetY } = draggingItem.current;
    const dropRow = row - offsetY;
    const dropCol = col - offsetX;

    if (dragPreview && dragPreview.row === dropRow && dragPreview.col === dropCol) {
        return;
    }
    
    const isValid = isPlacementValid(block, dropRow, dropCol);
    setDragPreview({ row: dropRow, col: dropCol, isValid });
  };
  
  const handlePaletteDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  };

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    const currentDrag = draggingItem.current;
    if (!currentDrag || !dragPreview) return;

    const { block } = currentDrag;
    const { row, col, isValid } = dragPreview;

    if (isValid) {
      playSound('place-success');
      vibrateSuccess();
      const newPlacedBlock: PlacedBlock = { ...block, row, col };
      setLastPlacedBlockId(newPlacedBlock.id);
      setPlacedBlocks(prev => [...prev, newPlacedBlock]);

      const newlyCollectedGems: {row: number, col: number}[] = [];
      const gridRect = gridContainerRef.current?.getBoundingClientRect();
      gemsOnGrid.forEach(gemPos => {
        for (let r = 0; r < block.shape.length; r++) {
          for (let c = 0; c < block.shape[0].length; c++) {
            if (block.shape[r][c] && gemPos.row === row + r && gemPos.col === col + c) {
              newlyCollectedGems.push(gemPos);
              if (gridRect && dropContainerRef.current) {
                const dropRect = dropContainerRef.current.getBoundingClientRect();
                const cellWidth = gridRect.width / gridSize.cols;
                const cellHeight = gridRect.height / gridSize.rows;
                const gemX = gridRect.left - dropRect.left + (gemPos.col + 0.5) * cellWidth;
                const gemY = gridRect.top - dropRect.top + (gemPos.row + 0.5) * cellHeight;
                triggerParticles(gemX, gemY, 'burst', '#0ea5e9'); // Sky color for gems
              }
            }
          }
        }
      });

      if (newlyCollectedGems.length > 0) {
        const gemValue = newlyCollectedGems.length;
        playSound('gem-collect');
        setGemsOnGrid(prev => prev.filter(g => !newlyCollectedGems.find(ng => ng.row === g.row && ng.col === g.col)));
        gemsCollectedThisLevel.current += gemValue;
        setDisplayGems(prev => prev + gemValue);
        onCollectGem(gemValue);
        addLogEntry(`+${gemValue} Elmas`, 'gem', DiamondIcon);
      }

      if (dropContainerRef.current) {
        const rect = dropContainerRef.current.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        triggerParticles(x, y, 'burst', getHexFromTailwindClass(block.color));
        const points = block.shape.flat().reduce((sum, cell) => sum + cell, 0) * 10;
        addScore(points, e.clientX, e.clientY);
        addLogEntry(`+${points} Puan`, 'score', TrophyIcon);
      }

      if (currentDrag.source === 'palette') {
        setAvailableBlocks(prev => prev.filter(b => b.id !== block.id));
      }
      setTimeout(() => setLastPlacedBlockId(null), 400);
    } else {
      playSound('place-fail');
      vibrateFailure();
      if (gridContainerRef.current?.parentElement) {
        gridContainerRef.current.parentElement.classList.add('animate-shake');
        setTimeout(() => {
          gridContainerRef.current?.parentElement?.classList.remove('animate-shake');
        }, 400);
      }
      if (currentDrag.source !== 'palette') {
        setPlacedBlocks(prev => [...prev, currentDrag.source as PlacedBlock]);
      }
    }
    
    draggingItem.current = null;
    setDragPreview(null);
  };
  
  const handlePaletteDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setDragPreview(null);
    const currentDrag = draggingItem.current;
    if (!currentDrag) return;

    const { block, source } = currentDrag;

    if (source !== 'palette') {
      setAvailableBlocks(prev => {
        if (prev.find(b => b.id === block.id)) {
          return prev;
        }
        return [...prev, { ...block, shape: block.initialShape }];
      });
    }

    draggingItem.current = null;
  };

  const handleDragLeave = (e: React.DragEvent<HTMLDivElement>) => {
    setDragPreview(null);
  }

  const handleDragEnd = () => {
    const currentDrag = draggingItem.current;
    if (currentDrag) {
      if (currentDrag.source !== 'palette') {
        setPlacedBlocks(prev => [...prev, currentDrag.source as PlacedBlock]);
      }
      draggingItem.current = null;
      setDragPreview(null);
    }
  };

  const handleRotate = (blockId: string) => {
    advanceTutorialIfOnStep('actions');
    setAvailableBlocks(prevBlocks =>
      prevBlocks.map(block =>
        block.id === blockId ? { ...block, shape: rotateShapeClockwise(block.shape) } : block
      )
    );
  };

  const handleFlip = (blockId: string) => {
    advanceTutorialIfOnStep('actions');
    setAvailableBlocks(prevBlocks =>
      prevBlocks.map(block =>
        block.id === blockId ? { ...block, shape: flipShapeHorizontal(block.shape) } : block
      )
    );
  };
  
  const handleSimulateAction = (action: 'rotate' | 'flip') => {
    setAvailableBlocks(prevBlocks => {
        if (prevBlocks.length === 0) return prevBlocks;
        
        const firstBlock = prevBlocks[0];
        const updatedFirstBlock = {
            ...firstBlock,
            shape: action === 'rotate' ? rotateShapeClockwise(firstBlock.shape) : flipShapeHorizontal(firstBlock.shape)
        };
        
        return [updatedFirstBlock, ...prevBlocks.slice(1)];
    });
  };

  const triggerPowerUpAnimation = (name: string, buttonRef: React.RefObject<HTMLButtonElement>, color: string) => {
    setActivePowerUp(name);
    if (buttonRef.current) {
        const rect = buttonRef.current.getBoundingClientRect();
        triggerParticles(rect.left + rect.width / 2, rect.top + rect.height / 2, 'burst', color);
    }
    setTimeout(() => setActivePowerUp(null), 500);
  };

  const triggerHint = useCallback(() => {
    if (hintInfo || availableBlocks.length === 0) return;
    vibrateClick();
    playSound('ui-click');

    const wasHintUsed = onUseHint();
    if (wasHintUsed) {
      triggerPowerUpAnimation('hint', hintButtonRef, '#a855f7'); // Violet
      hintsUsedThisLevel.current += 1;
      addLogEntry('İpucu kullanıldı', 'powerup', LightbulbIcon);
      const blockToHint = availableBlocks[0];
      const solutionInfo = level.solution[blockToHint.id];

      if (solutionInfo) {
        setHintInfo({
          blockId: blockToHint.id,
          position: { row: solutionInfo.row, col: solutionInfo.col },
          shape: solutionInfo.shape,
        });

        setAvailableBlocks(prev =>
          prev.map(b =>
            b.id === blockToHint.id ? { ...b, shape: solutionInfo.shape } : b
          )
        );

        setTimeout(() => setHintInfo(null), 2500);
      }
    }
  }, [hintInfo, availableBlocks, onUseHint, level.solution, playSound, vibrateClick, addLogEntry, triggerParticles]);

  const triggerTimeShift = useCallback(() => {
    if (isTimeShiftActive) return;
    vibrateClick();
    playSound('ui-click');
    const wasUsed = onUseTimeShift();
    if (wasUsed) {
        triggerPowerUpAnimation('timeShift', timeShiftButtonRef, '#38bdf8'); // Sky
        addLogEntry('Zaman yavaşlatıldı!', 'powerup', HourglassIcon);
        setIsTimeShiftActive(true);
        setSpeed(0.25);
        setTimeout(() => {
            setSpeed(1);
            setIsTimeShiftActive(false);
        }, 5000);
    }
  }, [isTimeShiftActive, onUseTimeShift, setSpeed, playSound, vibrateClick, addLogEntry, triggerParticles]);
  
  const triggerSolverPiece = useCallback(() => {
    if (solvingInfo || hintInfo || availableBlocks.length === 0) return;
    vibrateClick();
    playSound('ui-click');

    const wasUsed = onUseSolverPiece();
    if (wasUsed) {
      triggerPowerUpAnimation('solver', solverButtonRef, '#2dd4bf'); // Teal
      addLogEntry('Çözücü parça kullanıldı', 'powerup', WandIcon);
      const blockToSolve = availableBlocks.find(b => level.solution[b.id]);
      if (blockToSolve) {
          const solutionInfo = level.solution[blockToSolve.id];

          setSolvingInfo({
            blockId: blockToSolve.id,
            position: { row: solutionInfo.row, col: solutionInfo.col },
            shape: solutionInfo.shape,
          });

          setTimeout(() => {
            setAvailableBlocks(prev => prev.filter(b => b.id !== blockToSolve.id));
            const newPlacedBlock: PlacedBlock = { 
                ...blockToSolve, 
                shape: solutionInfo.shape, 
                row: solutionInfo.row, 
                col: solutionInfo.col 
            };
            setPlacedBlocks(prev => [...prev, newPlacedBlock]);
            setSolvingInfo(null);
            playSound('place-success');
            vibrateSuccess();
            
            if (gridContainerRef.current && dropContainerRef.current) {
                const gridRect = gridContainerRef.current.getBoundingClientRect();
                const dropRect = dropContainerRef.current.getBoundingClientRect();
                const gridWidthValue = gridContainerRef.current.clientWidth;
                const gridHeightValue = gridContainerRef.current.clientHeight;
                const gap = CELL_GAP_PX;
                const cellWidth = (gridWidthValue - (level.gridSize.cols - 1) * gap) / level.gridSize.cols;
                const cellHeight = (gridHeightValue - (level.gridSize.rows - 1) * gap) / level.gridSize.rows;
                
                const blockWidthCells = solutionInfo.shape[0].length;
                const blockHeightCells = solutionInfo.shape.length;
                
                const pieceCenterXInGrid = (solutionInfo.col + blockWidthCells / 2) * cellWidth + solutionInfo.col * gap;
                const pieceCenterYInGrid = (solutionInfo.row + blockHeightCells / 2) * cellHeight + solutionInfo.row * gap;

                const xInDropContainer = (gridRect.left - dropRect.left) + pieceCenterXInGrid;
                const yInDropContainer = (gridRect.top - dropRect.top) + pieceCenterYInGrid;
                
                triggerParticles(xInDropContainer, yInDropContainer, 'burst', getHexFromTailwindClass(blockToSolve.color));
                
                const points = blockToSolve.initialShape.flat().reduce((sum, cell) => sum + cell, 0) * 10;
                addScore(points, gridRect.left + pieceCenterXInGrid, gridRect.top + pieceCenterYInGrid);
                addLogEntry(`+${points} Puan (Çözücü)`, 'score', TrophyIcon);
            }

          }, 1200);
      } else {
        console.warn("Solver piece used, but no solution found for any available block.");
      }
    }
  }, [solvingInfo, hintInfo, availableBlocks, onUseSolverPiece, level.solution, playSound, vibrateClick, vibrateSuccess, addScore, level.gridSize, addLogEntry, triggerParticles]);

  const handlePause = useCallback(() => {
    if (isTutorialActive) return;
    stopTimer();
    setIsPaused(true);
    playSound('ui-click');
    vibrateClick();
  }, [isTutorialActive, stopTimer, playSound, vibrateClick]);

  const handleResume = useCallback(() => {
    setIsPaused(false);
    startTimer();
  }, [startTimer]);

  const progressPercentage = totalGridCells > 0 ? (filledGridCells / totalGridCells) * 100 : 0;

  const renderGrid = useMemo(() => {
    const gridToRender = staticGrid.map(row => [...row]);

    const previewBlock = (dragPreview && draggingItem.current) ? draggingItem.current.block : null;
    const previewPos = dragPreview;

    if (previewBlock && previewPos) {
      const { row, col, isValid } = previewPos;
      for (let r = 0; r < previewBlock.shape.length; r++) {
        for (let c = 0; c < previewBlock.shape[0].length; c++) {
          if (previewBlock.shape[r][c]) {
            const gridRow = row + r;
            const gridCol = col + c;
            if (gridRow >= 0 && gridRow < gridSize.rows && gridCol >= 0 && gridCol < gridSize.cols) {
                 gridToRender[gridRow][gridCol] = {
                    color: isValid ? 'preview-valid' : 'preview-invalid',
                    blockId: 'preview'
                 };
            }
          }
        }
      }
    } else if (solvingInfo) {
      const { position, shape } = solvingInfo;
       for (let r = 0; r < shape.length; r++) {
            for (let c = 0; c < shape[0].length; c++) {
                if (shape[r][c]) {
                    const gridRow = position.row + r;
                    const gridCol = position.col + c;
                    if (gridRow >= 0 && gridRow < gridSize.rows && gridCol >= 0 && gridCol < gridSize.cols) {
                         gridToRender[gridRow][gridCol] = { color: 'solving', blockId: 'solving' };
                    }
                }
            }
        }
    } else if (hintInfo) {
      const { position, shape } = hintInfo;
       for (let r = 0; r < shape.length; r++) {
            for (let c = 0; c < shape[0].length; c++) {
                if (shape[r][c]) {
                    const gridRow = position.row + r;
                    const gridCol = position.col + c;
                    if (gridRow >= 0 && gridRow < gridSize.rows && gridCol >= 0 && gridCol < gridSize.cols) {
                         gridToRender[gridRow][gridCol] = { color: 'hint', blockId: 'hint' };
                    }
                }
            }
        }
    }
    return gridToRender;
  }, [staticGrid, dragPreview, gridSize, draggingItem, hintInfo, solvingInfo]);

  return (
    <div className={`flex flex-col h-[100svh] max-h-[100svh] p-2 sm:p-4 select-none fade-in bg-slate-200`}>
       <div className="absolute inset-0 bg-gradient-to-br from-sky-400 via-blue-500 to-indigo-600 opacity-80"></div>
      <header className="relative flex-shrink-0 w-full max-w-7xl mx-auto mb-2 sm:mb-4 z-10">
        <div className="flex justify-between items-center bg-black/10 backdrop-blur-2xl rounded-2xl p-2 sm:p-4 shadow-lg border border-white/20">
          <div className="flex items-center gap-2 md:gap-4">
            <div className={`flex items-center gap-2 px-3 py-1.5 rounded-lg bg-black/20 text-white ${isTimeShiftActive ? 'text-sky-300' : ''}`}>
                <HourglassIcon />
                <span className={`font-mono font-bold text-lg transition-colors ${isTimeShiftActive ? 'animate-pulse' : ''}`}>
                    {new Date(time * 1000).toISOString().substr(14, 5)}
                </span>
            </div>
            
            <div className={`flex items-center gap-2 px-3 py-1.5 rounded-lg bg-black/20 text-white`}>
                <TrophyIcon size={16} />
                <span className={`font-mono font-bold text-lg`}>
                    {currentScore.toLocaleString()}
                </span>
            </div>
            
            <div className={`flex items-center gap-2 px-3 py-1.5 rounded-lg bg-black/20 text-white`}>
                <DiamondIcon size={16} className="text-sky-400" />
                <span className={`font-mono font-bold text-lg`}>
                    {displayGems.toLocaleString()}
                </span>
            </div>
          </div>
          <div className="flex items-center">
             <button
              onClick={handlePause}
              className="p-2.5 bg-black/10 hover:bg-black/20 text-white rounded-lg transition-colors"
              aria-label="Oyunu Duraklat"
            >
              <PauseIcon />
            </button>
          </div>
        </div>
      </header>

      <div className="relative flex-grow w-full max-w-7xl mx-auto flex flex-col lg:flex-row gap-2 sm:gap-4 min-h-0">
          <div 
            ref={dropContainerRef}
            className="relative flex-1 min-h-0 flex flex-col items-center justify-center p-2 sm:p-6 bg-black/10 backdrop-blur-2xl rounded-2xl border border-white/20 shadow-xl overflow-hidden"
            onDrop={handleDrop}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
          >
            <div className="absolute top-4 left-4 z-10 text-left pointer-events-none">
              {level.name ? (
                <h1 className="text-2xl sm:text-3xl font-bold text-white leading-tight drop-shadow-md" title={level.name}>
                  {level.name}
                </h1>
              ) : (
                <div className="h-9 w-48 sm:w-64 bg-white/20 rounded-md animate-pulse mb-1"></div>
              )}
              <p className="text-base text-white/80 font-semibold drop-shadow-sm">Seviye {level.levelNumber}</p>
            </div>
            <ParticleSystem particles={particles} />
            <div 
                className={`inline-block bg-black/20 p-2 md:p-4 rounded-xl shadow-inner transition-all duration-300 ${isTimeShiftActive ? 'ring-4 ring-sky-300/80 animate-pulse' : ''}`}>
                <div 
                    ref={gridContainerRef}
                    className="grid bg-slate-300/50"
                    style={{
                        gap: `${CELL_GAP_PX}px`,
                        gridTemplateRows: `repeat(${gridSize.rows}, ${CELL_SIZE_REM}rem)`,
                        gridTemplateColumns: `repeat(${gridSize.cols}, ${CELL_SIZE_REM}rem)`,
                    }}
                >
                {renderGrid.map((row, r) =>
                    row.map((cell, c) => (
                    <GridCell 
                        key={`${r}-${c}`} 
                        row={r} 
                        col={c} 
                        color={cell?.color || ''}
                        hasGem={!!gemsOnGrid.find(g => g.row === r && g.col === c)}
                        isNewlyPlaced={cell?.blockId === lastPlacedBlockId}
                        draggable={!!cell && cell.blockId !== 'preview' && cell.blockId !== 'hint'}
                        onDragStart={(e) => {
                        const pBlock = placedBlocks.find(b => b.id === cell?.blockId);
                        if (pBlock) {
                            e.dataTransfer.effectAllowed = 'move';
                            const offsetY = r - pBlock.row;
                            const offsetX = c - pBlock.col;
                            handleDragStart(pBlock, offsetX, offsetY, pBlock);
                        }
                        }}
                        onDragEnd={handleDragEnd}
                    />
                    ))
                )}
                </div>
            </div>
             <div className="w-full max-w-md mx-auto mt-4">
                 <div className="text-sm text-center text-white/80 mb-1">{filledGridCells} / {totalGridCells}</div>
                 <div className="w-full bg-black/20 rounded-full h-2.5 shadow-inner">
                    <div
                        className="h-full rounded-full transition-all duration-300 ease-out bg-gradient-to-r from-sky-400 to-indigo-500"
                        style={{ width: `${progressPercentage}%` }}
                    ></div>
                </div>
            </div>
            {scoreAnimations.map(anim => (
                <div
                    key={anim.id}
                    className="absolute text-2xl font-black text-white animate-score-popup pointer-events-none"
                    style={{
                        left: anim.x,
                        top: anim.y,
                        transform: 'translate(-50%, -50%)',
                        textShadow: '0 2px 4px rgba(0,0,0,0.5)',
                    }}
                >
                    +{anim.value}
                </div>
            ))}
            <div className="absolute bottom-4 inset-x-4 z-20 flex justify-between items-end pointer-events-none">
                <div className="pointer-events-auto w-64">
                    <div className="flex items-center justify-between text-white/80 mb-2">
                        <div className="flex items-center gap-2">
                            <ClipboardListIcon size={16} />
                            <h3 className="text-sm font-bold uppercase tracking-wider">Oyun Akışı</h3>
                        </div>
                        <button 
                            onClick={() => setIsLogVisible(v => !v)}
                            className="p-1 rounded-full text-slate-400 hover:text-white hover:bg-white/10 transition-colors"
                            aria-label={isLogVisible ? "Akışı Gizle" : "Akışı Göster"}
                        >
                            {isLogVisible ? <EyeOffIcon size={16}/> : <EyeIcon size={16}/>}
                        </button>
                    </div>
                    {isLogVisible && (
                        <div className="space-y-2">
                        {logEntries.map(entry => {
                            const Icon = entry.icon;
                            let iconColor = 'text-slate-300';
                            if (entry.type === 'score') iconColor = 'text-amber-400';
                            if (entry.type === 'powerup') iconColor = 'text-sky-400';
                            if (entry.type === 'event') iconColor = 'text-emerald-400';
                            if (entry.type === 'gem') iconColor = 'text-sky-300';

                            return (
                                <div key={entry.id} className="flex items-center gap-3 bg-slate-900/50 backdrop-blur-md p-2.5 rounded-lg animate-log-entry shadow-lg">
                                    {Icon && <div className="flex-shrink-0 w-5 h-5 flex items-center justify-center"><Icon className={iconColor} size={16} /></div>}
                                    <p className="text-white text-sm font-semibold truncate">{entry.message}</p>
                                </div>
                            );
                        })}
                        </div>
                    )}
                </div>

                <div ref={powerUpsRef} className="pointer-events-auto flex items-center gap-3">
                    <button
                        ref={hintButtonRef}
                        onClick={triggerHint}
                        disabled={hintInfo != null || hints === 0}
                        className={`relative w-16 h-16 flex items-center justify-center rounded-2xl font-semibold transition-all shadow-lg text-white ${
                        hints > 0
                            ? 'bg-violet-500/80 hover:bg-violet-500 active:scale-95'
                            : 'bg-black/20 text-white/50 cursor-not-allowed opacity-70'
                        } ${activePowerUp === 'hint' ? 'animate-power-up-active' : ''}`}
                        aria-label={`Kullanılabilir ${hints} ipucu`}
                    >
                        <LightbulbIcon size={32}/>
                        <span className="absolute top-0 right-0 -translate-y-1/3 translate-x-1/3 px-2 py-0.5 bg-black/50 rounded-full text-xs font-bold border-2 border-violet-400">{hints}</span>
                    </button>
                    <button
                        ref={timeShiftButtonRef}
                        onClick={triggerTimeShift}
                        disabled={isTimeShiftActive || timeShifts === 0}
                        className={`relative w-16 h-16 flex items-center justify-center rounded-2xl font-semibold transition-all shadow-lg text-white ${
                            timeShifts > 0
                            ? 'bg-sky-500/80 hover:bg-sky-500 active:scale-95'
                            : 'bg-black/20 text-white/50 cursor-not-allowed opacity-70'
                        } ${activePowerUp === 'timeShift' ? 'animate-power-up-active' : ''}`}
                        aria-label={`Kullanılabilir ${timeShifts} zaman kaydırma`}
                    >
                        <HourglassIcon size={32}/>
                        <span className="absolute top-0 right-0 -translate-y-1/3 translate-x-1/3 px-2 py-0.5 bg-black/50 rounded-full text-xs font-bold border-2 border-sky-400">{timeShifts}</span>
                    </button>
                    <button
                        ref={solverButtonRef}
                        onClick={triggerSolverPiece}
                        disabled={solvingInfo != null || hintInfo != null || solverPieces === 0 || availableBlocks.length === 0}
                        className={`relative w-16 h-16 flex items-center justify-center rounded-2xl font-semibold transition-all shadow-lg text-white ${
                            solverPieces > 0
                            ? 'bg-teal-500/80 hover:bg-teal-500 active:scale-95'
                            : 'bg-black/20 text-white/50 cursor-not-allowed opacity-70'
                        } ${activePowerUp === 'solver' ? 'animate-power-up-active' : ''}`}
                        aria-label={`Kullanılabilir ${solverPieces} çözücü parça`}
                    >
                        <WandIcon size={32}/>
                        <span className="absolute top-0 right-0 -translate-y-1/3 translate-x-1/3 px-2 py-0.5 bg-black/50 rounded-full text-xs font-bold border-2 border-teal-400">{solverPieces}</span>
                    </button>
                </div>
            </div>
          </div>
          
          <div 
            className="w-full lg:w-80 flex-shrink-0 bg-black/10 backdrop-blur-2xl rounded-2xl border border-white/20 shadow-xl p-4 sm:p-6 flex flex-col"
            onDrop={handlePaletteDrop}
            onDragOver={handlePaletteDragOver}
          >
            <h2 className="text-xl font-bold text-white mb-4 text-center flex-shrink-0">Bloklar ({availableBlocks.length})</h2>
            <div ref={paletteRef} className="flex-grow min-h-0 flex lg:flex-col gap-4 overflow-auto scrollbar-hide p-1">
              {availableBlocks.map((block, index) => (
                <DraggableBlock 
                  key={block.id} 
                  block={block} 
                  onRotate={handleRotate}
                  onFlip={handleFlip}
                  onDragStart={(offsetX, offsetY) => handleDragStart(block, offsetX, offsetY, 'palette')}
                  onDragEnd={handleDragEnd}
                  isHinted={block.id === hintInfo?.blockId}
                  isSolving={block.id === solvingInfo?.blockId}
                  ref={index === 0 ? firstBlockRef : undefined}
                />
              ))}
              {availableBlocks.length === 0 && filledGridCells !== totalGridCells && (
                <p className="text-white/70 text-center text-sm p-4">Tüm bloklar yerleştirildi!</p>
              )}
            </div>
          </div>
        </div>
      {isTutorialActive && (
        <TutorialOverlay
            onNext={handleTutorialNext}
            onClose={handleTutorialClose}
            stepIndex={tutorialStep}
            onSimulateAction={handleSimulateAction}
            targets={tutorialTargets}
        />
      )}
      {isPaused && (
        <PauseModal 
            onResume={handleResume}
            onExit={onBack}
        />
      )}
    </div>
  );
};

export default GameScreen;