import '../styles/tokens.css'
import '../styles/tema-escuro.css' // antes dos ajustes: o alto contraste também vale no escuro
import '../styles/ajustes.css'
import '../styles/animacoes.css'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from '../components/App.vue'
import aparecer from '../directives/aparecer.js'
import router from '../router'
import { useAjustesStore } from '../stores/ajustes.js'
import { useAuthStore } from '../stores/auth.js'

const app = createApp(App).use(createPinia())
app.directive('aparecer', aparecer) // v-aparecer: revelar ao rolar (directives/aparecer.js)
useAjustesStore().iniciar() // aplica os ajustes de leitura salvos antes de mostrar a página

// A guarda do router precisa saber quem está logado antes da primeira navegação (senão o F5 desloga na tela)
const auth = useAuthStore()
await auth.carregar()
app.use(router)

// Outra aba entrou ou saiu (ou a sessão expirou): ajusta a tela que está aberta aqui
auth.sincronizarAbas(() => {
  const { meta } = router.currentRoute.value
  if (meta.logada && !auth.usuario) router.push('/entrar')
  else if (meta.visitante && auth.usuario) router.push(auth.inicio) // leitor: minhas leituras; admin: relatórios
})

app.mount('#vue-app')
