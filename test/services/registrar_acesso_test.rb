require "test_helper"

class RegistrarAcessoTest < ActiveSupport::TestCase
  setup do
    @livro = livros(:one)
    @sessao = {}
  end

  def registrar(tipo = "leitura", livro: @livro, usuario: nil, sessao: @sessao)
    RegistrarAcesso.call(livro: livro, tipo: tipo, usuario: usuario, sessao: sessao)
  end

  test "grava o acesso do visitante sem usuário" do
    acesso = nil
    assert_difference "AcessoMaterial.count", 1 do
      acesso = registrar
    end

    assert_nil acesso.usuario
    assert_equal "leitura", acesso.tipo_acesso
    assert_equal @livro, acesso.livro
  end

  test "grava o usuário logado" do
    acesso = registrar(usuario: usuarios(:one))

    assert_equal usuarios(:one), acesso.usuario
  end

  test "o mesmo acesso na mesma sessão conta uma vez só dentro de 30 minutos" do
    assert_difference "AcessoMaterial.count", 1 do
      registrar
      registrar # ex.: o arquivo de áudio, ou o link renovado do player
    end
  end

  test "depois de 30 minutos conta de novo" do
    registrar

    travel 31.minutes do
      assert_difference "AcessoMaterial.count", 1 do
        registrar
      end
    end
  end

  test "tipos diferentes e livros diferentes contam separado" do
    assert_difference "AcessoMaterial.count", 3 do
      registrar("visualizacao")
      registrar("leitura")
      registrar("leitura", livro: livros(:two))
    end
  end

  test "outra sessão (outro navegador) conta separado" do
    assert_difference "AcessoMaterial.count", 2 do
      registrar(sessao: {})
      registrar(sessao: {})
    end
  end

  test "a sessão guarda só os acessos da última meia hora" do
    registrar("leitura", livro: livros(:one))

    travel 31.minutes do
      registrar("leitura", livro: livros(:two))
    end

    assert_equal [ "#{livros(:two).id}-leitura" ], @sessao[:acessos_recentes].keys
  end

  test "tipo inválido não grava e não quebra" do
    assert_no_difference "AcessoMaterial.count" do
      assert_not registrar("abriu").persisted?
    end
  end
end
