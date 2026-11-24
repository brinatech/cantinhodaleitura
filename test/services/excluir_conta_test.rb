require "test_helper"

class ExcluirContaTest < ActiveSupport::TestCase
  setup do
    @ana = Usuario.create!(nome: "Ana", email: "ana-exclusao@example.com", password: "password123")
    @beto = Usuario.create!(nome: "Beto", email: "beto-exclusao@example.com", password: "password123")
    @livro = livros(:one)
  end

  def dar_dados_para(usuario)
    Favorito.create!(usuario: usuario, livro: @livro)
    MarcadorPagina.create!(usuario: usuario, livro: @livro, pagina_atual: 3)
    HistoricoLeitura.create!(usuario: usuario, livro: @livro, progresso_percentual: 10, data_inicio: Time.current, data_ultima_leitura: Time.current)
    lista = ListaLeitura.create!(usuario: usuario, nome: "Para ler")
    lista.lista_leitura_livros.create!(livro: @livro)
    AcessoMaterial.create!(usuario: usuario, livro: @livro, tipo_acesso: "leitura")
  end

  test "apaga os dados pessoais, mantém os acessos e anonimiza a conta" do
    dar_dados_para(@ana)
    lista_id = @ana.lista_leituras.first.id

    ExcluirConta.call(usuario: @ana)
    @ana.reload

    assert_equal 0, @ana.favoritos.count
    assert_equal 0, @ana.marcador_paginas.count
    assert_equal 0, @ana.historico_leituras.count
    assert_equal 0, @ana.lista_leituras.count
    assert_equal 0, ListaLeituraLivro.where(lista_leitura_id: lista_id).count
    assert_equal 1, @ana.acesso_materials.count, "os acessos ficam para os relatórios"

    assert_equal "Conta excluída", @ana.nome
    assert_equal "conta-excluida-#{@ana.id}@cantinho.invalid", @ana.email
    assert_not @ana.ativo
    assert @ana.excluido?
    assert_nil @ana.ultimo_acesso_em
    assert_not @ana.authenticate("password123"), "a senha antiga deixa de valer"
    assert Livro.exists?(@livro.id), "o livro continua no acervo"
  end

  test "não mexe nos dados de outra pessoa" do
    dar_dados_para(@ana)
    dar_dados_para(@beto)

    ExcluirConta.call(usuario: @ana)

    @beto.reload
    assert_equal [ 1, 1, 1, 1 ], [ @beto.favoritos.count, @beto.marcador_paginas.count, @beto.historico_leituras.count, @beto.lista_leituras.count ]
    assert_equal "Beto", @beto.nome
    assert @beto.ativo
  end

  test "funciona com uma conta sem nenhum dado" do
    ExcluirConta.call(usuario: @ana)

    assert @ana.reload.excluido?
  end

  test "o e-mail original fica livre para uma conta nova" do
    ExcluirConta.call(usuario: @ana)

    nova = Usuario.create!(nome: "Ana de novo", email: "ana-exclusao@example.com", password: "password123")
    assert nova.persisted?
  end

  test "se algo falhar, nada é apagado" do
    dar_dados_para(@ana)
    @ana.define_singleton_method(:update!) { |*| raise ActiveRecord::RecordInvalid, self }

    assert_raises(ActiveRecord::RecordInvalid) { ExcluirConta.call(usuario: @ana) }

    assert_equal 1, Favorito.where(usuario_id: @ana.id).count
    assert_equal 1, ListaLeitura.where(usuario_id: @ana.id).count
    assert_equal "Ana", @ana.reload.nome
  end
end
