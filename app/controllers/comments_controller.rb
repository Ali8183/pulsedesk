# frozen_string_literal: true

class CommentsController < ApplicationController
  def create
    @ticket = Ticket.find(params[:ticket_id])
    @comment = @ticket.comments.build(comment_params)

    # Önceki durum bilgisini tutalım
    was_solved = @ticket.status_solved?

    if @comment.save
      if @comment.is_gratitude?
        redirect_to @ticket, notice: "✨ Akıllı Nezaket Koruması (Gratitude Guard) Devrede: Müşterinin teşekkür mesajı algılandı. Bilet 'Çözüldü' durumunda tutuldu!"
      elsif was_solved && @ticket.reload.status_open?
        redirect_to @ticket, alert: "⚠️ Müşteri mesajında yeni bir sorun veya soru algılandı. Bilet temsilci incelemesi için yeniden 'Açık' duruma getirildi."
      else
        redirect_to @ticket, notice: "Mesaj başarıyla kaydedildi."
      end
    else
      redirect_to @ticket, alert: "Mesaj kaydedilemedi: #{@comment.errors.full_messages.to_sentence}"
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:author_name, :author_role, :body)
  end
end
