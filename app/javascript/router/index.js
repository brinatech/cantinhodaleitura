import { createRouter, createWebHashHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import AcessoView from '../views/AcessoView.vue'
import MinhasLeiturasView from '../views/MinhasLeiturasView.vue'
import LivroDetalheView from '../views/LivroDetalheView.vue'
import AcervoView from '../views/AcervoView.vue'

// Telas que o menu e a home já apontam, mas ainda não existem.
// Quando uma tela ficar pronta, troque o component dela aqui.
const emBreve = () => import('../views/EmBreveView.vue')
const telasPendentes = [
  { path: '/sobre', titulo: 'Sobre' },
  { path: '/acessibilidade', titulo: 'Acessibilidade' },
  { path: '/esqueci-senha', titulo: 'Recuperar senha' },
  // Telas da área logada: a página provisória aparece dentro do menu lateral
  { path: '/favoritos', titulo: 'Favoritos', logada: true },
  { path: '/listas-de-leitura', titulo: 'Listas de leitura', logada: true },
  { path: '/historico', titulo: 'Histórico', logada: true },
  { path: '/meu-perfil', titulo: 'Meu perfil', logada: true },
].map(({ path, titulo, logada }) => ({ path, component: emBreve, meta: { titulo, logada } }))

// Modo hash (/#/rota): não precisa de rota no config/routes.rb do Rails.
// shortcut: trocar para createWebHistory junto com o SpaController do backend.
const routes = [
  { path: '/', component: HomeView },
  { path: '/entrar', component: AcessoView },
  { path: '/criar-conta', component: AcessoView },
  { path: '/minhas-leituras', component: MinhasLeiturasView },
  { path: '/livros/:id', component: LivroDetalheView },
  { path: '/acervo', component: AcervoView }, // busca chega pela barra de cima: /acervo?busca=...
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
