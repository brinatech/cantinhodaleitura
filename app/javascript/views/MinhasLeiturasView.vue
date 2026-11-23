<!--
  Minhas leituras (Figma: "Minhas leituras · área logada"). Primeira tela do leitor:
  boas-vindas com resumo, os livros em andamento e as novidades do acervo.
  Dados reais:
  - Resumo e "Continue de onde parou": histórico de leitura (GET /api/v1/historico, HU-14), com a
    página do marcador (HU-15). "Em andamento" = progresso abaixo de 100%; "lidos" = 100%.
  - O terceiro número do Figma era "2h ouvindo", mas nada no banco guarda tempo de escuta:
    trocado pelo número de favoritos (levar à equipe).
  - Novidades: os 12 livros cadastrados mais recentemente (GET /api/v1/livros?ordem=recentes).
  As duas listas ficam numa fileira com setas (FileiraRolagem), também no celular.
  Cada parte carrega sozinha: se uma falhar, as outras continuam aparecendo.
-->
<script setup>
import { computed, onMounted, ref } from 'vue'
import LayoutLogado from '../components/layout/LayoutLogado.vue'
import Alerta from '../components/ui/Alerta.vue'
import Botao from '../components/ui/Botao.vue'
import CabecalhoSecao from '../components/ui/CabecalhoSecao.vue'
import CardContinuarLendo from '../components/ui/CardContinuarLendo.vue'
import CardLivro from '../components/ui/CardLivro.vue'
import DestaquePalavra from '../components/ui/DestaquePalavra.vue'
import EstadoVazio from '../components/ui/EstadoVazio.vue'
import FileiraRolagem from '../components/ui/FileiraRolagem.vue'
import Icone from '../components/ui/Icone.vue'
import IconeBolha from '../components/ui/IconeBolha.vue'
import Selo from '../components/ui/Selo.vue'
import { temAudio, textoFormato } from '../components/livros/formatos.js'
import { useFavoritar } from '../composables/useFavoritar.js'
import { listarHistorico } from '../services/historicoService.js'
import { listarLivros } from '../services/livrosService.js'
import { useAuthStore } from '../stores/auth.js'
import { useFavoritosStore } from '../stores/favoritos.js'
import globo from '../images/ilustracoes/globo-livros.png'
import lamparina from '../images/imgs-baixo-banner/lamparina.png'
import nuvem from '../images/imgs-baixo-banner/nuvem.png'
import menina from '../images/imgs-baixo-banner/garota-com-fone.png'

const nome = computed(() => useAuthStore().usuario?.nome ?? '')
const favoritos = useFavoritosStore()
const { alternar: alternarFavorito, erro: erroFavorito, aviso: avisoFavorito, ehFavorito, estaPendente } = useFavoritar()

// ===== Histórico: resumo e "Continue de onde parou" =====
const historico = ref([])
const carregandoHistorico = ref(true)
const erroHistorico = ref(false)

const lido = (item) => item.progresso_percentual >= 100
const andamento = computed(() => historico.value.filter((item) => !lido(item)))
const totalLidos = computed(() => historico.value.filter(lido).length)
// O histórico já vem do lido mais recentemente para o mais antigo: os 10 primeiros em andamento (o resto, no Histórico)
const continuar = computed(() => andamento.value.slice(0, 10))

const plural = (total, um, varios) => (total === 1 ? `1 ${um}` : `${total} ${varios}`)
const resumo = computed(() => [
  { texto: plural(andamento.value.length, 'em andamento', 'em andamento'), icone: 'livro', cor: 'laranja' },
  { texto: plural(totalLidos.value, 'livro lido', 'livros lidos'), icone: 'estrela', cor: 'rosa' },
  { texto: plural(favoritos.favoritos.length, 'favorito', 'favoritos'), icone: 'coracao', cor: 'ceu' },
])

const rotuloProgresso = (item) => (item.pagina_atual ? `Parou na página ${item.pagina_atual}` : 'Começou a ler')

async function carregarHistorico() {
  carregandoHistorico.value = true
  erroHistorico.value = false
  try {
    historico.value = await listarHistorico()
  } catch {
    erroHistorico.value = true
  } finally {
    carregandoHistorico.value = false
  }
}

// ===== Novidades no acervo =====
const novidades = ref([])
const carregandoNovidades = ref(true)
const erroNovidades = ref(false)

async function carregarNovidades() {
  carregandoNovidades.value = true
  erroNovidades.value = false
  try {
    novidades.value = (await listarLivros({ ordem: 'recentes' })).slice(0, 12)
  } catch {
    erroNovidades.value = true
  } finally {
    carregandoNovidades.value = false
  }
}

onMounted(() => {
  carregarHistorico()
  carregarNovidades()
  favoritos.carregar({ forcar: true }).catch(() => {}) // o número de favoritos pode ter mudado em outra aba
})
</script>

<template>
  <LayoutLogado>
    <div class="leituras">
      <section class="boas-vindas" aria-labelledby="titulo-boas-vindas">
        <img class="boas-vindas-nuvem" :src="nuvem" alt="" aria-hidden="true">
        <img class="boas-vindas-menina" :src="menina" alt="" aria-hidden="true">

        <Selo tom="laranja">Olá, {{ nome }}!</Selo>
        <h1 id="titulo-boas-vindas" class="boas-vindas-titulo">
          Vamos continuar uma <DestaquePalavra>história?</DestaquePalavra>
        </h1>
        <p class="boas-vindas-texto">Seus livros guardam a página onde você parou. É só escolher e seguir lendo ou ouvindo.</p>

        <ul v-if="!carregandoHistorico && !erroHistorico" class="resumo">
          <li v-for="item in resumo" :key="item.icone" class="resumo-item">
            <IconeBolha :icone="item.icone" :cor="item.cor" :tamanho="36" :tamanho-icone="24" />
            {{ item.texto }}
          </li>
        </ul>
      </section>

      <section class="secao" aria-labelledby="titulo-andamento">
        <div class="secao-topo">
          <CabecalhoSecao id="titulo-andamento" titulo="Continue de onde parou" subtitulo="Seu marcador está salvo em cada livro.">
            <template #ilustracao><img :src="globo" alt=""></template>
          </CabecalhoSecao>
          <Botao tipo="contorno" to="/historico">
            <template #icone><Icone nome="historico" /></template>
            Ver histórico
          </Botao>
        </div>

        <p v-if="carregandoHistorico" class="secao-aviso" role="status">Carregando suas leituras…</p>

        <div v-else-if="erroHistorico" class="secao-erro">
          <Alerta tipo="erro">Não conseguimos carregar suas leituras.</Alerta>
          <Botao tipo="contorno" @click="carregarHistorico">Tentar de novo</Botao>
        </div>

        <EstadoVazio
          v-else-if="!continuar.length"
          class="secao-vazio"
          :nivel="3"
          :titulo="totalLidos ? 'Você terminou todos os livros que começou!' : 'Você ainda não começou nenhum livro'"
          descricao="Escolha uma história no acervo. A página onde você parar fica guardada aqui."
        >
          <template #acao><Botao tipo="contorno" to="/acervo">Explorar o acervo</Botao></template>
        </EstadoVazio>

        <FileiraRolagem v-else class="fileira fileira--continuar" :itens="continuar" :chave="(item) => item.livro_id">
          <template #default="{ item }">
            <CardContinuarLendo
              layout="vertical"
              :titulo="item.livro.titulo"
              :detalhe="item.livro.autor || ''"
              :categoria="item.livro.categoria?.nome"
              :capa-url="item.livro.capa_url"
              :progresso="item.progresso_percentual"
              :rotulo-progresso="rotuloProgresso(item)"
              :to="{ name: 'livro-leitura-logado', params: { id: item.livro_id } }"
            />
          </template>
        </FileiraRolagem>
      </section>

      <section class="secao secao--novidades" aria-labelledby="titulo-novidades">
        <div class="secao-topo">
          <CabecalhoSecao id="titulo-novidades" titulo="Novidades no acervo" subtitulo="Livros que acabaram de chegar no cantinho.">
            <template #ilustracao><img :src="lamparina" alt=""></template>
          </CabecalhoSecao>
          <Botao tipo="contorno" to="/acervo">
            <template #icone><Icone nome="seta-direita" /></template>
            Ver todo o acervo
          </Botao>
        </div>

        <p v-if="carregandoNovidades" class="secao-aviso" role="status">Carregando novidades…</p>

        <div v-else-if="erroNovidades" class="secao-erro">
          <Alerta tipo="erro">Não conseguimos carregar as novidades.</Alerta>
          <Botao tipo="contorno" @click="carregarNovidades">Tentar de novo</Botao>
        </div>

        <p v-else-if="!novidades.length" class="secao-aviso">O acervo ainda não tem livros.</p>

        <template v-else>
          <p class="so-leitor" role="status">{{ avisoFavorito }}</p>
          <Alerta v-if="erroFavorito" tipo="erro">{{ erroFavorito }}</Alerta>

          <FileiraRolagem class="fileira fileira--novidades" :itens="novidades">
            <template #default="{ item: livro }">
              <CardLivro
                :titulo="livro.titulo"
                :autor="livro.autor"
                :categoria="livro.categoria?.nome"
                :capa-url="livro.capa_url"
                :formato="textoFormato(livro)"
                :icone-formato="temAudio(livro) ? 'fones' : 'livro'"
                :to="{ name: 'livro-detalhe-logado', params: { id: livro.id } }"
                :favorito="ehFavorito(livro.id)"
                :favoritando="estaPendente(livro.id)"
                @favoritar="alternarFavorito(livro.id, livro.titulo)"
              />
            </template>
          </FileiraRolagem>
        </template>
      </section>
    </div>
  </LayoutLogado>
</template>

<style scoped>
.leituras {
  display: flex;
  flex-direction: column;
  gap: 40px;
  max-width: 1096px; /* largura do conteúdo no Figma */
  margin-inline: auto;
}

/* ===== Boas-vindas ===== */
.boas-vindas {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 14px;
  min-height: 276px;
  padding: var(--espaco-32) 36px;
  overflow: hidden;
  border-radius: 32px;
  background: var(--apoio-laranja-suave);
}

.boas-vindas > :not(img) {
  position: relative; /* texto acima dos adesivos */
}

.boas-vindas-nuvem,
.boas-vindas-menina {
  position: absolute;
  pointer-events: none;
}

.boas-vindas-nuvem {
  top: -26px;
  right: 170px;
  width: 300px;
  opacity: 0.9;
}

.boas-vindas-menina {
  top: 69px;
  right: var(--espaco-32);
  width: 230px;
}

.boas-vindas-titulo {
  color: var(--texto-principal);
  font: var(--fonte-titulo);
}

.boas-vindas-texto {
  max-width: 520px;
  color: var(--texto-corpo);
  font: var(--fonte-corpo);
}

.resumo {
  display: flex;
  flex-wrap: wrap;
  gap: var(--espaco-12);
  list-style: none;
}

.resumo-item {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 6px var(--espaco-16) 6px 6px;
  border-radius: var(--raio-total);
  background: var(--fundo-superficie);
  color: var(--texto-principal);
  font: var(--fonte-botao);
}

/* ===== Seções ===== */
.secao {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.secao-topo {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  justify-content: space-between;
  gap: var(--espaco-16);
}

.secao-aviso {
  color: var(--texto-secundario);
  font: var(--fonte-corpo);
}

.secao-erro {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--espaco-12);
}

.secao-vazio {
  align-self: center;
}

/* Só para leitor de tela */
.so-leitor {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip-path: inset(50%);
  white-space: nowrap;
}

/* ===== Fileiras com setas (components/ui/FileiraRolagem.vue) =====
   Na largura do Figma cabem 3 cards (continuar) e 4 (novidades); o resto fica para as setas.
   Com 1 ou 2 livros, o card não estica: fica do tamanho de uma coluna.
   O respiro de 8px nas laterais deixa a sombra dos cards à mostra; a margem negativa
   compensa, para os cards continuarem alinhados com o título da seção. */
.fileira {
  --fileira-espaco: 20px;
  --fileira-respiro: var(--espaco-8);
  --fileira-seta-lado: calc(var(--espaco-8) - 26px); /* metade da seta para fora, na borda da fileira */

  margin: calc(-1 * var(--espaco-16)) calc(-1 * var(--espaco-8)) calc(-1 * var(--espaco-24)); /* tira a folga de cima e de baixo da fileira */
}

.fileira--continuar {
  --fileira-largura-item: max(260px, calc((100% - 2 * 20px) / 3));
}

.fileira--novidades {
  --fileira-largura-item: max(220px, calc((100% - 3 * 20px) / 4));
}

/* ===== Telas menores ===== */
@media (max-width: 1000px) {
  .boas-vindas-nuvem,
  .boas-vindas-menina {
    display: none;
  }
}

@media (max-width: 640px) {
  .leituras {
    gap: var(--espaco-32);
  }

  .boas-vindas {
    padding: var(--espaco-24) var(--espaco-24);
    border-radius: var(--raio-20);
  }

  .boas-vindas-titulo {
    font: var(--fonte-titulo-cartao);
  }

  /* Celular: a seta fica toda dentro da tela, por cima do card (para fora, passaria da borda) */
  .fileira {
    --fileira-seta-lado: var(--espaco-8);
  }
}
</style>
