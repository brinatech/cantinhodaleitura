// Favoritar/desfavoritar a partir de qualquer tela (HU-12 Task 3).
// Usado pelo BotaoFavorito (página do livro) e pelo coração do CardLivro (acervo).
// Visitante ou sessão que expirou vai para o login e volta para a página atual (?redirect=).
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth.js'
import { useFavoritosStore } from '../stores/favoritos.js'

export function useFavoritar() {
  const rota = useRoute()
  const roteador = useRouter()
  const auth = useAuthStore()
  const favoritos = useFavoritosStore()

  const erro = ref('') // mensagem para mostrar na tela
  const aviso = ref('') // confirmação lida pelo leitor de tela (role="status")

  const irParaLogin = () => roteador.push({ path: '/entrar', query: { redirect: rota.fullPath } })

  // Sem a lista, o coração apareceria vazio mesmo para um livro favorito
  onMounted(() => {
    if (auth.usuario) favoritos.carregar().catch(() => {})
  })

  async function alternar(livroId, titulo) {
    erro.value = ''
    aviso.value = ''
    if (!auth.usuario) return irParaLogin()

    const eraFavorito = favoritos.ehFavorito(livroId)
    try {
      const ficouFavorito = await favoritos.alternar(livroId)
      aviso.value = ficouFavorito ? `${titulo} foi adicionado aos favoritos.` : `${titulo} saiu dos favoritos.`
    } catch (falha) {
      if (falha.status === 401) {
        // A sessão expirou: atualiza quem está logado e pede o login de novo
        await auth.carregar()
        return irParaLogin()
      }
      erro.value = eraFavorito
        ? `Não foi possível tirar ${titulo} dos favoritos. Tente de novo.`
        : `Não foi possível favoritar ${titulo}. Tente de novo.`
    }
  }

  return {
    alternar,
    erro,
    aviso,
    ehFavorito: (livroId) => favoritos.ehFavorito(livroId),
    estaPendente: (livroId) => favoritos.estaPendente(livroId),
  }
}
