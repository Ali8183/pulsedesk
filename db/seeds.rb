# frozen_string_literal: true

puts "Clearing existing tickets and comments..."
Comment.destroy_all
Ticket.destroy_all

puts "Seeding PulseDesk demo data..."

# 1. Yeni Bilet (Atanmamış)
t1 = Ticket.create!(
  title: "API Webhook bildirimleri gecikmeli ulaşıyor",
  description: "Sistemimizden dönen ödeme onay webhook'ları son 2 saattir 15 dakika rötarla geliyor. Üretim ortamımızı etkiliyor.",
  customer_name: "Emre Aktaş",
  customer_email: "emre.aktas@enterprise-corp.com",
  priority: :urgent
)

# 2. Açık Bilet (Temsilci atanmış, SLA işliyor)
t2 = Ticket.create!(
  title: "SSO SAML entegrasyonunda sertifika yenileme",
  description: "Okta üzerinden SSO ile giriş yapan çalışanlarımız için IdP sertifikası yenilendi. Test ortamında doğrulamak istiyoruz.",
  customer_name: "Zeynep Kaya",
  customer_email: "zeynep.kaya@fintech-labs.io",
  priority: :high,
  assigned_agent: "Selin Yılmaz"
)
t2.transition_to!(:status_open)
t2.comments.create!(
  author_name: "Selin Yılmaz",
  author_role: "agent",
  body: "Merhaba Zeynep Hanım, yeni XML metadata dosyanızı test sunucumuza yükledik. Lütfen kontrol edebilir misiniz?"
)

# 3. Çözülmüş Bilet & Nezaket Koruması (Gratitude Guard)
t3 = Ticket.create!(
  title: "Fatura adresi ve vergi numarası güncelleme talebi",
  description: "Şirket ünvanımız değişti, son faturanın yeni bilgilerle düzenlenmesini talep ediyoruz.",
  customer_name: "Murat Demir",
  customer_email: "murat.demir@global-logistics.com",
  priority: :medium,
  assigned_agent: "Ahmet Kaya"
)
t3.transition_to!(:status_open)
t3.comments.create!(
  author_name: "Ahmet Kaya",
  author_role: "agent",
  body: "Merhaba Murat Bey, şirket bilgilerinizi güncelledik ve düzeltilmiş e-faturanızı e-posta ile ilettik."
)
t3.transition_to!(:status_solved)

# Müşteri teşekkür etti -> Gratitude Guard devreye girer ve çözüldü kalır
t3.comments.create!(
  author_name: "Murat Demir",
  author_role: "customer",
  body: "Çok teşekkür ederim Ahmet Bey, elinize sağlık harika bir destek oldu!"
)

# 4. SLA İhlali (Breached) Simüle Edilmiş Bilet
t4 = Ticket.create!(
  title: "Veritabanı yedeği indirme linki geçersiz",
  description: "Haftalık PostgreSQL yedek arşivini indiremiyoruz, 403 Forbidden dönüyor.",
  customer_name: "Deniz Arslan",
  customer_email: "deniz@cloud-scale.net",
  priority: :urgent,
  assigned_agent: "Ahmet Kaya"
)
t4.transition_to!(:status_open)
t4.update_columns(
  sla_due_at: 2.hours.ago,
  sla_breached: true
)

puts "Seeding completed successfully! #{Ticket.count} tickets created."
