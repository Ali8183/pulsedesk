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

  test "temsilci yanıt eklediğinde bilet açık duruma geçer" do
    assert_difference("Comment.count", 1) do
      post ticket_comments_url(@ticket), params: {
        comment: {
          author_name: "Destek Uzmanı Ahmet",
          author_role: "agent",
          body: "Merhaba Fatma Hanım, şifre sıfırlama linki e-postanıza tekrar gönderildi."
        }
      }
    end

    assert_redirected_to ticket_url(@ticket)
    assert @ticket.reload.status_open?
  end

  test "çözülmüş bilete teşekkür yanıtı eklendiğinde Gratitude Guard bilet durumunu çözüldü tutar" do
    @ticket.transition_to!(:status_open)
    @ticket.transition_to!(:status_solved)
    assert @ticket.status_solved?

    assert_difference("Comment.count", 1) do
      post ticket_comments_url(@ticket), params: {
        comment: {
          author_name: "Fatma Demir",
          author_role: "customer",
          body: "Çok teşekkürler, şifremi başarıyla yeniledim!"
        }
      }
    end

    assert_redirected_to ticket_url(@ticket)
    assert @ticket.reload.status_solved?, "Bilet 'Çözüldü' kalmalıdır"
    assert_equal 1, @ticket.gratitude_count
  end
end
