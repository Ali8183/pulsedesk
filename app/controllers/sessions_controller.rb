# frozen_string_literal: true

class SessionsController < ApplicationController
  AGENTS = {
    "ahmet@pulsedesk.com" => { name: "Ahmet Kaya", title: "Kıdemli Destek Uzmanı" },
    "selin@pulsedesk.com" => { name: "Selin Yılmaz", title: "Destek Temsilcisi" },
    "elif@pulsedesk.com" => { name: "Elif Tekin", title: "Operasyon Lideri" }
  }.freeze

  def new
    if agent_signed_in?
      redirect_to tickets_path, notice: "Zaten #{current_agent} olarak oturumunuz açık."
    end
  end

  def create
    email = params[:email].to_s.strip.downcase
    password = params[:password].to_s.strip
    agent_info = AGENTS[email]

    # Şifre kontrolü: 'admin' veya 'pulsedesk123' geçerli
    if agent_info && (password == "admin" || password == "pulsedesk123" || params[:quick_login].present?)
      session[:agent_email] = email
      session[:agent_name] = agent_info[:name]
      session[:agent_title] = agent_info[:title]

      redirect_to tickets_path, notice: "Hoş geldiniz, #{agent_info[:name]}. Temsilci masasına başarıyla giriş yapıldı."
    else
      flash.now[:alert] = "Geçersiz temsilci e-posta adresi veya şifre. (Demo Şifre: admin)"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:agent_email] = nil
    session[:agent_name] = nil
    session[:agent_title] = nil

    redirect_to root_path, notice: "Temsilci oturumu güvenli bir şekilde kapatıldı."
  end
end
