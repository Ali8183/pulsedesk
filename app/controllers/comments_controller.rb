# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :require_agent!

  def create
    @ticket = Ticket.find(params[:ticket_id])

    if @ticket.status_closed?
      redirect_to @ticket, alert: "Kapatılmış ve arşivlenmiş biletlere yeni mesaj eklenemez."
      return
    end

    body_text = params.dig(:comment, :body).to_s.strip
    if body_text.blank?
      redirect_to @ticket, alert: "Lütfen bir yanıt metni girin."
      return
    end

    @comment = @ticket.comments.build(
      author_name: current_agent,
      author_role: "agent",
      body: body_text
    )

    if @comment.save
      @ticket.reload
      @ticket.transition_to!(:status_pending) if @ticket.can_transition_to?(:status_pending)

      redirect_to @ticket, notice: "Yanıtınız başarıyla kaydedildi ve müşteriye iletildi."
    else
      redirect_to @ticket, alert: "Mesaj kaydedilemedi: #{@comment.errors.full_messages.to_sentence}"
    end
  end
end
