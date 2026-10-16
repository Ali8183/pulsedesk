# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "tickets#index"

  resources :tickets do
    member do
      patch :transition
      patch :assign
      post :simulate_time_travel
    end
    resources :comments, only: [:create]
  end
end
