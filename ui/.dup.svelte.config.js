import preprocess from 'svelte-preprocess';
import { optimizeCarbonImports } from 'carbon-components-svelte/preprocess/index.js';
import adapter from '@sveltejs/adapter-static';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  // Consult https://github.com/sveltejs/svelte-preprocess
  // for more information about preprocessors
  preprocess: [preprocess(), optimizeCarbonImports()],
  kit: {
    // hydrate the <div id="svelte"> element in src/app.html
    target: '#svelte',
    files: { lib: './src/lib' },
    vite: {
      server: {
        proxy: {
          '^/~landscape/.*': {
            target: 'http://localhost:8080/',
            changeOrigin: true
          },
          '^/~/.*': {
            target: 'http://localhost:8080/',
            changeOrigin: true
          },
          '^/spider/.*': {
            target: 'http://localhost:8080/',
            changeOrigin: true
          }
        },
        cors: true
      }
    },
    paths: { base: '/~canvas' },
    ssr: false,
    adapter: adapter({
      pages: 'out'
    })
    // adapter: adapter({
    //   // default options are shown
    //   pages: 'build',
    //   assets: 'build',
    //   fallback: null
    // })
  }
};

export default config;
