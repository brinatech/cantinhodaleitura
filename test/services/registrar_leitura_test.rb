require "test_helper"

class RegistrarLeituraTest < ActiveSupport::TestCase
  setup do
    @usuario = usuarios(:two)
    @livro = livros(:one) # usuário :two ainda não tem histórico neste livro
  end

  test "primeira leitura cria o histórico com início, última leitura e progresso" do
    historico = nil
    assert_difference "HistoricoLeitura.count", 1 do
      historico = RegistrarLeitura.call(usuario: @usuario, livro: @livro, pagina: 7, total_paginas: 28)
    end

    assert historico.persisted?
    assert_not_nil historico.data_inicio
    assert_equal historico.data_inicio, historico.data_ultima_leitura
    assert_equal BigDecimal("25"), historico.progresso_percentual
  end

  test "leituras seguintes atualizam o mesmo registro e mantêm o início" do
    primeira = RegistrarLeitura.call(usuario: @usuario, livro: @livro, pagina: 1, total_paginas: 10)
    inicio = primeira.data_inicio

    segunda = nil
    travel 1.day do
      assert_no_difference "HistoricoLeitura.count" do
        segunda = RegistrarLeitura.call(usuario: @usuario, livro: @livro, pagina: 5, total_paginas: 10)
      end
    end

    assert_equal primeira.id, segunda.id
    assert_equal inicio, segunda.reload.data_inicio
    assert_operator segunda.data_ultima_leitura, :>, inicio
    assert_equal BigDecimal("50"), segunda.progresso_percentual
  end

  test "progresso só aumenta: reler o começo não apaga o quanto já leu" do
    RegistrarLeitura.call(usuario: @usuario, livro: @livro, pagina: 8, total_paginas: 10)
    historico = RegistrarLeitura.call(usuario: @usuario, livro: @livro, pagina: 2, total_paginas: 10)

    assert_equal BigDecimal("80"), historico.reload.progresso_percentual
  end

  test "última página conta como livro lido (100%)" do
    historico = RegistrarLeitura.call(usuario: @usuario, livro: @livro, pagina: 28, total_paginas: 28)

    assert_equal BigDecimal("100"), historico.progresso_percentual
  end

  test "sem página, só marca que abriu o livro" do
    historico = RegistrarLeitura.call(usuario: @usuario, livro: @livro)

    assert historico.persisted?
    assert_equal BigDecimal("0"), historico.progresso_percentual
  end

  test "não mexe no histórico de outra pessoa" do
    do_outro = historico_leituras(:one) # usuário :one, livro :one
    progresso_antigo = do_outro.progresso_percentual

    RegistrarLeitura.call(usuario: @usuario, livro: @livro, pagina: 10, total_paginas: 10)

    assert_equal progresso_antigo, do_outro.reload.progresso_percentual
  end
end
