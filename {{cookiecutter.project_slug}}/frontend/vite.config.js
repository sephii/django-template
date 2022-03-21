const path = require('path');
const { defineConfig } = require('vite');

module.exports = defineConfig({
  base: "/static/",
  cacheDir: ".vite",
  build: {
    outDir: "dist",
    manifest: true,
    rollupOptions: {
      input: {
        'index': path.resolve(__dirname, 'js/index.js'),
      }
    }
  }
});
