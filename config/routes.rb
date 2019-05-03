Rails.application.routes.draw do
  scope :api, defaults: { format: :json } do
    resources :test_results, only: [:create]

    post 'build_queue/get_build' => 'build_queue#get_build'
    post 'test_results/:id/retry' => 'test_results#retry'

    post 'size_calculation_queue' => 'size_calculation_queue#get_calculation'
  end

  post 'api/v2/test_results/:id/retry' => 'test_results#retry'
  namespace :api do
    namespace :v2 do
      get 'autocomplete_data' => 'autocomplete#data'
      get 'search' => 'search#search'
      get 'search/addons' => 'search#addons'
      get 'search/source' => 'search#source'
      post 'corrections' => 'corrections#submit'

      jsonapi_resources :addons do
        jsonapi_related_resources :github_stats
        jsonapi_related_resources :readme
        jsonapi_related_resources :github_users
        jsonapi_related_resources :latest_review
      end

      jsonapi_resources :score_calculations, only: [:index] do
        # This block intentionally left empty to not generate relationship routes
      end

      jsonapi_resources :reviews, only: [:create] do
        jsonapi_related_resources :version
      end

      jsonapi_resources :categories do
        # This block intentionally left empty to not generate relationship routes
      end

      jsonapi_resources :maintainers, only: [:index] do
        jsonapi_related_resources :addons
      end

      jsonapi_resources :addon_dependencies do
        # This block intentionally left empty to not generate relationship routes
      end

      jsonapi_resources :ember_versions, only: [:index] do
        # This block intentionally left empty to not generate relationship routes
      end

      jsonapi_resources :test_results do
        jsonapi_related_resources :version
      end

      jsonapi_resources :build_servers

      scope :authentication do
        post :login, to: 'auth#login'
        post :logout, to: 'auth#logout'
      end
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
