
import { useCallback } from 'react';
import { useSettings } from '../contexts/SettingsContext';

const isHapticsSupported = typeof window !== 'undefined' && 'vibrate' in navigator;

export const useHaptics = () => {
  const { settings } = useSettings();

  const vibrate = useCallback((pattern: VibratePattern) => {
    if (settings.haptics && isHapticsSupported) {
      navigator.vibrate(pattern);
    }
  }, [settings.haptics]);

  const vibrateClick = useCallback(() => vibrate(20), [vibrate]);
  const vibrateSuccess = useCallback(() => vibrate(50), [vibrate]);
  const vibrateFailure = useCallback(() => vibrate([75, 50, 75]), [vibrate]);

  return { vibrateClick, vibrateSuccess, vibrateFailure, isHapticsSupported };
};
