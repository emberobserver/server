Rails.application.routes.draw do
  resources :category_packages

  scope :api, defaults: { format: :json } do
    resources :packages
    resources :categories
    resources :keywords

    scope :authentication do
      post :login, to: 'auth#login'
      post :logout, to: 'auth#logout'
    end
  end
end
