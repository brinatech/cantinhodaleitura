import '../styles/tokens.css'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from '../components/App.vue'
import router from '../router'

createApp(App).use(createPinia()).use(router).mount('#vue-app')
