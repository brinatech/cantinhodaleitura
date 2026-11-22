Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :usuarios, only: [ :create ]
      resource :sessao, only: [ :show, :create, :destroy ]
      resource :recuperacao_senha, only: [ :create, :update ], controller: "recuperacoes_senha"
      resource :perfil, only: [ :show, :update ], controller: "perfil" do
        patch :senha
      end
      resources :livros, only: [ :index, :show ] do
        resources :arquivos, only: :show, controller: "arquivos"
      end
      # Favoritos de quem está logado. O DELETE usa o número do livro: /favoritos/:livro_id
      resources :favoritos, only: [ :index, :create, :destroy ], param: :livro_id

      namespace :admin do
        resources :livros, only: [ :index, :create, :update, :destroy ] do
          resources :classificacoes, only: [ :index, :create, :destroy ]
        end
        resources :categorias, only: [ :index, :show, :create, :update, :destroy ]
      end
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
