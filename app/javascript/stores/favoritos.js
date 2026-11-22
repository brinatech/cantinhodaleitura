import { defineStore } from 'pinia'
import * as favoritosService from '../services/favoritosService.js'
import { useAuthStore } from './auth.js'

// Favoritos de quem está logado (HU-12 Task 3).
// A tela só muda depois que o servidor confirma: erro de rede não marca favorito falsamente.
// "donoId" guarda de quem é a lista: se alguém sai ou outra pessoa entra, a lista antiga não vale mais.
let carregando = null // pedido em andamento, para várias telas não buscarem a lista ao mesmo tempo

export const useFavoritosStore = defineStore('favoritos', {
  state: () => ({
    lista: [], // [{ livro_id, data_favorito, livro: {...} }], do mais recente ao mais antigo
    donoId: null,
    pendentes: [], // livros com POST/DELETE em andamento (evita clique duplo)
  }),
  getters: {
    // Só vale a lista do usuário logado agora
    favoritos(state) {
      const auth = useAuthStore()
      return auth.usuario && state.donoId === auth.usuario.id ? state.lista : []
    },
    ehFavorito() {
      return (livroId) => this.favoritos.some((f) => f.livro_id === Number(livroId))
    },
    estaPendente(state) {
      return (livroId) => state.pendentes.includes(Number(livroId))
    },
  },
  actions: {
    // Busca a lista uma vez por usuário. "forcar" busca de novo (ex.: abrir a página de favoritos).
    async carregar({ forcar = false } = {}) {
      const auth = useAuthStore()
      if (!auth.usuario) {
        this.limpar()
        return
      }
      if (!forcar && this.donoId === auth.usuario.id) return
      if (carregando) return carregando

      const usuarioId = auth.usuario.id
      carregando = favoritosService
        .listarFavoritos()
        .then((lista) => {
          if (useAuthStore().usuario?.id !== usuarioId) return // trocou de usuário no meio do caminho
          this.lista = lista
          this.donoId = usuarioId
        })
        .finally(() => {
          carregando = null
        })
      return carregando
    },

    // Favorita ou desfavorita. Devolve true se o livro ficou favorito.
    // Lança ErroApi (ex.: 401) para o botão decidir o que mostrar.
    async alternar(livroId) {
      const id = Number(livroId)
      if (this.estaPendente(id)) return this.ehFavorito(id)

      await this.carregar()
      this.pendentes.push(id)
      try {
        if (this.ehFavorito(id)) {
          await this.remover(id)
          return false
        }
        await this.adicionar(id)
        return true
      } finally {
        this.pendentes = this.pendentes.filter((p) => p !== id)
      }
    },

    async adicionar(livroId) {
      try {
        const favorito = await favoritosService.favoritar(livroId)
        this.lista = [favorito, ...this.lista.filter((f) => f.livro_id !== livroId)]
      } catch (erro) {
        // 409: já era favorito (favoritou em outra aba). Busca a lista certa do servidor.
        if (erro.status !== 409) throw erro
        await this.carregar({ forcar: true })
      }
    },

    async remover(livroId) {
      try {
        await favoritosService.desfavoritar(livroId)
      } catch (erro) {
        // 404: já não era favorito (tirou em outra aba). Só acerta a lista daqui.
        if (erro.status !== 404) throw erro
      }
      this.lista = this.lista.filter((f) => f.livro_id !== livroId)
    },

    limpar() {
      this.lista = []
      this.donoId = null
      this.pendentes = []
    },
  },
})
