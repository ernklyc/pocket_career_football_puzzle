import React, { useRef, useEffect } from 'react';
import { useSettings } from '../contexts/SettingsContext';

const BackgroundMusic: React.FC = () => {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const { settings } = useSettings();
  const hasInteracted = useRef(false);

  useEffect(() => {
    // This effect runs only once to create and set up the audio element.
    const audio = new Audio('https://aistudiocdn.com/media/audio/637043a5-29b3-4f81-a882-8438127391a8.mp3');
    audio.loop = true;
    audioRef.current = audio;

    const handleInteraction = () => {
      if (hasInteracted.current || !audioRef.current) return;
      hasInteracted.current = true;
      // Try to play music if volume is on. Use the element's volume property directly
      // to avoid issues with stale closures on the 'settings' object.
      if (audioRef.current.paused && audioRef.current.volume > 0) {
        audioRef.current.play().catch(e => console.log("Music will play after user interaction."));
      }
      // Clean up listeners after first interaction
      cleanup();
    };

    const cleanup = () => {
      window.removeEventListener('click', handleInteraction);
      window.removeEventListener('touchstart', handleInteraction);
      window.removeEventListener('keydown', handleInteraction);
    };

    // Listen for any interaction to enable audio
    window.addEventListener('click', handleInteraction);
    window.addEventListener('touchstart', handleInteraction);
    window.addEventListener('keydown', handleInteraction);

    return () => {
      // Cleanup on component unmount
      cleanup();
      audioRef.current?.pause();
      audioRef.current = null;
    };
  }, []); // Empty dependency array is correct here to prevent re-adding listeners.

  useEffect(() => {
    // This effect runs whenever musicVolume changes
    const audio = audioRef.current;
    if (audio) {
      audio.volume = settings.musicVolume;
      if (settings.musicVolume > 0 && hasInteracted.current && audio.paused) {
        audio.play().catch(e => console.error("Error playing music:", e));
      } else if (settings.musicVolume === 0 && !audio.paused) {
        audio.pause();
      }
    }
  }, [settings.musicVolume]);

  return null; // This component does not render any visible elements
};

export default BackgroundMusic;