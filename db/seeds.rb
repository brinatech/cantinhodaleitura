# Dados iniciais da biblioteca. Pode ser executado mais de uma vez sem duplicar
# categorias ou livros.

usuario_seed = Usuario.find_by(email: "seed@cantinhodaleitura.local") ||
  Usuario.find_by(tipo_usuario: "administrador") ||
  Usuario.first

usuario_seed ||= Usuario.create!(
  nome: "Cadastro dos livros iniciais",
  email: "seed@cantinhodaleitura.local",
  password: SecureRandom.hex(32),
  tipo_usuario: "administrador",
  data_cadastro: Time.current
)

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

  pasta_arquivos = Rails.root.join("db/seeds/arquivos/livros", dados.fetch(:titulo).parameterize)
  caminho_capa = pasta_arquivos.join("capa.jpg")
  if File.file?(caminho_capa)
    mesma_capa = livro.capa.attached? &&
      livro.capa.filename.to_s == "capa.jpg" &&
      livro.capa.blob.byte_size == File.size(caminho_capa) &&
      livro.capa.blob.service.exist?(livro.capa.blob.key)
    unless mesma_capa
      File.open(caminho_capa, "rb") do |arquivo|
        livro.capa.attach(io: arquivo, filename: "capa.jpg", content_type: "image/jpeg")
      end
    end
  end

  { "livro.pdf" => [ "texto", "application/pdf" ], "audio.mp3" => [ "audio", "audio/mpeg" ] }.each do |nome, (tipo, content_type)|
    caminho_arquivo = pasta_arquivos.join(nome)
    next unless File.file?(caminho_arquivo)

    material = ArquivoMaterial.find_or_initialize_by(livro: livro, tipo: tipo)
    mesmo_arquivo = material.arquivo.attached? &&
      material.arquivo.filename.to_s == nome &&
      material.arquivo.blob.byte_size == File.size(caminho_arquivo) &&
      material.arquivo.blob.service.exist?(material.arquivo.blob.key)
    unless mesmo_arquivo
      File.open(caminho_arquivo, "rb") do |arquivo|
        material.arquivo.attach(io: arquivo, filename: nome, content_type: content_type)
      end
    end
    material.save!
  end
end
