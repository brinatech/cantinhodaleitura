import { defineStore } from 'pinia'
import * as authService from '../services/authService.js'

// Avisa as outras abas do navegador quando alguém entra ou sai (o cookie de sessão é um só)
const canal = typeof BroadcastChannel === 'undefined' ? null : new BroadcastChannel('cantinho:auth')

export const useAuthStore = defineStore('auth', {
  state: () => ({ usuario: null }),
  getters: {
    // Só conveniência de tela: quem protege as ações de administração é o Rails (403)
    ehAdministrador: (state) => state.usuario?.tipo_usuario === 'administrador',
    // Página inicial de cada perfil (um login só; o perfil vem da conta):
    // o administrador cai nos Relatórios, o leitor nas Minhas leituras
    inicio() {
      return this.ehAdministrador ? '/admin/relatorios' : '/minhas-leituras'
    },
  },
  actions: {
    // Pergunta ao servidor quem está logado. Sem rede, fica como estava.
    async carregar() {
      try {
        this.usuario = await authService.usuarioAtual()
      } catch {
        /* servidor fora do ar: mantém o estado atual */
      }
    },
    async entrar(email, senha) {
      this.usuario = await authService.entrar(email, senha)
      canal?.postMessage('mudou')
    },
    // O cadastro não abre sessão sozinho: entra logo em seguida com os mesmos dados
    async cadastrar(dados) {
      await authService.cadastrar(dados)
      await this.entrar(dados.email, dados.senha)
    },
    async sair() {
      try {
        await authService.sair()
      } finally {
        this.usuario = null
        canal?.postMessage('mudou')
      }
    },
    // A sessão já acabou no servidor (ex.: a pessoa excluiu a conta): só esquece aqui e avisa as outras abas
    esquecer() {
      this.usuario = null
      canal?.postMessage('mudou')
    },
    // Outras abas: quando uma entra ou sai, esta revalida. Voltar para a aba também revalida
    // (sessão que expirou). "aoMudar" decide o que fazer com a tela aberta.
    sincronizarAbas(aoMudar) {
      const revalidar = () => this.carregar().then(aoMudar)
      if (canal) canal.onmessage = revalidar
      document.addEventListener('visibilitychange', () => {
        if (document.visibilityState === 'visible') revalidar()
      })
    },
  },
})
