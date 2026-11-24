# Dados iniciais da biblioteca. Pode ser executado mais de uma vez sem duplicar
# categorias ou livros.

usuario_seed = Usuario.find_or_create_by!(email: "seed@cantinhodaleitura.local") do |usuario|
  usuario.nome = "Cadastro dos livros iniciais"
  usuario.password = SecureRandom.hex(32)
  usuario.tipo_usuario = "administrador"
  usuario.data_cadastro = Time.current
end

livros = [
  {
    titulo: "Luna e o Cachorrinho Aventureiro",
    autor: "Autor fictício",
    descricao: "Luna eo Cachorrinho Aventureiro é uma história infantil que aborda amizade, carinho, coragem ecuidado com os animais. Acompanhe Luna e seu cachorrinho Pipoca em uma pequena aventura pelo jardim, onde descobrem que os melhores tesouros estão nos momentos compartilhados com quem amamos.\r\n\r\nUma história leve e divertida, ideal para incentivar a imaginação etransmitir valores importantes às crianças.",
    categoria: "Infantil"
  },
  {
    titulo: "O Segredo da Cidade Perdida",
    autor: "Autor fictício",
    descricao: "Uma expedição pela Amazônia leva Helena a descobrir uma cidade perdida, escondida há séculos entre montanhas. Guiada por pistas deixadas por seu pai desaparecido, ela enfrenta mistérios, perigos e descobertas surpreendentes. Mas o maior tesouro daquela cidade não é ouro, e sim o conhecimento de uma civilização esquecida. Uma aventura sobre coragem, família e a importância de preservar a história.",
    categoria: "Aventura"
  }
]

livros.each do |dados|
  categoria = Categoria.find_or_create_by!(nome: dados.fetch(:categoria))
  livro = Livro.find_or_initialize_by(titulo: dados.fetch(:titulo))
  livro.assign_attributes(
    autor: dados.fetch(:autor),
    descricao: dados.fetch(:descricao),
    capa_url: nil,
    categoria: categoria,
    usuario_cadastro: usuario_seed
  )
  livro.save!
end
