Rails.application.routes.draw do
  scope :api, defaults: { format: :json } do
    resources :evaluations
    resources :metrics
    resources :reviews
    resources :packages
  end
end
