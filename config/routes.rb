Rails.application.routes.draw do
  resources :category_packages

  scope :api, defaults: { format: :json } do
    resources :evaluations
    resources :metrics
    resources :reviews
    resources :packages
    resources :categories
  end
end
