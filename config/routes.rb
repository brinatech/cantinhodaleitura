Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :usuarios, only: [ :create ]
      # HU-20 (versão proposta): o responsável cria a conta da criança e confirma pelo link do e-mail
      resources :cadastros_menores, only: [ :create ], controller: "cadastros_menores"
      resources :autorizacoes_menor, only: [ :show, :update, :destroy ], param: :token, controller: "autorizacoes_menor"
      resource :sessao, only: [ :show, :create, :destroy ]
      resource :recuperacao_senha, only: [ :create, :update ], controller: "recuperacoes_senha"
      # Meus dados (HU-21). DELETE = excluir a própria conta (anonimização, pede a senha atual)
      resource :perfil, only: [ :show, :update, :destroy ], controller: "perfil" do
        patch :senha
      end
      resources :livros, only: [ :index, :show ] do
        resources :arquivos, only: :show, controller: "arquivos"
      end
      # Favoritos de quem está logado. O DELETE usa o número do livro: /favoritos/:livro_id
      resources :favoritos, only: [ :index, :create, :destroy ], param: :livro_id
      # Marcador de página de quem está logado, um por livro: GET e PUT /marcadores_pagina/:livro_id
      resources :marcadores_pagina, only: [ :show, :update ], param: :livro_id, controller: "marcadores_pagina"
      # Histórico de quem está logado: GET /historico (lista) e o leitor avisa a página lida em PUT /historico/:livro_id
      resources :historico, only: [ :index, :update ], param: :livro_id, controller: "historico"
      # Listas de leitura de quem está logado, e os livros de cada uma (/listas_leitura/:id/livros/:livro_id)
      resources :listas_leitura, only: [ :index, :show, :create, :update, :destroy ], controller: "listas_leitura" do
        resources :livros, only: [ :create, :destroy ], param: :livro_id, controller: "lista_leitura_livros"
      end

      namespace :admin do
        resources :usuarios, only: [ :index, :update ]
        resources :livros, only: [ :index, :create, :update, :destroy ] do
          resources :classificacoes, only: [ :index, :create, :destroy ]
        end
        resources :categorias, only: [ :index, :show, :create, :update, :destroy ]
        get "relatorios/resumo", to: "relatorios#resumo"
      end
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
