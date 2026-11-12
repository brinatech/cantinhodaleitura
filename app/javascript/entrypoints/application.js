import '../styles/tokens.css'
import '../styles/ajustes.css'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from '../components/App.vue'
import router from '../router'
import { useAjustesStore } from '../stores/ajustes.js'

const app = createApp(App).use(createPinia()).use(router)
useAjustesStore().iniciar() // aplica os ajustes de leitura salvos antes de mostrar a página
app.mount('#vue-app')
