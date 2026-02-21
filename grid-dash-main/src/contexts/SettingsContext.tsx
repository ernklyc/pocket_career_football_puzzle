import React, { createContext, useContext, useCallback } from 'react';
import type { Settings, PlayerProgress } from '../types';

interface SettingsContextType {
  settings: Settings;
  updateSettings: (newSettings: Partial<Settings>) => void;
}

const SettingsContext = createContext<SettingsContextType | undefined>(undefined);

interface SettingsProviderProps {
  progress: PlayerProgress;
  setProgress: React.Dispatch<React.SetStateAction<PlayerProgress>>;
  children: React.ReactNode;
}

export const SettingsProvider: React.FC<SettingsProviderProps> = ({ progress, setProgress, children }) => {
  const updateSettings = useCallback((newSettings: Partial<Settings>) => {
    setProgress(prev => ({
      ...prev,
      settings: {
        ...prev.settings,
        ...newSettings,
      },
    }));
  }, [setProgress]);

  return (
    <SettingsContext.Provider value={{ settings: progress.settings, updateSettings }}>
      {children}
    </SettingsContext.Provider>
  );
};

export const useSettings = (): SettingsContextType => {
  const context = useContext(SettingsContext);
  if (context === undefined) {
    throw new Error('useSettings must be used within a SettingsProvider');
  }
  return context;
};