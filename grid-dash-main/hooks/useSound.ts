import { useCallback } from 'react';
import { useSettings } from '../contexts/SettingsContext';

type SoundEffect = 
  | 'place-success' 
  | 'place-fail' 
  | 'rotate' 
  | 'level-complete' 
  | 'ui-click'
  | 'gem-collect'
  | 'purchase-success'
  | 'purchase-fail';

const soundFiles: Record<SoundEffect, string> = {
  'place-success': 'https://aistudiocdn.com/media/audio/5e53631a-555e-445a-8a58-3d172e909569.mp3',
  'place-fail': 'https://aistudiocdn.com/media/audio/a1170b6a-2d4e-4148-8a8b-3023953e5e6e.mp3',
  'rotate': 'https://aistudiocdn.com/media/audio/7562868c-e8a0-4a8e-8a21-be337a77a11f.mp3',
  'level-complete': 'https://aistudiocdn.com/media/audio/b841de1f-61d0-4355-8848-f14d8f288f36.mp3',
  'ui-click': 'https://aistudiocdn.com/media/audio/17a7314b-57f9-4670-845b-96c21a4f009f.mp3',
  'gem-collect': 'https://aistudiocdn.com/media/audio/80823b18-d703-4f4a-bb0a-a3287c2f0f43.mp3',
  'purchase-success': 'https://aistudiocdn.com/media/audio/6e4312f5-b827-41a4-99b3-8557c667e4d2.mp3',
  'purchase-fail': 'https://aistudiocdn.com/media/audio/a1170b6a-2d4e-4148-8a8b-3023953e5e6e.mp3',
};

// Preload audio elements
const audioObjects = Object.entries(soundFiles).reduce((acc, [key, src]) => {
  if (typeof Audio !== 'undefined') {
    acc[key as SoundEffect] = new Audio(src);
  }
  return acc;
}, {} as Record<SoundEffect, HTMLAudioElement>);

export const useSound = () => {
  const { settings } = useSettings();

  const playSound = useCallback((sound: SoundEffect) => {
    if (settings.soundVolume > 0 && audioObjects[sound]) {
      const audio = audioObjects[sound];
      audio.volume = settings.soundVolume;
      audio.currentTime = 0;
      audio.play().catch(err => console.warn(`Sound play failed for ${sound}: ${err.message}`));
    }
  }, [settings.soundVolume]);

  return { playSound };
};