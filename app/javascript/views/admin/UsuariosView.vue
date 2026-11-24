<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import LayoutLogado from '../../components/layout/LayoutLogado.vue'
import Alerta from '../../components/ui/Alerta.vue'
import Botao from '../../components/ui/Botao.vue'
import EstadoVazio from '../../components/ui/EstadoVazio.vue'
import { ErroApi } from '../../services/api.js'
import { atualizarUsuario, listarUsuarios } from '../../services/admin/usuariosAdminService.js'
import { useAuthStore } from '../../stores/auth.js'

const auth = useAuthStore()
const usuarios = ref([])
const carregando = ref(true)
const erroLista = ref('')
const busca = ref('')
const filtro = ref('todos')
const salvando = ref({})
const aviso = ref('')
const erroAcao = ref('')
const papeis = reactive({})

const filtrados = computed(() => {
  const termo = busca.value.trim().toLocaleLowerCase('pt-BR')
  return usuarios.value.filter((usuario) => {
    const combina = !termo || `${usuario.nome} ${usuario.email}`.toLocaleLowerCase('pt-BR').includes(termo)
    const status = filtro.value === 'todos' || (filtro.value === 'ativos' ? usuario.ativo : !usuario.ativo)
    return combina && status
  })
})

const mensagemErro = (erro) => {
  if (!(erro instanceof ErroApi)) return 'Não conseguimos conectar ao servidor. Tente de novo.'
  if (erro.status === 401) return 'Sua sessão terminou. Entre de novo para continuar.'
  if (erro.status === 403) return erro.message || 'Só administradores podem gerenciar contas.'
  return erro.message
}

async function carregar() {
  carregando.value = true
  erroLista.value = ''
  try {
    usuarios.value = await listarUsuarios()
    usuarios.value.forEach((usuario) => { papeis[usuario.id] = usuario.tipo_usuario })
  } catch (erro) {
    erroLista.value = mensagemErro(erro)
  } finally {
    carregando.value = false
  }
}

onMounted(carregar)

async function salvarPapel(usuario) {
  erroAcao.value = ''
  aviso.value = ''
  salvando.value[usuario.id] = true
  try {
    const atualizado = await atualizarUsuario(usuario.id, { tipo_usuario: papeis[usuario.id] })
    usuarios.value = usuarios.value.map((item) => item.id === atualizado.id ? atualizado : item)
    aviso.value = `Perfil de ${atualizado.nome} atualizado.`
  } catch (erro) {
    erroAcao.value = mensagemErro(erro)
    papeis[usuario.id] = usuario.tipo_usuario
  } finally {
    salvando.value[usuario.id] = false
  }
}

async function alternarAtivo(usuario) {
  erroAcao.value = ''
  aviso.value = ''
  const acao = usuario.ativo ? 'bloquear' : 'reativar'
  if (usuario.ativo && !window.confirm(`Bloquear a conta de ${usuario.nome}? A pessoa não poderá entrar até que a conta seja reativada.`)) return

  salvando.value[usuario.id] = true
  try {
    const atualizado = await atualizarUsuario(usuario.id, { ativo: !usuario.ativo })
    usuarios.value = usuarios.value.map((item) => item.id === atualizado.id ? atualizado : item)
    aviso.value = `Conta de ${atualizado.nome} ${atualizado.ativo ? 'reativada' : 'bloqueada'}.`
  } catch (erro) {
    erroAcao.value = mensagemErro(erro)
  } finally {
    salvando.value[usuario.id] = false
  }
}

const dataBr = (valor) => valor ? new Date(valor).toLocaleDateString('pt-BR') : 'Nunca acessou'
</script>

<template>
  <LayoutLogado>
    <main class="usuarios-admin">
      <header class="usuarios-topo">
        <p class="usuarios-rotulo">Administração</p>
        <h1>Usuários</h1>
        <p>Consulte as contas, altere o perfil de acesso ou bloqueie e reative o acesso.</p>
      </header>

      <Alerta v-if="aviso" tipo="sucesso" role="status">{{ aviso }}</Alerta>
      <Alerta v-if="erroAcao" tipo="erro" role="alert">{{ erroAcao }}</Alerta>

      <EstadoVazio v-if="erroLista" titulo="Usuários indisponíveis" :descricao="erroLista">
        <template #acao><Botao tipo="contorno" @click="carregar">Tentar de novo</Botao></template>
      </EstadoVazio>

      <p v-else-if="carregando" class="usuarios-status" role="status">Carregando usuários…</p>

      <template v-else>
        <section class="usuarios-filtros" aria-label="Filtros de usuários">
          <label class="usuarios-campo">
            <span>Buscar por nome ou e-mail</span>
            <input v-model="busca" type="search" autocomplete="off" placeholder="Ex.: Maria ou maria@email.com">
          </label>
          <label class="usuarios-campo usuarios-campo--status">
            <span>Status</span>
            <select v-model="filtro">
              <option value="todos">Todas as contas</option>
              <option value="ativos">Ativas</option>
              <option value="inativos">Bloqueadas</option>
            </select>
          </label>
        </section>

        <p class="usuarios-contagem" aria-live="polite">{{ filtrados.length }} de {{ usuarios.length }} contas</p>

        <div v-if="filtrados.length" class="usuarios-tabela-wrap">
          <table class="usuarios-tabela">
            <caption class="so-leitor">Contas cadastradas e ações administrativas</caption>
            <thead>
              <tr>
                <th scope="col">Conta</th>
                <th scope="col">Perfil</th>
                <th scope="col">Status</th>
                <th scope="col">Último acesso</th>
                <th scope="col"><span class="so-leitor">Ações</span></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="usuario in filtrados" :key="usuario.id">
                <td data-label="Conta">
                  <strong>{{ usuario.nome }}</strong>
                  <span class="usuarios-email">{{ usuario.email }}</span>
                </td>
                <td data-label="Perfil">
                  <template v-if="usuario.id === auth.usuario?.id">
                    <span class="usuarios-papel">Administrador (sua conta)</span>
                  </template>
                  <div v-else class="usuarios-papel-edicao">
                    <label class="so-leitor" :for="`papel-${usuario.id}`">Perfil de {{ usuario.nome }}</label>
                    <select :id="`papel-${usuario.id}`" v-model="papeis[usuario.id]" :disabled="salvando[usuario.id]">
                      <option value="leitor">Leitor</option>
                      <option value="administrador">Administrador</option>
                    </select>
                    <button
                      v-if="papeis[usuario.id] !== usuario.tipo_usuario"
                      class="usuarios-link"
                      type="button"
                      :disabled="salvando[usuario.id]"
                      @click="salvarPapel(usuario)"
                    >Salvar perfil</button>
                  </div>
                </td>
                <td data-label="Status">
                  <span class="usuarios-status-conta" :class="usuario.ativo ? 'is-ativo' : 'is-bloqueado'">
                    {{ usuario.ativo ? 'Ativa' : 'Bloqueada' }}
                  </span>
                </td>
                <td data-label="Último acesso">{{ dataBr(usuario.ultimo_acesso_em) }}</td>
                <td data-label="Ações">
                  <button
                    v-if="usuario.id !== auth.usuario?.id"
                    class="usuarios-acao"
                    :class="usuario.ativo ? 'usuarios-acao--bloquear' : 'usuarios-acao--reativar'"
                    type="button"
                    :disabled="salvando[usuario.id]"
                    @click="alternarAtivo(usuario)"
                  >{{ salvando[usuario.id] ? 'Salvando…' : usuario.ativo ? 'Bloquear' : 'Reativar' }}</button>
                  <span v-else class="usuarios-propria-conta">Você não pode bloquear sua própria conta.</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <EstadoVazio v-else titulo="Nenhuma conta encontrada" descricao="Mude a busca ou o filtro de status." />
      </template>
    </main>
  </LayoutLogado>
</template>

<style scoped>
.usuarios-admin { max-width: 1180px; margin: 0 auto; padding: 40px clamp(20px, 4vw, 56px) 64px; color: var(--texto-principal); }
.usuarios-topo { margin-bottom: 28px; }
.usuarios-rotulo { margin: 0 0 8px; color: var(--texto-secundario); font: var(--fonte-rotulo); letter-spacing: var(--letras-rotulo); text-transform: uppercase; }
.usuarios-topo h1 { margin: 0; font: var(--fonte-titulo); }
.usuarios-topo > p:last-child { margin: 10px 0 0; color: var(--texto-secundario); }
.usuarios-filtros { display: flex; flex-wrap: wrap; align-items: end; gap: 16px; margin: 28px 0 12px; padding: 20px; border: 1px solid var(--borda-padrao); border-radius: var(--raio-20); background: var(--fundo-superficie); }
.usuarios-campo { display: grid; flex: 1 1 280px; gap: 8px; color: var(--texto-principal); font: var(--fonte-rotulo); }
.usuarios-campo--status { flex: 0 1 220px; }
.usuarios-campo input, .usuarios-campo select, .usuarios-papel-edicao select { min-height: 44px; padding: 9px 12px; border: 1px solid var(--borda-padrao); border-radius: var(--raio-8); background: var(--fundo-superficie); color: var(--texto-principal); font: var(--fonte-corpo); }
.usuarios-campo :focus-visible, .usuarios-papel-edicao select:focus-visible, .usuarios-admin button:focus-visible { outline: 3px solid var(--borda-foco); outline-offset: 2px; }
.usuarios-contagem { color: var(--texto-secundario); font: var(--fonte-rotulo); }
.usuarios-tabela-wrap { overflow-x: auto; border: 1px solid var(--borda-padrao); border-radius: var(--raio-20); background: var(--fundo-superficie); }
.usuarios-tabela { width: 100%; border-collapse: collapse; text-align: left; }
.usuarios-tabela th, .usuarios-tabela td { padding: 16px; border-bottom: 1px solid var(--borda-padrao); vertical-align: middle; }
.usuarios-tabela th { color: var(--texto-secundario); font: var(--fonte-rotulo); }
.usuarios-tabela tbody tr:last-child td { border-bottom: 0; }
.usuarios-tabela td:first-child { min-width: 210px; }
.usuarios-email { display: block; margin-top: 4px; color: var(--texto-secundario); font-size: .9rem; }
.usuarios-papel-edicao { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; }
.usuarios-papel { color: var(--texto-secundario); }
.usuarios-link { padding: 8px 10px; border: 0; background: transparent; color: var(--texto-principal); font: var(--fonte-rotulo); text-decoration: underline; cursor: pointer; }
.usuarios-status-conta { display: inline-flex; padding: 6px 10px; border-radius: 999px; font: var(--fonte-rotulo); }
.is-ativo { background: var(--fundo-suave); color: var(--texto-principal); }
.is-bloqueado { background: var(--apoio-rosa-suave); color: var(--texto-erro); }
.usuarios-acao { padding: 9px 12px; border: 1px solid var(--borda-padrao); border-radius: var(--raio-8); background: transparent; font: var(--fonte-rotulo); cursor: pointer; }
.usuarios-acao--bloquear { color: var(--texto-erro); }
.usuarios-acao--reativar { color: var(--texto-principal); }
.usuarios-acao:disabled, .usuarios-link:disabled { opacity: .6; cursor: wait; }
.usuarios-propria-conta { display: inline-block; max-width: 190px; color: var(--texto-secundario); font-size: .85rem; }
.usuarios-status { padding: 24px 0; color: var(--texto-secundario); }
.so-leitor { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; border: 0; }
@media (max-width: 760px) {
  .usuarios-admin { padding-top: 28px; }
  .usuarios-tabela thead { position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0, 0, 0, 0); }
  .usuarios-tabela, .usuarios-tabela tbody, .usuarios-tabela tr, .usuarios-tabela td { display: block; width: 100%; }
  .usuarios-tabela tr { padding: 8px 14px; border-bottom: 1px solid var(--borda-padrao); }
  .usuarios-tabela tbody tr:last-child { border-bottom: 0; }
  .usuarios-tabela td { display: grid; grid-template-columns: minmax(100px, 34%) 1fr; gap: 12px; padding: 10px 2px; border: 0; }
  .usuarios-tabela td::before { content: attr(data-label); color: var(--texto-secundario); font: var(--fonte-rotulo); }
  .usuarios-tabela td:first-child { min-width: 0; }
}
</style>
