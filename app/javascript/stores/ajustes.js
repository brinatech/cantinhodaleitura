import { defineStore } from 'pinia'

// Ajustes de leitura (Figma: "Painel de acessibilidade"). Ficam salvos no navegador.
// Cada ajuste vira um atributo no <html>; as regras estão em styles/ajustes.css.
const CHAVE = 'cantinho:ajustes'
const PADRAO = { tamanho: 'normal', linhas: 'normal', tema: 'claro', voz: false, contraste: false, calmo: false }
const ESCALA = { normal: '100%', grande: '112.5%', maior: '125%' } // A, A+, A++ (fontes são em rem)

function ler() {
  try {
    return { ...PADRAO, ...JSON.parse(localStorage.getItem(CHAVE)) }
  } catch {
    return { ...PADRAO } // sem localStorage (janela privada, dados bloqueados): usa o padrão
  }
}

export const useAjustesStore = defineStore('ajustes', {
  state: () => ler(),
  actions: {
    aplicar() {
      const html = document.documentElement
      html.style.fontSize = ESCALA[this.tamanho] ?? ESCALA.normal
      html.dataset.linhas = this.linhas
      html.dataset.tema = this.tema // "escuro": styles/tema-escuro.css
      html.toggleAttribute('data-contraste-alto', this.contraste)
      html.toggleAttribute('data-calmo', this.calmo)
      try {
        localStorage.setItem(CHAVE, JSON.stringify(this.$state))
      } catch {
        /* sem armazenamento: o ajuste vale só nesta visita */
      }
    },
    iniciar() {
      this.aplicar()
      this.$subscribe(() => this.aplicar())
    },
    restaurar() {
      this.$patch({ ...PADRAO })
    },
  },
})
