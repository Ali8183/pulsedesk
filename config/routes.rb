# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # 1. Ana Karşılama Sayfası (Genel Bilgilendirme)
  root "home#index"

  # 2. MÜŞTERİ GİRİŞ SAYFASI & PORTALI (Sadece Müşteriye Özel URL: /musteri)
  get  "musteri",         to: "portal#new",    as: :customer_portal
  get  "portal",          to: "portal#new",    as: :portal
  post "portal",          to: "portal#create"
  get  "musteri/sorgula", to: "portal#lookup", as: :customer_lookup
  get  "portal/tickets/:id",       to: "portal#show",  as: :portal_ticket
  post "portal/tickets/:id/reply", to: "portal#reply", as: :portal_reply

  # 3. YETKİLİ TEMSİLCİ GİRİŞ SAYFASI (Sadece Personele Özel URL: /temsilci)
  get    "temsilci",     to: "sessions#new",     as: :agent_portal
  get    "agent/login",  to: "sessions#new",     as: :agent_login
  post   "agent/login",  to: "sessions#create"
  delete "agent/logout", to: "sessions#destroy", as: :agent_logout

  # 4. TEMSİLCİ YÖNETİM MASASI (Sadece Oturum Açmış Personele Özel)
  resources :tickets do
    member do
      patch :transition
      patch :assign
      post :simulate_time_travel
    end
    resources :comments, only: [:create]
  end
end
