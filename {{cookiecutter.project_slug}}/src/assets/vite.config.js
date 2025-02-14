const path = require('path');
const { defineConfig } = require('vite');

module.exports = defineConfig({
  root: path.resolve(__dirname),
  base: "/static/",
  cacheDir: ".vite",
  build: {
    outDir: path.resolve(__dirname, "dist"),
    manifest: true,
    rollupOptions: {
      input: {
        'index': path.resolve(__dirname, 'js/index.js'),
      }
    }
  },
  server: {
    origin: 'http://localhost:5173',
    watch: {
      ignored: [
        '**/.vite/**',
        '**/__pycache__/**',
        '**/*.py',
        '**/*.pyc',
        '**/.venv/**',
        '**/.direnv/**',
        '**/.devenv/**',
        '**/.mypy_cache/**',
        '**/media/**',
        '**/static/**',
        '**/node_modules/**',
        '**/tests/**'
      ],
    },
  },
  resolve: {
    // Preserve node_modules symlink
    preserveSymlinks: true
  },
});
