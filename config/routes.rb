Rails.application.routes.draw do
  scope :api, defaults: { format: :json } do
    resources :addons
    resources :categories
    resources :keywords
    resources :versions, only: [:show, :index]
    get 'reviews/:id', to: 'reviews#show'

    scope :authentication do
      post :login, to: 'auth#login'
      post :logout, to: 'auth#logout'
    end
  end
end
