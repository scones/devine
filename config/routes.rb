Rails.application.routes.draw do


  namespace :webhooks do
    resources :github, only: :create
  end
end
