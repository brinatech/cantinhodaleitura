ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, with: :threads)

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
