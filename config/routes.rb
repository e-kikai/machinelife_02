Rails.application.routes.draw do
  constraints ->(req) { req.host.exclude?("daihou") && req.host.exclude?("org") } do
    ### health check ###
    get "up" => "rails/health#show", as: :rails_health_check

    ### root ###
    root "main#index"

    get "feed" => "main#feed"
    # get "admin_mail_feed" => "main#admin_mail_feed"

    ### machine ###
    resources :companies, only: [:index, :show]
    get  "/products/:id" => redirect("/machines/%{id}")
    get  "/products/large_genre/:id" => redirect("/machines/large_genre/%{id}")
    get  "/products/genre/:id" => redirect("/machines/genre/%{id}")
    get  "/products/company/:id" => redirect("/machines/company/%{id}")
    get  "/products/maker/:id" => redirect("/machines/maker/%{id}")

    resources :machines do
      get "large_genre/:large_genre_id" => "machines#large_genre", on: :collection
      get "genre/:genre_id"             => "machines#genre",       on: :collection
      get "company/:company_id"         => "machines#company",     on: :collection
      get "maker/:maker"                => "machines#maker",       on: :collection
      get "addr1/:addr1"                => "machines#addr1",       on: :collection
    end
    resources :contacts, only: [:new, :create, :index, :edit, :update]
    resources :helps, only: [:index, :show]
    get "sitemap" => "helps#sitemap"

    get "/news/:target" => "machines#news"
    get "/news/:target/:date" => "machines#news"
    get "/news/:target/:date/:week" => "machines#news"

    resources :catalogs, only: [:show]

    ### admin ###
    namespace :admin do
      root "main#index"

      get    "/login"  => "sessions#new"
      post   "/login"  => "sessions#create"
      delete "/logout" => "sessions#destroy"

      resources :machines, only: [:index, :new, :edit, :create, :update] do
        collection do
          get :catalog_search
          get :genre_specs
          delete :delete_all
        end
      end
      resources :contacts, only: [:index]
      resource :company, only: [:edit, :update]
      resource :user, only: [:edit, :update]
      resources :urikais, only: [:index, :new, :create, :update, :show]
      resources :catalogs, only: [:index, :create] do
        collection do
          get :search
          get :manuals
        end
      end
      resource :miniblogs, only: [:create]

      resources :d_infos, only: [:index, :new, :create, :edit, :update, :destroy]
    end

    ### system ###
    namespace :system do
      mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

      root "main#index"

      resources :users,     only: [:index, :new, :create, :edit, :update, :destroy]
      resources :companies, only: [:index, :new, :create, :edit, :update, :destroy] do
        get "pdf", on: :collection
        post "login", on: :member
      end
      resources :bidinfos, only: [:index, :new, :create, :edit, :update, :destroy]
      resources :infos,    only: [:index, :new, :create, :edit, :update, :destroy]
      resources :catalog_requests, only: [:index]
      resources :contacts, only: [:index] do
        collection do
          get :all
          get :total
          get :formula
        end
      end

      resources :xl_genres, only: [:index, :new, :show, :create, :edit, :update, :destroy]
      resources :large_genres, only: [:new, :show, :create, :edit, :update, :destroy]
      resources :genres, only: [:new, :create, :edit, :update, :destroy]
      resources :mails, only: [:index, :new, :create] do
        collection do
          get   :ignore
          patch "ignore" => :ignore_update
        end
      end
      resources :detail_logs, only: [:index]
      resources :catalog_logs, only: [:index]
      resources :search_logs, only: [:index]

      namespace :catalogs do
        get   :csv
        post  :csv_upload
        get   :csv_confirm
        patch :csv_import
        get   :sftp
      end

      namespace :machines do
        get   :csv
        post  :csv_upload
        get   :csv_confirm
        patch :csv_import
      end

      namespace :crawler do
        get ":id/:company" => :edit
        patch ":id/:company" => :update
        get "auction_show"
      end

      resources :machine_nitamonos, only: [:new, :create]
    end

    ### playground ###
    namespace :playground do
      resources :openai_test01, only: [:index, :create]
    end
  end

  ### daihou ###
  constraints ->(req) { req.host.include?("daihou") } do
    namespace :daihou, path: nil do
      ### health check ###
      get "up" => "rails/health#show", as: :rails_health_check

      root "main#index"

      get "access" => "main#access"

      resource :company, only: [:show]
      resource :contact, only: [:show, :new, :create]
      resources :machines, only: [:index, :show]
      resources :infos, only: [:index, :show]
    end
  end

  ### 全機連 ###
  constraints ->(req) { req.host.include?("org") } do
    namespace :zenkiren, path: nil do
      ### health check ###
      get "/up" => "rails/health#show", as: :rails_health_check
      root "main#index"
      get "/:page" => "main#show"

      resources :companies, only: [] do
        collection do
          get :tokyo
          get :osaka
          get :chubu
        end
      end
    end
  end

  # すべての未知のルートを404エラーページへリダイレクト
  match '*path', to: 'errors#not_found', via: :all
end
