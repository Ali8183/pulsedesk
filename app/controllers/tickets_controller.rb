# frozen_string_literal: true

class TicketsController < ApplicationController
  before_action :require_agent!, except: %i[index]
  before_action :set_ticket, only: %i[show transition assign simulate_time_travel]

  def index
    unless agent_signed_in?
      render "sessions/new"
      return
    end

    # Tüm biletlerin SLA durumunu arka planda kontrol et
    Ticket.where(status: %i[status_new status_open status_pending], sla_breached: false).find_each do |t|
      t.check_sla_breach!
    end

    @tickets = Ticket.all.order(created_at: :desc)

    # Filtreleme
    case params[:filter]
    when "open"
      @tickets = @tickets.where(status: %i[status_new status_open status_pending])
    when "solved"
      @tickets = @tickets.where(status: %i[status_solved status_closed])
    when "closed"
      @tickets = @tickets.where(status: :status_closed)
    when "breached"
      @tickets = @tickets.where(sla_breached: true)
    end

    # İstatistikler (SaaS KPI Paneli)
    @total_count     = Ticket.count
    @open_count      = Ticket.where(status: %i[status_new status_open status_pending]).count
    @solved_count    = Ticket.where(status: %i[status_solved status_closed]).count
    @breached_count  = Ticket.where(sla_breached: true).count
    @gratitude_saves = Ticket.sum(:gratitude_count)
  end

  def show
    @ticket.check_sla_breach!
    @comments = @ticket.comments.order(created_at: :asc)
    @new_comment = @ticket.comments.build(author_name: current_agent, author_role: "agent")
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.save
      redirect_to @ticket, notice: "Destek talebi başarıyla oluşturuldu. SLA geri sayımı başlatıldı."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Aort Dilimi Durum Geçiş Aksiyonu
  def transition
    target = params[:target_status]

    if @ticket.transition_to!(target)
      redirect_to @ticket, notice: "Bilet durumu '#{@ticket.human_status_name}' olarak güncellendi."
    else
      redirect_to @ticket, alert: @ticket.errors[:status].first || "Geçersiz durum geçişi."
    end
  end

  # Temsilci Atama Aksiyonu
  def assign
    agent = params[:agent_name].to_s.strip
    if agent.present?
      @ticket.assigned_agent = agent
      @ticket.status = :status_open if @ticket.status_new?
      @ticket.save!
      redirect_to @ticket, notice: "Bilet '#{agent}' temsilcisine atandı ve 'Açık' durumuna alındı."
    else
      redirect_to @ticket, alert: "Lütfen bir temsilci seçin."
    end
  end

  # SUNUM İÇİN ZAMAN MAKİNESİ SİMÜLATÖRÜ:
  # Sunumda 2-4 saat beklemek mümkün olmadığından, tek tıkla SLA'i geçmişe alıp breach'i gösterir
  def simulate_time_travel
    @ticket.update_columns(
      sla_due_at: 15.minutes.ago,
      sla_breached: true
    )
    redirect_to @ticket, alert: "⚡ Zaman Makinesi Tetiklendi: SLA süresi geriye çekildi ve SLA İHLALİ (Breach) simüle edildi!"
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description, :customer_name, :customer_email, :priority, :assigned_agent)
  end
end
