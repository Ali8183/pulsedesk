# frozen_string_literal: true

# SLA Hesaplama Servisi (PulseDesk SLA Engine)
#
# SUNUM NOTU - KOD YERİ SORUSU İÇİN:
# "SLA hafta sonlarını veya mesai saatlerini saymasın" değişikliği sorulduğunda:
# Tam olarak bu dosyadaki `calculate_due_at` metoduna (Satır 25-45)
# iş günü / mesai saati hesaplama mantığı eklenir.
class SlaCalculator
  # Öncelik bazlı SLA yanıt/çözüm süreleri (Saat cinsinden)
  SLA_POLICY_HOURS = {
    "urgent" => 2,   # Acil biletler için 2 saat
    "high"   => 4,   # Yüksek öncelikli biletler için 4 saat
    "medium" => 8,   # Normal biletler için 8 saat
    "low"    => 24   # Düşük öncelikli biletler için 24 saat
  }.freeze

  def self.hours_for(priority)
    SLA_POLICY_HOURS[priority.to_s] || 8
  end

  def self.calculate_due_at(priority, from_time = Time.current)
    hours = hours_for(priority)
    # Varsayılan: Takvim saati üzerinden hesaplama.
    # [HOCANIN KOD YERİ SORUSU]: Eğer "Hafta sonları sayılmasın" kuralı istenirse,
    # burada from_time'dan itibaren Cumartesi ve Pazar günleri atlanarak
    # iş günü (business hours) ekleme fonksiyonu çağrılır:
    #
    # target = from_time
    # hours.times do
    #   target += 1.hour
    #   target += 2.days if target.saturday?
    # end
    # target
    from_time + hours.hours
  end

  def self.breached?(ticket, current_time = Time.current)
    return false if ticket.status_solved? || ticket.status_closed?
    return false if ticket.sla_due_at.blank?

    current_time > ticket.sla_due_at
  end
end
