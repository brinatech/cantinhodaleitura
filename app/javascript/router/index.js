import { createRouter, createWebHashHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import AcessoView from '../views/AcessoView.vue'
import MinhasLeiturasView from '../views/MinhasLeiturasView.vue'
import LivroDetalheView from '../views/LivroDetalheView.vue'
import AcervoView from '../views/AcervoView.vue'
import MeuPerfilView from '../views/MeuPerfilView.vue'
import AcervoPublicoView from '../views/AcervoPublicoView.vue' //importa o acervo publico
import { useAuthStore } from '../stores/auth.js'

// Modo hash (/#/rota): não precisa de rota no config/routes.rb do Rails.
// shortcut: trocar para createWebHistory junto com o SpaController do backend.
const routes = [
  { path: '/', component: HomeView },
  // visitante: quem já está logado não precisa destas telas (vai para as minhas leituras)
  { path: '/entrar', component: AcessoView, meta: { visitante: true } },
  { path: '/criar-conta', component: AcessoView, meta: { visitante: true } },
  { path: '/esqueci-senha', component: AcessoView },
  { path: '/redefinir-senha', component: AcessoView },
  // leitor: telas pessoais do leitor. O administrador não tem essas ferramentas (vai para a área dele)
  { path: '/minhas-leituras', component: MinhasLeiturasView, meta: { logada: true, leitor: true } },
  { path: '/meu-perfil', component: MeuPerfilView, meta: { logada: true } },
  { path: '/favoritos', component: () => import('../views/FavoritosView.vue'), meta: { logada: true, leitor: true } },
  { path: '/historico', component: () => import('../views/HistoricoView.vue'), meta: { logada: true, leitor: true } },
  { path: '/listas-de-leitura', component: () => import('../views/ListasLeituraView.vue'), meta: { logada: true, leitor: true } },
  { path: '/listas-de-leitura/:id', component: () => import('../views/ListaDetalheView.vue'), meta: { logada: true, leitor: true } },
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
  { path: '/acervo', component: AcervoView, meta: { logada: true, leitor: true } }, // busca chega pela barra de cima: /acervo?busca=...
  { path: '/acervo-publico', component: AcervoPublicoView }, //rota para chamar o acero publico
  { path: '/sobre', component: () => import('../views/SobreView.vue'), meta: { titulo: 'Sobre' } },
  { path: '/acessibilidade', component: () => import('../views/AcessibilidadeView.vue'), meta: { titulo: 'Acessibilidade' } },
  // Área do administrador. A página inicial dele é Relatórios (stores/auth.js, "inicio").
  // O livro aberto daqui usa o mesmo detalhe da área logada (/acervo/:id), sem as ferramentas de leitor.
  {
    path: '/admin/acervo',
    component: AcervoView, // a mesma estante do leitor: o admin confere capas e títulos como o leitor vê
    meta: { logada: true, admin: true },
  },
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
  // Só em desenvolvimento: no build de produção o import abaixo é descartado
  ...(import.meta.env.DEV
    ? [{ path: '/design-system', component: () => import('../views/DesignSystemView.vue') }]
    : []),
  // Endereço que não existe
  { path: '/:pathMatch(.*)*', component: () => import('../views/NaoEncontradaView.vue'), meta: { titulo: 'Página não encontrada' } },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 }), // cada página nova abre no topo
})

// Área logada exige sessão: sem ela, vai para o login e volta para cá depois (?redirect=)
// Cada perfil tem a sua área: o leitor não entra na administração, e o administrador não usa as
// ferramentas pessoais do leitor (favoritos, listas...). Só conveniência: quem protege de verdade
// é o Rails (403 para quem não é administrador).
router.beforeEach((para) => {
  const auth = useAuthStore()
  if (para.meta.logada && !auth.usuario) return { path: '/entrar', query: { redirect: para.fullPath } }
  if (para.meta.visitante && auth.usuario) return auth.inicio
  if (para.meta.admin && !auth.ehAdministrador) return '/minhas-leituras'
  if (para.meta.leitor && auth.ehAdministrador) {
    // O acervo do admin é o /admin/acervo (a busca da barra de cima vai junto)
    return para.path === '/acervo' ? { path: '/admin/acervo', query: para.query } : auth.inicio
  }
})

export default router
