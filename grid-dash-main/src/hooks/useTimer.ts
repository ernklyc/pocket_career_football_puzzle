import { useState, useRef, useCallback } from 'react';

const useTimer = () => {
  const [time, setTime] = useState(0);
  const intervalRef = useRef<number | null>(null);
  const speedRef = useRef<number>(1); // 1 is normal speed

  const stopTimer = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  }, []);

  const startTimer = useCallback(() => {
    if (intervalRef.current !== null) return;
    intervalRef.current = window.setInterval(() => {
      setTime(prevTime => prevTime + 1);
    }, 1000 / speedRef.current);
  }, []);

  const setSpeed = useCallback((newSpeed: number) => {
    if (speedRef.current !== newSpeed) {
      speedRef.current = newSpeed;
      // Restart the timer with the new speed
      stopTimer();
      startTimer();
    }
  }, [startTimer, stopTimer]);

  const resetTimer = useCallback(() => {
    stopTimer();
    setTime(0);
    speedRef.current = 1; // Reset speed on new level
    startTimer();
  }, [stopTimer, startTimer]);

  return { time, startTimer, stopTimer, resetTimer, setSpeed };
};

export default useTimer;