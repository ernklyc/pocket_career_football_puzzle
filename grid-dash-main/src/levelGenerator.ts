
import type { Level, Block, Shape } from './types';
import { BLOCKS_DEFINITIONS } from './constants';

interface BlockDefinition {
  name: string;
  shape: Shape;
  color: string;
  size: number;
}

export const getLevelConfig = (levelNumber: number) => {
  const config: {
    id: number;
    levelNumber: number;
    gridSize: { rows: number; cols: number };
    blockTypes: string[];
    starThresholds: { threeStar: number; twoStar: number };
  } = {
    id: levelNumber,
    levelNumber: levelNumber,
    gridSize: { rows: 4, cols: 4 },
    blockTypes: ['O', 'I4', 'T', 'L', 'J', 'S', 'Z'],
    starThresholds: { threeStar: 0, twoStar: 0 },
  };
  
  if (levelNumber === 1) { 
    config.gridSize = { rows: 4, cols: 2 };
    config.blockTypes = ['L', 'L'];
  } else if (levelNumber === 2) {
    config.gridSize = { rows: 4, cols: 2 };
    config.blockTypes = ['O', 'O'];
  } else if (levelNumber <= 4) {
    config.gridSize = { rows: 4, cols: 3 };
  } else if (levelNumber <= 7) {
    config.gridSize = { rows: 4, cols: 4 };
  } else if (levelNumber <= 11) {
    config.gridSize = { rows: 5, cols: 4 };
    config.blockTypes.push('P', 'U', 'T5');
  } else if (levelNumber <= 16) {
    config.gridSize = { rows: 5, cols: 5 };
    config.blockTypes = ['F', 'I5', 'V5', 'X', 'P', 'U', 'T5', 'W', 'Y', 'L5'];
  } else if (levelNumber <= 24) {
    config.gridSize = { rows: 6, cols: 5 };
    config.blockTypes = ['F', 'I5', 'V5', 'X', 'P', 'U', 'T5', 'W', 'Y', 'L5'];
  } else {
    const side = 6 + Math.floor((levelNumber - 25) / 5);
    let rows = Math.min(side, 9);
    let cols = Math.min(side, 8);
    if ((rows * cols) % 2 !== 0 && (rows*cols) % 5 !== 0) {
      cols += 1;
    }
    config.gridSize = { rows, cols };
    config.blockTypes.push('P', 'U', 'T5', 'F', 'I5', 'V5', 'X', 'W', 'Y', 'L5');
  }

  // Dynamically set star thresholds based on grid size
  const totalCells = config.gridSize.rows * config.gridSize.cols;
  config.starThresholds.threeStar = Math.ceil(totalCells * 1.5); // Fast
  config.starThresholds.twoStar = Math.ceil(totalCells * 3);   // Medium

  return config;
};


// Helper to rotate a shape
const rotate = (shape: Shape): Shape => {
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

// Create a pool of all possible blocks and their rotations
const createBlockPool = (blockTypes?: string[]): BlockDefinition[] => {
  const pool: BlockDefinition[] = [];
  const seenShapes = new Set<string>();
  
  const definitionsToUse = blockTypes 
    ? blockTypes.reduce((acc, key) => {
        if(BLOCKS_DEFINITIONS[key]) {
          acc[key] = BLOCKS_DEFINITIONS[key];
        }
        return acc;
      }, {} as typeof BLOCKS_DEFINITIONS)
    : BLOCKS_DEFINITIONS;


  for (const name in definitionsToUse) {
    let currentShape = definitionsToUse[name].shape;
    for (let i = 0; i < 4; i++) {
      const shapeString = JSON.stringify(currentShape);
      if (!seenShapes.has(shapeString)) {
        seenShapes.add(shapeString);
        pool.push({
          name,
          shape: currentShape,
          color: definitionsToUse[name].color,
          size: currentShape.flat().reduce((a, b) => a + b, 0),
        });
      }
      currentShape = rotate(currentShape);
    }
  }
  return pool.sort((a, b) => b.size - a.size);
};

const shuffleArray = <T>(array: T[]): T[] => {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
};

type LevelConfig = ReturnType<typeof getLevelConfig>;

export const generateLevel = (config: LevelConfig): Level => {
  const { gridSize, blockTypes } = config;

  let attempt = 0;
  while (attempt < 50) { // Try up to 50 times
      const levelBlockPool = createBlockPool(blockTypes);
      const solutionGrid: (string | null)[][] = Array.from({ length: gridSize.rows }, () => Array(gridSize.cols).fill(null));
      
      const solutionBlocks: (Block & {pos: {r: number, c: number}})[] = [];
      let blockIdCounter = 0;
      
      const canPlace = (shape: Shape, r: number, c: number) => {
        for (let i = 0; i < shape.length; i++) {
          for (let j = 0; j < shape[0].length; j++) {
            if (shape[i][j]) {
              const gridRow = r + i;
              const gridCol = c + j;
              if (
                gridRow >= gridSize.rows ||
                gridCol >= gridSize.cols ||
                solutionGrid[gridRow][gridCol] !== null
              ) {
                return false;
              }
            }
          }
        }
        return true;
      };

      const placeBlock = (def: BlockDefinition, r: number, c: number, blockId: string) => {
          for (let i = 0; i < def.shape.length; i++) {
              for (let j = 0; j < def.shape[0].length; j++) {
                  if (def.shape[i][j]) {
                      solutionGrid[r + i][c + j] = blockId;
                  }
              }
          }
      }
      
      const solve = (shuffledPool: BlockDefinition[]): boolean => {
          let r = -1, c = -1;
          for (let i = 0; i < gridSize.rows; i++) {
              for (let j = 0; j < gridSize.cols; j++) {
                  if (solutionGrid[i][j] === null) {
                      r = i;
                      c = j;
                      break;
                  }
              }
              if (r !== -1) break;
          }

          if (r === -1) return true;

          for (const blockDef of shuffledPool) {
              if (canPlace(blockDef.shape, r, c)) {
                  const blockId = `block-${config.levelNumber}-${blockIdCounter}`;
                  placeBlock(blockDef, r, c, blockId);
                  solutionBlocks.push({
                      id: blockId,
                      shape: blockDef.shape,
                      initialShape: BLOCKS_DEFINITIONS[blockDef.name].shape,
                      color: blockDef.color,
                      pos: {r, c}
                  });
                  blockIdCounter++;

                  if (solve(shuffledPool)) {
                      return true;
                  }

                  blockIdCounter--;
                  solutionBlocks.pop();
                   for (let i = 0; i < gridSize.rows; i++) {
                      for (let j = 0; j < gridSize.cols; j++) {
                          if (solutionGrid[i][j] === blockId) {
                              solutionGrid[i][j] = null;
                          }
                      }
                  }
              }
          }
          return false;
      }
      
      const shuffledLevelPool = shuffleArray(levelBlockPool);

      if (solve(shuffledLevelPool) && (gridSize.rows * gridSize.cols === solutionBlocks.reduce((sum, b) => sum + b.shape.flat().reduce((a, c) => a + c, 0), 0) )) {
          const finalSolution: Level['solution'] = {};
          const finalBlocks: Block[] = [];

          solutionBlocks.forEach(b => {
              finalSolution[b.id] = { row: b.pos.r, col: b.pos.c, shape: b.shape };
              finalBlocks.push({
                  id: b.id,
                  shape: b.initialShape,
                  initialShape: b.initialShape,
                  color: b.color,
              });
          });
          
          const gemPositions: { row: number, col: number }[] = [];
          const totalCells = gridSize.rows * gridSize.cols;
          if (totalCells > 8) { // Only add gems to non-trivial levels
            const gemCount = Math.floor(Math.random() * (totalCells / 12)) + 1;
            
            const possibleGemSpots: {row: number, col: number}[] = [];
            for(let r = 0; r < gridSize.rows; r++) {
              for(let c = 0; c < gridSize.cols; c++) {
                if (solutionGrid[r][c] !== null) {
                  possibleGemSpots.push({row: r, col: c});
                }
              }
            }

            shuffleArray(possibleGemSpots);

            for(let i = 0; i < gemCount && i < possibleGemSpots.length; i++) {
              gemPositions.push(possibleGemSpots[i]);
            }
          }

          return {
            id: config.id,
            levelNumber: config.levelNumber,
            gridSize,
            blocks: shuffleArray(finalBlocks),
            solution: finalSolution,
            starThresholds: config.starThresholds,
            gemPositions,
            blockTypes: config.blockTypes
          };
      }
      attempt++;
  }

  console.error(`Failed to generate a level for config after ${attempt} attempts:`, config);
  // Fallback to a guaranteed simple level if generation fails.
  const fallbackConfig = getLevelConfig(1);
  const fallbackBlock = {
      id: 'fallback-block-1-0',
      shape: [[1, 1], [1, 1]],
      initialShape: [[1, 1], [1, 1]],
      color: BLOCKS_DEFINITIONS['O'].color,
  };
  return {
    id: 1,
    levelNumber: 1,
    gridSize: { rows: 2, cols: 2 },
    blocks: [fallbackBlock],
    solution: { [fallbackBlock.id]: { row: 0, col: 0, shape: fallbackBlock.shape } },
    starThresholds: fallbackConfig.starThresholds,
    gemPositions: [],
    blockTypes: fallbackConfig.blockTypes,
  };
};
