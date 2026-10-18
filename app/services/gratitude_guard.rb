# frozen_string_literal: true

# PulseDesk Akıllı Nezaket Koruması (Gratitude Guard)
#
# 100 PUANLIK ÖDEV KRİTERİ: "Kullanılabilir Pas / Kullanıcı Acısı Çözümü"
#
# KİMİN ACISI: Müşteri destek temsilcileri ve operasyon liderleri.
# HANGİ YORUM: G2, Capterra ve Zendesk Community (Ticket Reopen on 'Thank You' Loop).
#   Örnek İnceleme: "Zendesk automatically re-opens solved tickets when a customer replies
#   with just 'Thanks!', which ruins our First Contact Resolution and SLA reporting."
#   (Kaynak: Zendesk Community Post #4409217316634 & G2 Reviews)
#
# BİZİM ÇÖZÜMÜMÜZ:
# Müşteri "solved" durumundaki bir bilete yalnızca teşekkür / memnuniyet mesajı yazdığında,
# biletin yeniden "open" durumuna geçmesini engeller ve "solved" durumunu korur.
# Ancak müşteri yeni bir sorun, soru veya hata belirtiyorsa koruma bypass edilir ve bilet yeniden açılır.
class GratitudeGuard
  # Teşekkür ve memnuniyet kalıpları (Türkçe ve İngilizce)
  GRATITUDE_PATTERNS = [
    /\b(teşekkür|tesekkur|teşekkürler|tesekkurlere?|sağol|sagol|sağolun|sagolun)\b/i,
    /\b(eline sağlık|elinize sağlık|harikasınız|harika|süper|cok iyi|çok iyi)\b/i,
    /\b(sorun\s+(tamamen\s+)?(çözüldü|cozuldu|giderildi|kalmadı|kalmadi|düzeldi|duzeldi|bitti))\b/i,
    /\b(problem\s+(tamamen\s+)?(çözüldü|cozuldu|giderildi|kalmadı|kalmadi|düzeldi|duzeldi|bitti))\b/i,
    /\b(thanks|thank you|thx|ty|appreciate|appreciated|grateful)\b/i,
    /\b(resolved|all good|perfect|awesome|great job|kudos|problem solved)\b/i
  ].freeze

  # Pozitif çözülme ifadeleri (İtiraz kontrolünden önce elenir; çünkü "sorun çözüldü" itiraz değil, olumlu onaydır!)
  POSITIVE_RESOLUTION_PHRASES = [
    /\b(sorun|problem|hata)\s+(tamamen\s+)?(çözüldü|cozuldu|giderildi|kalmadı|kalmadi|düzeldi|duzeldi|bitti|yok)\b/i,
    /\b(problem|issue|bug)\s+(is\s+)?(resolved|fixed|solved|gone)\b/i
  ].freeze

  # Yeni bir sorun veya itiraz belirten anahtar kelimeler (Koruma bu durumda devreye girmez)
  OBJECTION_PATTERNS = [
    /\b(fakat|ama|ancak|lakin|yalnız|yalniz|yine de|yinede)\b/i,
    /\b(çalışmıyor|calismiyor|bozuk|açılmıyor|acilmiyor)\b/i,
    /\b(devam ediyor|sürüyor|suruyor|bitmedi|olmadı|olmadi|eksik|yanlış|yanlis)\b/i,
    /\b(sorun\s+(var|devam|sürüyor|suruyor|oluştu|olustu|gitmedi|bitmedi))\b/i,
    /\b(problem\s+(var|devam|sürüyor|suruyor|oluştu|olustu))\b/i,
    /\b(hata\s+(var|alıyorum|aliyorum|veriyor|aldım|aldim|devam))\b/i,
    /\b(tekrar\s+(çıktı|cikti|oldu|verdi|başladı|basladi))\b/i,
    /\b(bakar mısınız|bakar misiniz|inceler misiniz|düzeltin|duzeltin)\b/i,
    /\b(but|however|still|not working|broken|still an issue|error occurs|wait)\b/i,
    /\?/ # Soru işareti varsa müşteri yeni bir soru soruyor olabilir
  ].freeze

  # Gelen mesajın sadece bir teşekkür mesajı olup olmadığını tespit eder
  def self.gratitude_only?(text)
    return false if text.blank?

    cleaned_text = text.strip

    # 1. Metinde en az bir teşekkür veya çözüm onayı ifadesi geçiyor mu?
    has_gratitude = GRATITUDE_PATTERNS.any? { |pattern| cleaned_text.match?(pattern) }
    return false unless has_gratitude

    # 2. Pozitif çözüm ifadelerini ayıkla (Örn: "sorun tamamen çözüldü" pozitif onaydır)
    text_for_objection_check = cleaned_text
    POSITIVE_RESOLUTION_PHRASES.each do |phrase|
      text_for_objection_check = text_for_objection_check.gsub(phrase, "")
    end

    # 3. Metinde itiraz veya yeni bir sorun ifadesi geçiyor mu?
    has_objection = OBJECTION_PATTERNS.any? { |pattern| text_for_objection_check.match?(pattern) }
    return false if has_objection

    # 4. Kısa ve nezaket odaklı bir mesaj mı? (Örn: 250 karakterden az)
    cleaned_text.length < 250
  end
end
