# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # 1. Giriş Sayfası (Landing Page)
  root "home#index"

  # 2. Müşteri Alanı (Müşteri Destek Portalı)
  get  "portal", to: "portal#new", as: :portal
  post "portal", to: "portal#create"
  get  "portal/tickets/:id", to: "portal#show", as: :portal_ticket
  post "portal/tickets/:id/reply", to: "portal#reply", as: :portal_reply

  # 3. Temsilci Alanı (Destek Ekibi & Temsilci Masası)
  resources :tickets do
    member do
      patch :transition
      patch :assign
      post :simulate_time_travel
    end
    resources :comments, only: [:create]
  end
end
