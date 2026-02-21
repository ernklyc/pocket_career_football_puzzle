import React from 'react';

export interface ParticleEvent {
  id: number;
  x: number; // center x
  y: number; // center y
  color?: string; // used for burst
  type: 'burst' | 'confetti';
}

interface ParticleSystemProps {
  particles: ParticleEvent[];
}

const Particle: React.FC<{ particle: ParticleEvent }> = ({ particle }) => {
    if (particle.type === 'burst') {
        // Create a cluster of 10 particles for a burst effect
        return (
            <>
                {Array.from({ length: 10 }).map((_, i) => {
                    const style: React.CSSProperties = {
                        left: `${particle.x}px`,
                        top: `${particle.y}px`,
                        backgroundColor: particle.color || '#ffffff',
                        // @ts-ignore - CSS custom properties for animation
                        '--random-x': Math.random(),
                        '--random-y': Math.random(),
                    };
                    return (
                        <div
                            key={`${particle.id}-${i}`}
                            className="absolute w-2 h-2 rounded-full animate-particle-burst"
                            style={style}
                        />
                    )
                })}
            </>
        )
    }

    if (particle.type === 'confetti') {
        // Create a shower of 60 confetti pieces from the top of the container
        return (
             <>
                {Array.from({ length: 60 }).map((_, i) => {
                    const colors = ['#38bdf8', '#fbbf24', '#4ade80', '#f472b6', '#a78bfa', '#ffffff'];
                    const size = Math.random() * 8 + 4; // 4px to 12px
                    const isCircle = Math.random() > 0.8;
                    const xSwing = (Math.random() - 0.5) * 80;

                    const style: React.CSSProperties = {
                        left: `${Math.random() * 100}%`,
                        top: '-20px',
                        width: `${size}px`,
                        height: isCircle ? `${size}px` : `${size * 0.7}px`,
                        backgroundColor: colors[Math.floor(Math.random() * colors.length)],
                        animationDelay: `${Math.random() * 0.5}s`,
                        animationDuration: `${Math.random() * 2 + 3}s`,
                         // @ts-ignore - CSS custom properties for animation
                        '--r-start': `${Math.random() * 360}deg`,
                        '--r-1': `${Math.random() * 360}deg`,
                        '--r-2': `${Math.random() * 360}deg`,
                        '--r-3': `${Math.random() * 360}deg`,
                        '--r-4': `${Math.random() * 360}deg`,
                        '--r-end': `${Math.random() * 720}deg`,
                        '--x-swing-1': `${xSwing}px`,
                        '--x-swing-2': `${-xSwing}px`,
                        '--x-end': `${(Math.random() - 0.5) * xSwing * 2}px`,
                    };
                    return (
                        <div
                            key={`${particle.id}-${i}`}
                            className={`absolute ${isCircle ? 'rounded-full' : ''} animate-confetti`}
                            style={style}
                        />
                    )
                })}
            </>
        )
    }

    return null;
};

const ParticleSystem: React.FC<ParticleSystemProps> = ({ particles }) => {
  return (
    <div className="absolute inset-0 pointer-events-none overflow-hidden z-[55]">
      {particles.map(p => <Particle key={p.id} particle={p} />)}
    </div>
  );
};

export default ParticleSystem;