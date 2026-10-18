# frozen_string_literal: true

require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket = Ticket.create!(
      title: "Giriş hatası",
      description: "Şifremi sıfırlayamıyorum",
      customer_name: "Fatma Demir",
      customer_email: "fatma@example.com",
      priority: :high
    )
  end

  test "giriş yapmamış kullanıcı bilet yorumu ekleyemez ve temsilci girişine yönlendirilir" do
    post ticket_comments_url(@ticket), params: {
      comment: { body: "Yetkisiz yorum denemesi" }
    }
    assert_redirected_to temsilci_url
  end

  test "temsilci yanıt eklediğinde yorum kaydedilir ve bilet yanıt bekleniyor (pending) durumuna geçer" do
    post temsilci_giris_url, params: { email: "ahmet@pulsedesk.com", password: "admin" }

    assert_difference("Comment.count", 1) do
      post ticket_comments_url(@ticket), params: {
        comment: {
          body: "Merhaba Fatma Hanım, şifre sıfırlama linki e-postanıza tekrar gönderildi."
        }
      }
    end

    assert_redirected_to ticket_url(@ticket)
    assert @ticket.reload.status_pending?, "Temsilci yanıt verdiğinde bilet 'Yanıt Bekleniyor' durumuna geçmelidir"

    comment = Comment.last
    assert_equal "Ahmet Kaya", comment.author_name
    assert_equal "agent", comment.author_role
  end

  test "kapatılmış ve arşivlenmiş bir bilete yeni yorum eklenemez" do
    @ticket.transition_to!(:status_open)
    @ticket.transition_to!(:status_solved)
    @ticket.transition_to!(:status_closed)
    assert @ticket.status_closed?

    post temsilci_giris_url, params: { email: "ahmet@pulsedesk.com", password: "admin" }

    assert_no_difference("Comment.count") do
      post ticket_comments_url(@ticket), params: {
        comment: { body: "Arşivlenmiş bilete mesaj yazılamaz" }
      }
    end

    assert_redirected_to ticket_url(@ticket)
    follow_redirect!
    assert_select ".flash-alert-danger", text: /Kapatılmış ve arşivlenmiş/
  end
end
