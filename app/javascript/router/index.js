import { createRouter, createWebHashHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

// Telas que o menu e a home já apontam, mas ainda não existem.
// Quando uma tela ficar pronta, troque o component dela aqui.
const emBreve = () => import('../views/EmBreveView.vue')
const telasPendentes = [
  { path: '/sobre', titulo: 'Sobre' },
  { path: '/acervo', titulo: 'Acervo' },
  { path: '/acessibilidade', titulo: 'Acessibilidade' },
  { path: '/entrar', titulo: 'Entrar' },
  { path: '/minhas-leituras', titulo: 'Minhas leituras' },
].map(({ path, titulo }) => ({ path, component: emBreve, meta: { titulo } }))

// Modo hash (/#/rota): não precisa de rota no config/routes.rb do Rails.
// shortcut: trocar para createWebHistory junto com o SpaController do backend.
const routes = [
  { path: '/', component: HomeView },
  ...telasPendentes,
  // Só em desenvolvimento: no build de produção o import abaixo é descartado
  ...(import.meta.env.DEV
    ? [{ path: '/design-system', component: () => import('../views/DesignSystemView.vue') }]
    : []),
  // Endereço que não existe: a mesma página provisória, sem título, vira "não encontrada"
  { path: '/:pathMatch(.*)*', component: emBreve },
]

export default createRouter({
  history: createWebHashHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 }), // cada página nova abre no topo
})
