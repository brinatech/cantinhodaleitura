import { createRouter, createWebHashHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import AcessoView from '../views/AcessoView.vue'
import MinhasLeiturasView from '../views/MinhasLeiturasView.vue'
import LivroDetalheView from '../views/LivroDetalheView.vue'
import AcervoView from '../views/AcervoView.vue'
import MeuPerfilView from '../views/MeuPerfilView.vue'
import AcervoPublicoView from '../views/AcervoPublicoView.vue' //importa o acervo publico
import { useAuthStore } from '../stores/auth.js'

// Telas que o menu e a home já apontam, mas ainda não existem.
// Quando uma tela ficar pronta, troque o component dela aqui.
const emBreve = () => import('../views/EmBreveView.vue')
const telasPendentes = [
  { path: '/sobre', titulo: 'Sobre' },
  // shortcut: acervo do visitante (links da home). Some quando a AcervoView escolher a moldura pelo login
  // { path: '/acervo-publico', titulo: 'Acervo' }, 
  { path: '/acessibilidade', titulo: 'Acessibilidade' },
  // Telas da área logada: a página provisória aparece dentro do menu lateral
].map(({ path, titulo, logada }) => ({ path, component: emBreve, meta: { titulo, logada } }))

// Modo hash (/#/rota): não precisa de rota no config/routes.rb do Rails.
// shortcut: trocar para createWebHistory junto com o SpaController do backend.
const routes = [
  { path: '/', component: HomeView },
  // visitante: quem já está logado não precisa destas telas (vai para as minhas leituras)
  { path: '/entrar', component: AcessoView, meta: { visitante: true } },
  { path: '/criar-conta', component: AcessoView, meta: { visitante: true } },
  { path: '/esqueci-senha', component: AcessoView },
  { path: '/redefinir-senha', component: AcessoView },
  { path: '/minhas-leituras', component: MinhasLeiturasView, meta: { logada: true } },
  { path: '/meu-perfil', component: MeuPerfilView, meta: { logada: true } },
  { path: '/favoritos', component: () => import('../views/FavoritosView.vue'), meta: { logada: true } },
  { path: '/historico', component: () => import('../views/HistoricoView.vue'), meta: { logada: true } },
  { path: '/listas-de-leitura', component: () => import('../views/ListasLeituraView.vue'), meta: { logada: true } },
  { path: '/listas-de-leitura/:id', component: () => import('../views/ListaDetalheView.vue'), meta: { logada: true } },
  { path: '/livros/:id', name: 'livro-detalhe', component: LivroDetalheView },
  // Mesma tela, na moldura da área logada (menu lateral). O acervo logado (/acervo) leva a esta.
  { path: '/acervo/:id', name: 'livro-detalhe-logado', component: LivroDetalheView, meta: { logada: true } },
  // Leitura do livro (HU-10 Task 4): a do visitante e a da área logada, como o detalhe
  { path: '/livros/:id/ler', name: 'livro-leitura', component: () => import('../views/LeitorLivroView.vue') },
  {
    path: '/acervo/:id/ler',
    name: 'livro-leitura-logado',
    component: () => import('../views/LeitorLivroView.vue'),
    meta: { logada: true },
  },
  { path: '/acervo', component: AcervoView, meta: { logada: true } }, // busca chega pela barra de cima: /acervo?busca=...
  { path: '/acervo-publico', component: AcervoPublicoView }, //rota para chamar o acero publico
  // Área admin (provisória até a tela admin de livros, HU-07 Task 4)
  {
    path: '/admin/livros/:id/classificacoes',
    component: () => import('../views/admin/ClassificacoesLivroView.vue'),
    meta: { logada: true, admin: true },
  },
    {
    path: '/admin/livros',
    component: () => import('../views/admin/LivrosView.vue'),
    meta: { logada: true, admin: true },
  },
  {
    path: '/admin/categorias',
    component: () => import('../views/admin/CategoriasView.vue'),
    meta: { logada: true, admin: true },
  },
  {
    path: '/admin/relatorios',
    component: () => import('../views/admin/RelatoriosView.vue'),
    meta: { logada: true, admin: true },
  },
  ...telasPendentes,
  // Só em desenvolvimento: no build de produção o import abaixo é descartado
  ...(import.meta.env.DEV
    ? [{ path: '/design-system', component: () => import('../views/DesignSystemView.vue') }]
    : []),
  // Endereço que não existe: a mesma página provisória, sem título, vira "não encontrada"
  { path: '/:pathMatch(.*)*', component: emBreve },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 }), // cada página nova abre no topo
})

// Área logada exige sessão: sem ela, vai para o login e volta para cá depois (?redirect=)
router.beforeEach((para) => {
  const { usuario } = useAuthStore()
  if (para.meta.logada && !usuario) return { path: '/entrar', query: { redirect: para.fullPath } }
  if (para.meta.visitante && usuario) return '/minhas-leituras'
  // Só conveniência: quem protege de verdade é o Rails (403 para quem não é administrador)
  if (para.meta.admin && usuario?.tipo_usuario !== 'administrador') return '/minhas-leituras'
})

export default router
