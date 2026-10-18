# frozen_string_literal: true

class Ticket < ApplicationRecord
  has_many :comments, -> { order(created_at: :asc) }, dependent: :destroy

  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }, prefix: true
  enum :status, {
    status_new: 0,
    status_open: 1,
    status_pending: 2,
    status_solved: 3,
    status_closed: 4
  }

  validates :title, presence: true, length: { maximum: 120 }
  validates :description, presence: true
  validates :customer_name, presence: true
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :set_sla_defaults, on: :create

  # Durum geçiş matrisi (Aort Dilimi Durum Akışı)
  ALLOWED_TRANSITIONS = {
    "status_new"     => %w[status_open],
    "status_open"    => %w[status_pending status_solved status_closed],
    "status_pending" => %w[status_open status_solved status_closed],
    "status_solved"  => %w[status_open status_closed],
    "status_closed"  => [] # Kapalı biletler değiştirilemez
  }.freeze

  def can_transition_to?(target_status)
    return true if status == target_status.to_s

    allowed = ALLOWED_TRANSITIONS[status] || []
    allowed.include?(target_status.to_s)
  end

  def transition_to!(target_status)
    target_str = target_status.to_s
    unless can_transition_to?(target_str)
      errors.add(:status, "'#{human_status_name(status)}' durumundan '#{human_status_name(target_str)}' durumuna geçişe izin verilmiyor.")
      return false
    end

    self.status = target_str
    if target_str == "status_solved" || (target_str == "status_closed" && resolved_at.blank?)
      self.resolved_at ||= Time.current
    end
    save!
  end

  # Zaman Kuralı (SLA Kontrolü)
  def sla_breached?
    # Eğer önceden aşılmışsa true
    return true if read_attribute(:sla_breached)

    # Çözülmüş veya kapatılmış biletler geçmişteki durumunu korur
    return false if status_solved? || status_closed?
    return false if sla_due_at.blank?

    # Anlık zaman SLA süresini geçtiyse true
    Time.current > sla_due_at
  end

  # Arka plan job veya periyodik kontrolde veritabanını günceller
  def check_sla_breach!
    return false if status_solved? || status_closed?
    return false if sla_due_at.blank?

    if Time.current > sla_due_at && !read_attribute(:sla_breached)
      update_columns(sla_breached: true)
      true
    else
      false
    end
  end

  # Arayüz için SLA geri sayım süresi (saniye)
  def sla_remaining_seconds
    return 0 if sla_due_at.blank?

    [0, (sla_due_at - Time.current).to_i].max
  end

  # Arayüz renk göstergesi:
  # :breached -> Kırmızı alarm (SLA aşıldı)
  # :warning  -> Sarı/Turuncu (Son 1 saat kaldı)
  # :normal   -> Yeşil (Güvenli zaman aralığı)
  # :resolved -> Çözüldü / SLA durduruldu
  def sla_urgency_level
    return :resolved if status_solved? || status_closed?
    return :breached if sla_breached?

    rem = sla_remaining_seconds
    if rem <= 1800 # Son 30 dakika kaldıysa sarı/turuncu uyarı
      :warning
    else
      :normal
    end
  end

  def human_status_name(s = status)
    case s.to_s
    when "status_new"     then "Yeni"
    when "status_open"    then "Açık"
    when "status_pending" then "Yanıt Bekleniyor"
    when "status_solved"  then "Çözüldü"
    when "status_closed"  then "Kapatıldı"
    else s.to_s.humanize
    end
  end

  def human_priority_name
    case priority
    when "low"    then "Düşük"
    when "medium" then "Normal"
    when "high"   then "Yüksek"
    when "urgent" then "Acil"
    else priority.to_s.humanize
    end
  end

  private

  def set_sla_defaults
    # Önceliğe göre SLA süresini her zaman hesapla
    calculated_hours = SlaCalculator.hours_for(priority)
    self.sla_hours = calculated_hours
    self.sla_due_at = SlaCalculator.calculate_due_at(priority, created_at || Time.current)
    self.status ||= :status_new
    self.gratitude_count ||= 0
  end
end
