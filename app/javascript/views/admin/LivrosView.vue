<!-- Tela de administração de livros do acervo, apenas para administradores. -->
<!-- Permite cadastrar, editar e excluir livros do acervo, com arquivos em texto ou áudio. -->

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import LayoutLogado from '../../components/layout/LayoutLogado.vue'
import Alerta from '../../components/ui/Alerta.vue'
import Botao from '../../components/ui/Botao.vue'
import EstadoVazio from '../../components/ui/EstadoVazio.vue'
import ModalConfirmacao from '../../components/ui/ModalConfirmacao.vue'
import { ErroApi } from '../../services/api.js'
import { criarLivro, editarLivro, excluirLivro, listarLivrosAdmin } from '../../services/admin/livrosAdminService.js'
import { listarCategorias } from '../../services/admin/categoriasAdminService.js'
import FormLivro from '../../components/admin/FormLivro.vue'


const livros = ref([])
const categorias = ref([])
const carregando = ref(true)
const erroLista = ref('')

const salvando = ref(false)
const errosServidor = ref({})
const aviso = reactive({ tipo: 'sucesso', texto: '' })
const formLivro = ref(null)
const editando = ref(null) // livro em edição; null = cadastrando um novo
const modalExclusao = ref(null)
const paraExcluir = ref(null) // livro escolhido no botão "Excluir"
const excluindo = ref(false)
const erroExclusao = ref('')

const ROTULOS = { titulo: 'Título', autor: 'Autor', descricao: 'Descrição', categoria: 'Categoria', capa: 'Capa', arquivo: 'Arquivo' }


const SEM_SERVIDOR = 'Não conseguimos conectar ao servidor. Tente de novo.'
const ROTULO_FORMATO = { texto: 'Texto', audio: 'Áudio' }
// Retorna a mensagem de erro apropriada para exibir ao usuário, com base no tipo de erro e status HTTP.
function mensagemDoErro(erro) {
    if (!(erro instanceof ErroApi)) return SEM_SERVIDOR
    if (erro.status === 401) return 'Sua sessão terminou. Entre de novo para continuar.'
    if (erro.status === 403) return 'Só administradores podem gerenciar livros.'
    return erro.message
}

// A API de livros só manda o número da categoria; o nome vem da lista de categorias
const nomeDaCategoria = (id) => categorias.value.find((categoria) => categoria.id === id)?.nome ?? 'Sem categoria'

const formatosDo = (livro) => livro.arquivos.map((arquivo) => ROTULO_FORMATO[arquivo.tipo] ?? arquivo.tipo).join(' e ')

const livrosOrdenados = computed(() =>
    [...livros.value].sort((a, b) => a.titulo.localeCompare(b.titulo, 'pt-BR')),
)
// Carrega a lista de livros e categorias do servidor, tratando o estado de carregamento e erros.
async function carregar() {
    carregando.value = true
    erroLista.value = ''
    try {
        const [listaLivros, listaCategorias] = await Promise.all([listarLivrosAdmin(), listarCategorias()])
        livros.value = listaLivros
        categorias.value = listaCategorias
    } catch (erro) {
        erroLista.value = mensagemDoErro(erro)
    } finally {
        carregando.value = false
    }
}
// Rails manda { titulo: ['não pode ficar em branco'] }; o formulário quer { titulo: 'Título não pode ficar em branco.' }
// O erro "arquivo" vai para o campo do arquivo que estava sendo enviado
function errosPorCampo(erro, campoDoArquivo) {
    const resultado = {}
    for (const [campo, mensagens] of Object.entries(erro.erros ?? {})) {
        const destino = campo === 'arquivo' ? campoDoArquivo : campo
        resultado[destino] = `${ROTULOS[campo] ?? campo} ${mensagens[0]}.`
    }
    return resultado
}

// Serve para cadastrar (livro novo) e para editar (quando "editando" tem um livro)
async function salvar(dados) {
    salvando.value = true
    errosServidor.value = {}
    aviso.texto = ''
    const livroEditado = editando.value

    // Quais arquivos vão: o PDF e/ou o áudio, nesta ordem. Na edição pode não ir nenhum.
    const envios = []
    if (dados.arquivoTexto) envios.push({ tipoArquivo: 'texto', arquivo: dados.arquivoTexto, campo: 'arquivoTexto' })
    if (dados.arquivoAudio) envios.push({ tipoArquivo: 'audio', arquivo: dados.arquivoAudio, campo: 'arquivoAudio' })
    const [primeiro, segundo] = envios

    let livro = null
    try {
        // 1º envio: os dados + o primeiro arquivo. Edita (PATCH) ou cria (POST).
        livro = livroEditado
            ? await editarLivro(livroEditado.id, { ...dados, ...primeiro })
            : await criarLivro({ ...dados, ...primeiro })

        // 2º envio: só se escolheu os dois arquivos. Manda o áudio para o mesmo livro.
        // A capa já foi no 1º envio: não manda a mesma imagem de novo.
        if (segundo) livro = await editarLivro(livro.id, { ...dados, ...segundo, capa: null })

        Object.assign(aviso, { tipo: 'sucesso', texto: `Livro "${livro.titulo}" ${livroEditado ? 'atualizado' : 'cadastrado'}.` })
    } catch (erro) {
        if (livro) {
            // O 1º envio deu certo e o 2º não: o livro foi salvo, só ficou sem o áudio
            Object.assign(aviso, {
                tipo: 'erro',
                texto: `O livro "${livro.titulo}" foi salvo, mas o áudio não foi enviado. Edite o livro para enviar o áudio de novo.`,
            })
        } else if (erro instanceof ErroApi && erro.status === 422) {
            // Dados errados: mostra cada erro embaixo do seu campo
            errosServidor.value = errosPorCampo(erro, primeiro?.campo ?? 'arquivoTexto')
            return
        } else {
            Object.assign(aviso, { tipo: 'erro', texto: mensagemDoErro(erro) })
            return
        }
    } finally {
        salvando.value = false
    }

    // Chegou aqui: o livro foi salvo. Novo entra na lista; editado troca o antigo.
    if (livroEditado) {
        livros.value = livros.value.map((item) => (item.id === livro.id ? livro : item))
    } else {
        livros.value.push(livro)
    }
    editando.value = null
    formLivro.value.limpar()
}

function comecarEdicao(livro) {
    editando.value = livro
    errosServidor.value = {}
    aviso.texto = ''
    window.scrollTo({ top: 0, behavior: 'smooth' }) // o formulário fica no topo da página
}

function cancelarEdicao() {
    editando.value = null
    errosServidor.value = {}
}

// "Excluir" na lista só abre o modal; a exclusão acontece no botão do modal
function pedirExclusao(livro) {
    aviso.texto = ''
    paraExcluir.value = livro
    erroExclusao.value = ''
    modalExclusao.value.abrir()
}

async function confirmarExclusao() {
    const livro = paraExcluir.value
    excluindo.value = true
    erroExclusao.value = ''
    const tirarDaLista = () => (livros.value = livros.value.filter((item) => item.id !== livro.id))
    try {
        await excluirLivro(livro.id)
        tirarDaLista()
        if (editando.value?.id === livro.id) cancelarEdicao()
        Object.assign(aviso, { tipo: 'sucesso', texto: `Livro "${livro.titulo}" excluído.` })
        excluindo.value = false
        modalExclusao.value.fechar()
    } catch (erro) {
        excluindo.value = false
        if (erro instanceof ErroApi && erro.status === 404) {
            // Alguém já tinha excluído: tira da lista e avisa fora do modal
            tirarDaLista()
            modalExclusao.value.fechar()
            Object.assign(aviso, { tipo: 'erro', texto: `O livro "${livro.titulo}" já tinha sido excluído.` })
            return
        }
        // O Rails não apaga livro que tem classificações, favoritos, histórico, marcadores,
        // listas ou acessos ligados a ele (responde 422 com erros.base)
        erroExclusao.value =
            erro instanceof ErroApi && erro.erros?.base
                ? 'Este livro não pode ser excluído porque tem classificações, favoritos, histórico ou listas de leitura ligados a ele.'
                : mensagemDoErro(erro)
    }
}


// Função chamada ao montar o componente para iniciar o carregamento dos dados.
onMounted(carregar)
</script>

<template>
    <LayoutLogado>
        <div class="admin-pagina">
            <div>
                <p class="admin-rotulo">Administração</p>
                <h1 class="admin-titulo">Livros</h1>
                <p class="admin-subtitulo">Cadastre os livros do acervo, com o arquivo em texto ou áudio.</p>
            </div>
            <Alerta v-if="aviso.texto" :tipo="aviso.tipo">{{ aviso.texto }}</Alerta>

            <FormLivro v-if="!carregando && !erroLista" ref="formLivro" :categorias="categorias" :livro="editando"
                :salvando="salvando" :erros="errosServidor" @enviar="salvar" @cancelar="cancelarEdicao" />



            <section class="cartao" aria-labelledby="titulo-lista-livros" :aria-busy="carregando">
                <h2 id="titulo-lista-livros" class="cartao-titulo">
                    Livros cadastrados<span v-if="!carregando && !erroLista"> ({{ livros.length }})</span>
                </h2>

                <p v-if="carregando" class="cartao-texto" role="status">Carregando livros...</p>

                <template v-else-if="erroLista">
                    <Alerta tipo="erro">{{ erroLista }}</Alerta>
                    <Botao tipo="contorno" @click="carregar">Tentar de novo</Botao>
                </template>

                <EstadoVazio v-else-if="!livros.length" :nivel="3" titulo="Nenhum livro cadastrado"
                    descricao="Os livros cadastrados vão aparecer aqui." />

                <ul v-else class="lista">
                    <li v-for="livro in livrosOrdenados" :key="livro.id" class="item">
                        <div class="item-capa" aria-hidden="true">
                            <img v-if="livro.capa_url" :src="livro.capa_url" alt="">
                        </div>
                        <div class="item-texto">
                            <span class="item-nome">{{ livro.titulo }}</span>
                            <span class="item-descricao">
                                {{ livro.autor || 'Autor não informado' }} · {{ nomeDaCategoria(livro.id_categoria) }}
                            </span>
                            <span class="item-descricao">
                                {{ livro.arquivos.length ? `Formato: ${formatosDo(livro)}` : 'Sem arquivo' }}
                            </span>
                        </div>
                        <div class="item-acoes">
                            <Botao tipo="contorno" :aria-label="`Editar ${livro.titulo}`" @click="comecarEdicao(livro)">
                                Editar
                            </Botao>
                            <Botao tipo="contorno" :aria-label="`Classificações de ${livro.titulo}`"
                                :to="`/admin/livros/${livro.id}/classificacoes`">
                                Classificações
                            </Botao>
                            <Botao tipo="contorno" :aria-label="`Excluir ${livro.titulo}`" @click="pedirExclusao(livro)">
                                Excluir
                            </Botao>
                        </div>
                    </li>
                </ul>
            </section>
        </div>

        <ModalConfirmacao ref="modalExclusao" titulo="Excluir livro?" texto-confirmar="Excluir"
            texto-carregando="Excluindo..." :carregando="excluindo" :erro="erroExclusao"
            @confirmar="confirmarExclusao" @fechado="paraExcluir = null">
            <p v-if="paraExcluir">
                O livro <strong>{{ paraExcluir.titulo }}</strong> e os arquivos dele serão excluídos.
                Essa ação não pode ser desfeita.
            </p>
        </ModalConfirmacao>
    </LayoutLogado>
</template>

<style scoped>
.admin-pagina {
    display: flex;
    flex-direction: column;
    gap: var(--espaco-24);
    max-width: 720px;
    margin-inline: auto;
}

.admin-rotulo {
    margin-bottom: var(--espaco-4);
    color: var(--texto-secundario);
    font: var(--fonte-rotulo);
    letter-spacing: var(--letras-rotulo);
    text-transform: uppercase;
}

.admin-titulo {
    color: var(--texto-principal);
    font: var(--fonte-titulo);
}

.admin-subtitulo {
    margin-top: var(--espaco-8);
    color: var(--texto-secundario);
    font: var(--fonte-interface);
}

.cartao {
    display: flex;
    flex-direction: column;
    gap: var(--espaco-16);
    padding: var(--espaco-32);
    border-radius: var(--raio-20);
    background: var(--fundo-superficie);
    box-shadow: var(--sombra-cartao);
}

.cartao> :deep(.vazio) {
    align-self: center;
}

.cartao>button {
    align-self: flex-start;
}

.cartao-titulo {
    color: var(--texto-principal);
    font: var(--fonte-subtitulo);
}

.cartao-texto {
    color: var(--texto-secundario);
    font: var(--fonte-interface);
}

.cartao-acoes {
    display: flex;
    flex-wrap: wrap;
    gap: var(--espaco-12);
}

.lista {
    display: flex;
    flex-direction: column;
    gap: var(--espaco-8);
    padding: 0;
    list-style: none;
}

.item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--espaco-16);
    padding: var(--espaco-12) var(--espaco-16);
    border-radius: var(--raio-12);
    background: var(--fundo-nuvem);
}

.item-texto {
    display: flex;
    flex: 1;
    flex-direction: column;
    gap: var(--espaco-4);
    min-width: 0;
}

/* Miniatura da capa; sem capa, fica só o fundo (como os cards do acervo) */
.item-capa {
    flex-shrink: 0;
    width: 48px;
    height: 64px;
    overflow: hidden;
    border-radius: var(--raio-8);
    background: var(--fundo-suave);
}

.item-capa img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.item-nome {
    color: var(--texto-principal);
    font: var(--fonte-botao);
    overflow-wrap: anywhere;
}

.item-descricao {
    color: var(--texto-secundario);
    font: var(--fonte-legenda);
    overflow-wrap: anywhere;
}

.item-acoes {
    display: flex;
    flex-wrap: wrap;
    flex-shrink: 0;
    justify-content: flex-end;
    gap: var(--espaco-8);
}

@media (max-width: 520px) {
    .cartao {
        padding: var(--espaco-24) var(--espaco-16);
    }

    .item {
        flex-direction: column;
        align-items: stretch;
    }

    .item-acoes>* {
        flex: 1;
    }
}
</style>