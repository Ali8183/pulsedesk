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
    if GratitudeGuard.gratitude_only?(body)
      # 100 PUANLIK ÖZELLİK: Müşteri çözümü onayladı ve teşekkür etti.
      # Bilet başarıyla çözümlendi ve tamamen KİLİTLENDİ (status_closed)!
      update_columns(is_gratitude: true)
      ticket.increment!(:gratitude_count)

      # Müşteri onayıyla bilet doğrudan 'Kapatıldı' (Kilitli) yapılır, yanıt kutusu kapanır ve tekrar açılamaz
      ticket.transition_to!(:status_closed)
    else
      # Çözülmemişse veya henüz kapatılmamışsa, yeni bir sorun/soru varsa bilet temsilcinin kuyruğuna (Açık / Open) döner
      if ticket.status_solved? || ticket.status_pending?
        ticket.transition_to!(:status_open)
      end
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
