# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # 1. Ana Karşılama Sayfası (Landing Page)
  root "home#index"

  # 2. MÜŞTERİ TARAFI (SADECE /musteri)
  get    "musteri",                 to: "musteri#index",  as: :musteri
  post   "musteri/giris",           to: "musteri#login",  as: :musteri_giris
  delete "musteri/cikis",           to: "musteri#logout", as: :musteri_cikis
  post   "musteri/talep",           to: "musteri#create", as: :musteri_talep
  get    "musteri/talep/:id",       to: "musteri#show",   as: :musteri_ticket
  post   "musteri/talep/:id/cevap", to: "musteri#reply",  as: :musteri_cevap

  # 3. TEMSİLCİ TARAFI (SADECE /temsilci)
  get    "temsilci",                 to: "tickets#index",       as: :temsilci
  post   "temsilci/giris",           to: "sessions#create",     as: :temsilci_giris
  delete "temsilci/cikis",           to: "sessions#destroy",    as: :temsilci_cikis

  # Temsilci Bilet Operasyonları (CRUD, Durum Geçişi, Atama, SLA Zaman Makinesi)
  resources :tickets do
    member do
      patch :transition
      patch :assign
      post :simulate_time_travel
    end
    resources :comments, only: [:create]
  end

  # URL Konsolidasyonu ve Geriye Dönük Uyumluluk (4 URL Karmaşasını Ortadan Kaldırır)
  get    "agent/login",  to: redirect("/temsilci"), as: :agent_login
  get    "agent_portal", to: redirect("/temsilci"), as: :agent_portal
  post   "agent/login",  to: "sessions#create"
  delete "agent/logout", to: "sessions#destroy", as: :agent_logout

  get  "portal",                   to: redirect("/musteri"), as: :customer_portal
  get  "portal/new",               to: redirect("/musteri"), as: :portal
  get  "portal/tickets/:id",       to: redirect("/musteri/talep/%{id}"), as: :portal_ticket
  post "portal/tickets/:id/reply", to: "musteri#reply", as: :portal_reply
  get  "musteri/sorgula",          to: redirect("/musteri"), as: :customer_lookup
end

