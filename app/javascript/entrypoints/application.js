import '../styles/tokens.css'
import '../styles/ajustes.css'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from '../components/App.vue'
import router from '../router'
import { useAjustesStore } from '../stores/ajustes.js'
import { useAuthStore } from '../stores/auth.js'

const app = createApp(App).use(createPinia())
useAjustesStore().iniciar() // aplica os ajustes de leitura salvos antes de mostrar a página

// A guarda do router precisa saber quem está logado antes da primeira navegação (senão o F5 desloga na tela)
const auth = useAuthStore()
await auth.carregar()
app.use(router)

// Outra aba entrou ou saiu (ou a sessão expirou): ajusta a tela que está aberta aqui
auth.sincronizarAbas(() => {
  const { meta } = router.currentRoute.value
  if (meta.logada && !auth.usuario) router.push('/entrar')
  else if (meta.visitante && auth.usuario) router.push('/minhas-leituras')
})

app.mount('#vue-app')
