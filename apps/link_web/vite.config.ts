import { defineConfig } from 'vite';

// Relative base works for GitHub Pages subpath and phone-served HTTP root.
export default defineConfig({
  base: './',
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  },
});
