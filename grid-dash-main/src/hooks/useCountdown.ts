
import { useState, useEffect } from 'react';

const calculateRemainingTime = (targetTimestamp: number) => {
    const now = Date.now();
    const difference = targetTimestamp - now;
    if (difference <= 0) {
        return { total: 0, days: 0, hours: 0, minutes: 0, seconds: 0, isFinished: true };
    }
    const total = Math.floor(difference / 1000);
    const seconds = Math.floor(total % 60);
    const minutes = Math.floor((total / 60) % 60);
    const hours = Math.floor((total / 3600) % 24);
    const days = Math.floor(total / 86400);
    return { total, days, hours, minutes, seconds, isFinished: false };
};

const useCountdown = (targetTimestamp: number) => {
    const [timeLeft, setTimeLeft] = useState(() => calculateRemainingTime(targetTimestamp));

    useEffect(() => {
        const initialState = calculateRemainingTime(targetTimestamp);
        setTimeLeft(initialState);
        
        if (initialState.isFinished) return;

        const interval = setInterval(() => {
            const newTimeLeft = calculateRemainingTime(targetTimestamp);
            setTimeLeft(newTimeLeft);
            if (newTimeLeft.isFinished) {
              clearInterval(interval);
            }
        }, 1000);

        return () => clearInterval(interval);
    }, [targetTimestamp]);
    
    const { days, hours, minutes, seconds } = timeLeft;
    const totalHours = days * 24 + hours;
    const formattedTime = `${String(totalHours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

    return { ...timeLeft, formattedTime };
};

export default useCountdown;
