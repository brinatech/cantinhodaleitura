ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Testes em sequência. Em paralelo com threads, todas usam o mesmo banco de teste
    # e o carregamento das fixtures entra em deadlock no PostgreSQL. No Windows não
    # há fork, então o modo :processes (um banco por worker) não está disponível.
    # A suíte é pequena e roda em poucos segundos sem paralelismo.
    parallelize(workers: 1)

    # Load fixtures in foreign-key dependency order.
    fixtures :usuarios,
         :categorias,
         :livros,
         :arquivo_materials,
         :acesso_materials,
         :favoritos,
         :lista_leituras,
         :lista_leitura_livros,
         :historico_leituras,
         :marcador_paginas,
         :classificacaos

    # Add more helper methods to be used by all tests here...
  end
end
