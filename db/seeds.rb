# frozen_string_literal: true

# Tüm biletleri ve yorumları temizle - Canlı sunum ve test için veritabanı boş başlar
puts "Tüm biletler ve mesaj geçmişi temizleniyor..."
Comment.destroy_all
Ticket.destroy_all
puts "Veritabanı sıfırlandı: Sistemde #{Ticket.count} bilet bulunuyor."
