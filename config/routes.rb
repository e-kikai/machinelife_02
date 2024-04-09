Rails.application.routes.draw do
  get 'catalogs/show'
  ### health check ###
  get "up" => "rails/health#show", as: :rails_health_check

  ### root ###
  root "main#index"

  ### machine ###
  resources :companies, only: [:index, :show]
  resources :machines do
    get "large_genre/:large_genre_id" => "machines#large_genre", on: :collection
    get "genre/:genre_id"             => "machines#genre",       on: :collection
    get "company/:company_id"         => "machines#company",     on: :collection
    get "maker/:maker"                => "machines#maker",       on: :collection
  end
  resources :contacts, only: [:new, :create, :index, :edit, :update]
  resources :helps, only: [:index, :show]
  get "sitemap" => "helps#sitemap"
  resources :zenkiren, only: [:index, :show]

  get "/news/:target" => "machines#news"

  resources :catalogs, only: [:show]

  ### admin ###
  namespace :admin do
    root "main#index"

    get    "/login"  => "sessions#new"
    post   "/login"  => "sessions#create"
    delete "/logout" => "sessions#destroy"

    resources :machines, only: [:index, :new, :edit, :create, :update, :delete] do
      collection do
        get :catalog_search
        get :genre_specs
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
      get "all", on: :collection
    end

    resources :xl_genres, only: [:index, :new, :show, :create, :edit, :update, :destroy]
    resources :large_genres, only: [:new, :show, :create, :edit, :update, :destroy]
    resources :genres, only: [:new, :create, :edit, :update, :destroy]

    namespace :catalogs do
      get   :csv
      post  "csv" => :csv_upload
      patch "csv" => :csv_import
    end

    namespace :machines do
      get   :csv
      post  "csv" => :csv_upload
      patch "csv" => :csv_import
    end

    resources :crawler, only: [:edit, :update]
  end
end
