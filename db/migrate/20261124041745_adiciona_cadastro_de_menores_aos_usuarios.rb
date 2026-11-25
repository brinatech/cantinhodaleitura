# HU-20 (VERSÃO PROPOSTA, aguardando a SESFA): conta de criança/adolescente criada pelo responsável.
# Coleta mínima: nome ou apelido da criança (coluna nome), nome de usuário para entrar (crianças
# costumam não ter e-mail), nome e e-mail do responsável, e quando ele confirmou a autorização.
# Sem data de nascimento, CPF ou documento. Ver docs/decisoes-negocio/cadastro_menores.md.
class AdicionaCadastroDeMenoresAosUsuarios < ActiveRecord::Migration[8.1]
  def change
    add_column :usuarios, :menor, :boolean, default: false, null: false
    add_column :usuarios, :nome_usuario, :string, limit: 30
    add_column :usuarios, :responsavel_nome, :string, limit: 100
    add_column :usuarios, :responsavel_email, :string, limit: 150
    add_column :usuarios, :autorizado_em, :datetime
    add_index :usuarios, :nome_usuario, unique: true
  end
end
