Rails.application.routes.draw do
  scope :api, defaults: { format: :json } do
    resources :addons, only: [:index, :update]
    get 'hidden' => 'addons#hidden'
    get 'addons/:name' => 'addons#show'
    resources :categories, only: [:index, :create, :update]
    get 'categories/:name' => 'categories#show'
    resources :keywords, only: [:show, :index]
    resources :versions, only: [:show, :index]
    resources :reviews, only: [:show, :create, :index]
    resources :maintainers, only: [:index]
    post 'corrections' => 'corrections#submit'
    get 'search/addons' => 'search#addons'
    get 'search/source' => 'search#source'

    resources :build_servers, only: [:index, :create, :update, :destroy]
    resources :test_results, only: [:index, :create, :show]

    post 'build_queue/get_build' => 'build_queue#get_build'
    post 'test_results/:id/retry' => 'test_results#retry'

    get 'search' => 'search#search'

    scope :authentication do
      post :login, to: 'auth#login'
      post :logout, to: 'auth#logout'
    end
  end

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
        jsonapi_related_resources :reviews
      end

      jsonapi_resources :reviews, only: [:create] do
        # This block intentionally left empty to not generate relationship routes
      end

      jsonapi_resources :categories do
        # This block intentionally left empty to not generate relationship routes
      end

      jsonapi_resources :maintainers, only: [:index] do
        jsonapi_related_resources :addons
      end

      jsonapi_resources :test_results do
        jsonapi_related_resources :version
      end
    end
  end
end
