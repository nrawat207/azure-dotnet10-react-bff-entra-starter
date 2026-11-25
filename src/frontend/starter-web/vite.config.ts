import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
export default defineConfig({ plugins: [react()], server: { port: 5173, proxy: { '/bff': { target: 'https://localhost:7043', secure: false }, '/api': { target: 'https://localhost:7043', secure: false } } }, test: { environment: 'jsdom' } });
