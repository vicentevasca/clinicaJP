import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

import App from './App.vue'
import router from './router'

import './assets/styles/main.css'
import './assets/styles/animations.css'

// GSAP plugins
gsap.registerPlugin(ScrollTrigger)

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')

// Registrar service worker PWA
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch(() => {
      // PWA registration failed — non-critical
    })
  })
}
