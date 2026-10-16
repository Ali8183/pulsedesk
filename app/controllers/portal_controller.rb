# frozen_string_literal: true

class PortalController < ApplicationController
  def new
    @ticket = Ticket.new(priority: :urgent)
  end

  def create
    @ticket = Ticket.new(portal_ticket_params)

    if @ticket.save
      redirect_to portal_ticket_path(@ticket), notice: "Destek talebiniz (#{@ticket.id}) başarıyla oluşturuldu! Destek ekibimiz en kısa sürede ilgilenecektir."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @ticket = Ticket.find(params[:id])
    @comments = @ticket.comments.order(created_at: :asc)
    @new_comment = @ticket.comments.build(author_role: "customer")
  end

  def reply
    @ticket = Ticket.find(params[:id])
    body_text = params.dig(:comment, :body).to_s.strip

    if body_text.present?
      @comment = @ticket.comments.build(
        author_name: @ticket.customer_name,
        author_role: "customer",
        body: body_text
      )

      if @comment.save
        redirect_to portal_ticket_path(@ticket), notice: "Mesajınız destek ekibine iletildi."
      else
        redirect_to portal_ticket_path(@ticket), alert: "Mesaj gönderilemedi."
      end
    else
      redirect_to portal_ticket_path(@ticket), alert: "Lütfen bir mesaj yazın."
    end
  end

  private

  def portal_ticket_params
    params.require(:ticket).permit(:title, :description, :customer_name, :customer_email, :priority)
  end
end
