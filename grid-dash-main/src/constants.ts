import type { Block, Level } from './types';

export const CELL_SIZE_REM = 2.25;
export const CELL_GAP_PX = 1;

export const BLOCKS_DEFINITIONS: Record<string, { shape: number[][]; color: string }> = {
  // 4 cells
  I4: { shape: [[1, 1, 1, 1]], color: 'bg-sky-500 border-2 border-solid border-t-sky-300 border-l-sky-300 border-b-sky-700 border-r-sky-700' },
  O: { shape: [[1, 1], [1, 1]], color: 'bg-amber-400 border-2 border-solid border-t-amber-200 border-l-amber-200 border-b-amber-600 border-r-amber-600' },
  T: { shape: [[0, 1, 0], [1, 1, 1]], color: 'bg-purple-500 border-2 border-solid border-t-purple-300 border-l-purple-300 border-b-purple-700 border-r-purple-700' },
  L: { shape: [[1, 0], [1, 0], [1, 1]], color: 'bg-orange-500 border-2 border-solid border-t-orange-300 border-l-orange-300 border-b-orange-700 border-r-orange-700' },
  J: { shape: [[0, 1], [0, 1], [1, 1]], color: 'bg-blue-500 border-2 border-solid border-t-blue-300 border-l-blue-300 border-b-blue-700 border-r-blue-700' },
  S: { shape: [[0, 1, 1], [1, 1, 0]], color: 'bg-emerald-500 border-2 border-solid border-t-emerald-300 border-l-emerald-300 border-b-emerald-700 border-r-emerald-700' },
  Z: { shape: [[1, 1, 0], [0, 1, 1]], color: 'bg-rose-500 border-2 border-solid border-t-rose-300 border-l-rose-300 border-b-rose-700 border-r-rose-700' },
  // 5 cells
  F: { shape: [[0, 1, 1], [1, 1, 0], [0, 1, 0]], color: 'bg-green-500 border-2 border-solid border-t-green-300 border-l-green-300 border-b-green-700 border-r-green-700' },
  P: { shape: [[1, 1], [1, 1], [1, 0]], color: 'bg-red-500 border-2 border-solid border-t-red-300 border-l-red-300 border-b-red-700 border-r-red-700' },
  U: { shape: [[1, 0, 1], [1, 1, 1]], color: 'bg-indigo-500 border-2 border-solid border-t-indigo-300 border-l-indigo-300 border-b-indigo-700 border-r-indigo-700' },
  I5: { shape: [[1, 1, 1, 1, 1]], color: 'bg-cyan-500 border-2 border-solid border-t-cyan-300 border-l-cyan-300 border-b-cyan-700 border-r-cyan-700' },
  T5: { shape: [[1, 1, 1], [0, 1, 0]], color: 'bg-fuchsia-500 border-2 border-solid border-t-fuchsia-300 border-l-fuchsia-300 border-b-fuchsia-700 border-r-fuchsia-700' },
  V5: { shape: [[1, 0, 0], [1, 0, 0], [1, 1, 1]], color: 'bg-lime-500 border-2 border-solid border-t-lime-300 border-l-lime-300 border-b-lime-700 border-r-lime-700' },
  X: { shape: [[0, 1, 0], [1, 1, 1], [0, 1, 0]], color: 'bg-teal-500 border-2 border-solid border-t-teal-300 border-l-teal-300 border-b-teal-700 border-r-teal-700' },
  W: { shape: [[1, 0, 0], [1, 1, 0], [0, 1, 1]], color: 'bg-violet-500 border-2 border-solid border-t-violet-300 border-l-violet-300 border-b-violet-700 border-r-violet-700'},
  Y: { shape: [[1, 0], [1, 1], [1, 0], [1, 0]], color: 'bg-pink-500 border-2 border-solid border-t-pink-300 border-l-pink-300 border-b-pink-700 border-r-pink-700'},
  L5: { shape: [[1, 0], [1, 0], [1, 0], [1, 1]], color: 'bg-amber-600 border-2 border-solid border-t-amber-400 border-l-amber-400 border-b-amber-800 border-r-amber-800'},
};