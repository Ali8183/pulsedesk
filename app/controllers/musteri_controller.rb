# frozen_string_literal: true

class MusteriController < ApplicationController
  before_action :require_customer!, only: %i[create show reply]

  def index
    if customer_signed_in?
      @tickets = Ticket.where("LOWER(customer_email) = ?", current_customer_email.downcase).order(created_at: :desc)
      @new_ticket = Ticket.new(customer_name: current_customer_name, customer_email: current_customer_email, priority: :urgent)
    else
      # Müşteri giriş ekranına gelindiğinde eski yetkili oturum artıklarını temizle
      session[:agent_name] = nil
      session[:agent_email] = nil
      session[:agent_title] = nil
      @tab = params[:tab] == "register" ? "register" : "login"
      render :login
    end
  end

  def login
    email = params[:email].to_s.strip.downcase

    if email.present?
      session[:customer_email] = email
      existing_ticket = Ticket.where("LOWER(customer_email) = ?", email).order(created_at: :desc).first
      session[:customer_name] = params[:name].presence || existing_ticket&.customer_name || email.split("@").first.titleize

      redirect_to root_path, notice: "Hoş geldiniz, #{session[:customer_name]}. Destek paneliniz açıldı."
    else
      flash.now[:alert] = "Lütfen geçerli bir e-posta adresi girin."
      @tab = "login"
      render :login, status: :unprocessable_entity
    end
  end

  def register
    email = params[:email].to_s.strip.downcase
    name = params[:name].to_s.strip

    if email.present? && name.present?
      session[:customer_email] = email
      session[:customer_name] = name

      redirect_to root_path, notice: "Hesabınız başarıyla oluşturuldu! Hoş geldiniz, #{name}."
    else
      flash.now[:alert] = "Lütfen adınızı ve e-posta adresinizi eksiksiz girin."
      @tab = "register"
      render :login, status: :unprocessable_entity
    end
  end

  def logout
    session[:customer_email] = nil
    session[:customer_name] = nil
    session[:agent_name] = nil
    session[:agent_email] = nil
    session[:agent_title] = nil
    redirect_to root_path, notice: "Müşteri oturumunuz güvenli bir şekilde kapatıldı."
  end

  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.customer_email = current_customer_email
    @ticket.customer_name = current_customer_name

    if @ticket.save
      redirect_to musteri_ticket_path(@ticket), notice: "Destek talebiniz (#{@ticket.id}) başarıyla oluşturuldu! Destek ekibimiz en kısa sürede ilgilenecektir."
    else
      @tickets = Ticket.where("LOWER(customer_email) = ?", current_customer_email.downcase).order(created_at: :desc)
      @new_ticket = @ticket
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @ticket = Ticket.find(params[:id])
    unless @ticket.customer_email.to_s.downcase == current_customer_email.downcase
      redirect_to musteri_path, alert: "Yalnızca kendi açtığınız destek taleplerini görüntüleyebilirsiniz."
      return
    end

    @comments = @ticket.comments.order(created_at: :asc)
    @new_comment = @ticket.comments.build(author_name: current_customer_name, author_role: "customer")
  end

  def reply
    @ticket = Ticket.find(params[:id])
    unless @ticket.customer_email.to_s.downcase == current_customer_email.downcase
      redirect_to musteri_path, alert: "Yetkisiz işlem."
      return
    end

    if @ticket.status_closed?
      redirect_to musteri_ticket_path(@ticket), alert: "Bu destek talebi kapatılmıştır ve arşivlenmiştir. Yeni bir sorun için lütfen yeni bir talep oluşturun."
      return
    end

    body_text = params.dig(:comment, :body).to_s.strip
    if body_text.present?
      @comment = @ticket.comments.build(
        author_name: current_customer_name,
        author_role: "customer",
        body: body_text
      )

      if @comment.save
        if @comment.is_gratitude?
          redirect_to musteri_ticket_path(@ticket), notice: "✨ Akıllı Nezaket Koruması: Teşekkür mesajınız kaydedildi. Bilet 'Çözüldü' durumunda tutuldu!"
        elsif @ticket.reload.status_open?
          redirect_to musteri_ticket_path(@ticket), alert: "⚠️ Sorununuzun devam ettiği algılandı. Bilet temsilcinin kuyruğuna yeniden 'Açık' olarak iletildi."
        else
          redirect_to musteri_ticket_path(@ticket), notice: "Mesajınız destek ekibine iletildi."
        end
      else
        redirect_to musteri_ticket_path(@ticket), alert: "Mesaj gönderilemedi."
      end
    else
      redirect_to musteri_ticket_path(@ticket), alert: "Lütfen bir mesaj yazın."
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :description, :priority)
  end
end
