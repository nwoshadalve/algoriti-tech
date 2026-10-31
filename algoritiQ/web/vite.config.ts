/// <reference types="vitest/config" />
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { defineConfig, loadEnv } from 'vite'
import { VitePWA } from 'vite-plugin-pwa'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const rootDir = path.dirname(fileURLToPath(import.meta.url))

export default defineConfig(({ mode }) => {
  // `.env.development` is not part of process.env inside this file; read it.
  const env = loadEnv(mode, rootDir, '')
  const apiProxy = env.VITE_API_PROXY || 'https://algoritiq.local:8443'

  return {
    base: './',
    plugins: [
      react(),
      tailwindcss(),
      VitePWA({
        registerType: 'autoUpdate',
        includeAssets: [
          'favicon.ico',
          'favicon.svg',
          'favicon-16x16.png',
          'favicon-32x32.png',
          'favicon-48x48.png',
          'apple-touch-icon.png',
          'icon-192.png',
          'icon-512.png',
          'icon-maskable-512.png',
          'algoritiq-wordmark.svg',
          'algoritiq-wordmark-reversed.svg',
          'fonts/**/*',
        ],
        manifest: {
          name: 'AlgoritiQ',
          short_name: 'AlgoritiQ',
          description: 'Clinic queue dashboard for admin and doctor workflows',
          theme_color: '#0B1F3A',
          background_color: '#0B1F3A',
          display: 'standalone',
          start_url: './',
          icons: [
            { src: 'icon-192.png', sizes: '192x192', type: 'image/png' },
            { src: 'icon-512.png', sizes: '512x512', type: 'image/png' },
            {
              src: 'icon-maskable-512.png',
              sizes: '512x512',
              type: 'image/png',
              purpose: 'maskable',
            },
          ],
        },
        workbox: {
          globPatterns: ['**/*.{js,css,html,ico,svg,ttf,woff2}'],
          navigateFallback: 'index.html',
          navigateFallbackDenylist: [/^\/api\//],
        },
      }),
    ],
    resolve: {
      alias: {
        '@': path.resolve(rootDir, './src'),
      },
    },
    server: {
      port: 5173,
      proxy: {
        '/api': {
          target: apiProxy,
          changeOrigin: true,
          secure: false,
        },
      },
    },
    test: {
      environment: 'happy-dom',
      setupFiles: ['./src/test/setup.ts'],
      globals: true,
      css: true,
    },
  }
})
