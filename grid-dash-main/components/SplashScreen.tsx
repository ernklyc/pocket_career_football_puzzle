import React from 'react';

const SplashScreen: React.FC = () => {
    return (
        <div className="relative flex flex-col items-center justify-center h-[100svh] p-4 text-center bg-background overflow-hidden animate-splash-wrapper-fade-out">
            <div className="absolute inset-0 bg-gradient-to-br from-sky-400 via-blue-500 to-indigo-600"></div>
            <div className="relative">
                <div className="flex items-center justify-center overflow-hidden">
                    <h1 
                        className="text-7xl md:text-8xl font-black text-white leading-none animate-splash-grid"
                        style={{ textShadow: '0 4px 15px rgba(0,0,0,0.1)' }}
                    >
                        Grid
                    </h1>
                     <h1 
                        className="text-7xl md:text-8xl font-black text-white leading-none animate-splash-dash ml-4"
                        style={{ textShadow: '0 4px 15px rgba(0,0,0,0.1)' }}
                    >
                        Dash
                    </h1>
                </div>
                <p className="text-white/80 text-lg mt-2 animate-splash-subtitle">Bir Blok Bulmaca Oyunu</p>
            </div>
        </div>
    );
};

export default SplashScreen;