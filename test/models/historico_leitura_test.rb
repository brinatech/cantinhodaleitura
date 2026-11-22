require "test_helper"

class HistoricoLeituraTest < ActiveSupport::TestCase
  test "exige usuário e livro" do
    historico = HistoricoLeitura.new

    assert_not historico.valid?
    assert_not_empty historico.errors[:usuario]
    assert_not_empty historico.errors[:livro]
  end

  test "progresso fica entre 0 e 100" do
    [ -1, 100.01 ].each do |progresso|
      historico = HistoricoLeitura.new(usuario: usuarios(:two), livro: livros(:one), progresso_percentual: progresso)

      assert_not historico.valid?, "o progresso #{progresso} deveria ser recusado"
    end
    assert HistoricoLeitura.new(usuario: usuarios(:two), livro: livros(:one), progresso_percentual: 100).valid?
  end

  test "um registro por pessoa e livro" do
    repetido = HistoricoLeitura.new(usuario: usuarios(:one), livro: livros(:one)) # o fixture :one já é esse par

    assert_not repetido.valid?
    assert_includes repetido.errors[:livro_id], "já está em uso"
  end

  test "a última leitura não pode ser antes do início" do
    historico = HistoricoLeitura.new(usuario: usuarios(:two), livro: livros(:one), data_inicio: Time.current, data_ultima_leitura: 1.day.ago)

    assert_not historico.valid?
    assert_not_empty historico.errors[:data_ultima_leitura]
  end
end
