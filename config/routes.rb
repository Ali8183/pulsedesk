# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # 1. MÜŞTERİ TARAFI (Ana Sayfa / ve /musteri Doğrudan Müşteri Portalıdır)
  root "musteri#index"

  get    "musteri",                 to: "musteri#index",    as: :musteri
  post   "musteri/giris",           to: "musteri#login",    as: :musteri_giris
  post   "musteri/kayit",           to: "musteri#register", as: :musteri_kayit
  delete "musteri/cikis",           to: "musteri#logout",   as: :musteri_cikis
  post   "musteri/talep",           to: "musteri#create",   as: :musteri_talep
  get    "musteri/talep/:id",       to: "musteri#show",     as: :musteri_ticket
  post   "musteri/talep/:id/cevap", to: "musteri#reply",    as: :musteri_cevap

  # 2. TEMSİLCİ TARAFI (SADECE /temsilci - Kullanıcı elle URL'yi /temsilci yaparak girer)
  get    "temsilci",                 to: "tickets#index",       as: :temsilci
  post   "temsilci/giris",           to: "sessions#create",     as: :temsilci_giris
  delete "temsilci/cikis",           to: "sessions#destroy",    as: :temsilci_cikis

  get    "tickets",                  to: redirect("/temsilci")

  # Temsilci Bilet Operasyonları (CRUD, Durum Geçişi, Atama, SLA Zaman Makinesi)
  resources :tickets, except: [:index] do
    member do
      patch :transition
      patch :assign
      post :simulate_time_travel
    end
    resources :comments, only: [:create]
  end

  # Geriye dönük yönlendirmeler
  get    "agent/login",  to: redirect("/temsilci")
  get    "agent_portal", to: redirect("/temsilci")
  post   "agent/login",  to: "sessions#create"
  delete "agent/logout", to: "sessions#destroy"

  get  "portal",       to: redirect("/")
  get  "portal/*path", to: redirect("/")
end

