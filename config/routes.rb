Rails.application.routes.draw do
  scope :api, defaults: { format: :json } do
    resources :addons, only: [:index, :update] do
      get 'readme' => 'addons#readme'
    end
    get 'addons/:name' => 'addons#show'
    resources :categories, only: [:index]
    get 'categories/:name' => 'categories#show', as: 'category'
    resources :keywords, only: [:show, :index]
    resources :versions, only: [:show, :index]
    resources :reviews, only: [:show, :create, :index]
    resources :maintainers, only: [:index]
    post 'corrections' => 'corrections#submit'

    scope :authentication do
      post :login, to: 'auth#login'
      post :logout, to: 'auth#logout'
    end
  end
end
