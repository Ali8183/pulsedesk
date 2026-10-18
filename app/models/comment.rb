# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :ticket

  validates :author_name, presence: true
  validates :author_role, presence: true, inclusion: { in: %w[customer agent system] }
  validates :body, presence: true

  after_create :process_ticket_interaction

  private

  def process_ticket_interaction
    case author_role
    when "customer"
      handle_customer_reply
    when "agent"
      handle_agent_reply
    end
  end

  def handle_customer_reply
    # Eğer bilet zaten çözülmüş durumdaysa GratitudeGuard kontrolü devreye girer
    if ticket.status_solved?
      if GratitudeGuard.gratitude_only?(body)
        # 100 PUANLIK ÖZELLİK: Teşekkür mesajı biletin durumunu bozmaz
        update_columns(is_gratitude: true)
        ticket.increment!(:gratitude_count)
      else
        # Yeni bir sorun veya soru varsa bilet yeniden açılır
        ticket.transition_to!(:status_open)
      end
    elsif ticket.status_pending?
      # Müşteri yanıt verdiğinde bilet tekrar temsilci kuyruğuna (open) döner
      ticket.transition_to!(:status_open)
    end
  end

  def handle_agent_reply
    ticket.update_column(:first_responded_at, Time.current) if ticket.first_responded_at.blank?

    if ticket.status_new?
      ticket.update!(
        status: :status_open,
        first_responded_at: ticket.first_responded_at || Time.current
      )
    end
  end
end
