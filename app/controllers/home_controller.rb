# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @total_tickets = Ticket.count
    @open_tickets = Ticket.where(status: [:status_new, :status_open, :status_pending]).count
    @gratitude_saves = Ticket.sum(:gratitude_count)
    @breached_count = Ticket.where(sla_breached: true).count
  end
end
