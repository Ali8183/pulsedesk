# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    @ticket = Ticket.create!(
      title: "Hesap aktivasyon e-postası gelmedi",
      description: "Yeni üye oldum ancak onay postası kutuma düşmedi.",
      customer_name: "Burak Yılmaz",
      customer_email: "burak@example.com",
      priority: :high
    )
  end

  # ============================================================
  # 100 PUANLIK ÖZELLİK TESTİ: GRATITUDE GUARD (NEZAKET KORUMASI)
  # ============================================================

  test "çözülmüş bilete müşteri teşekkür ettiğinde Gratitude Guard devreye girer ve bilet çözüldü kalır" do
    # 1. Temsilci bileti açar ve çözer
    @ticket.transition_to!(:status_open)
    @ticket.transition_to!(:status_solved)
    assert @ticket.status_solved?

    # 2. Müşteri sadece nezaket/teşekkür mesajı gönderir (Zendesk'te bu bilet açılırdı!)
    comment = @ticket.comments.create!(
      author_name: @ticket.customer_name,
      author_role: "customer",
      body: "Çok teşekkür ederim, sayenizde problemim hemen çözüldü! Harikasınız."
    )

    # 3. PulseDesk Doğrulaması:
    assert comment.is_gratitude?, "Yorum teşekkür olarak işaretlenmeli"
    assert @ticket.reload.status_solved?, "Bilet 'Çözüldü' kalmaya devam etmeli, gereksiz yere açılmamalı"
    assert_equal 1, @ticket.gratitude_count
  end

  test "çözülmüş bilete müşteri teşekkür edip yeni bir hata bildirirse bilet yeniden açılır (Reopen)" do
    @ticket.transition_to!(:status_open)
    @ticket.transition_to!(:status_solved)
    assert @ticket.status_solved?

    # Müşteri teşekkür etti ama 'ama hata devam ediyor' dedi
    comment = @ticket.comments.create!(
      author_name: @ticket.customer_name,
      author_role: "customer",
      body: "Teşekkürler ancak mobil uygulamada aynı hata hala devam ediyor, kontrol edebilir misiniz?"
    )

    assert_not comment.is_gratitude?, "İtiraz/sorun içeren mesaj teşekkür olarak sayılmamalı"
    assert @ticket.reload.status_open?, "Bilet temsilcinin ilgilenmesi için yeniden 'Açık' durumuna geçmeli"
  end

  test "temsilci yeni bilete ilk yanıtı verdiğinde bilet açık duruma geçer" do
    assert @ticket.status_new?

    @ticket.comments.create!(
      author_name: "Destek Uzmanı Elif",
      author_role: "agent",
      body: "Merhaba Burak Bey, talebiniz inceleniyor. Aktivasyon linki yeniden gönderildi."
    )

    assert @ticket.reload.status_open?
    assert @ticket.first_responded_at.present?
  end
end
