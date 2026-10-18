# frozen_string_literal: true

require "test_helper"

class PortalControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket = Ticket.create!(
      title: "Müşteri Portalı Test Bilet",
      description: "Portal üzerinden açıldı",
      customer_name: "Canan Yılmaz",
      customer_email: "canan@example.com",
      priority: :urgent
    )
  end

  test "portal talep formu başarıyla açılır" do
    get portal_url
    assert_response :success
    assert_select "h1", text: /Müşteri Destek Portalı/
  end

  test "müşteri portal üzerinden yeni bilet oluşturabilir" do
    assert_difference("Ticket.count", 1) do
      post portal_url, params: {
        ticket: {
          title: "Sistemde sipariş gözükmüyor",
          description: "Kartımdan para çekildi fakat sipariş onaylanmadı",
          customer_name: "Kemal Demir",
          customer_email: "kemal@example.com",
          priority: "urgent"
        }
      }
    end

    new_ticket = Ticket.last
    assert_redirected_to portal_ticket_url(new_ticket)
    assert_equal 2, new_ticket.sla_hours
  end

  test "müşteri bilet takip sayfasını görüntüleyebilir" do
    get portal_ticket_url(@ticket)
    assert_response :success
    assert_select "h1", text: /#{@ticket.title}/
  end

  test "müşteri biletine yanıt yazabilir ve gratitude guard devreye girer" do
    @ticket.transition_to!(:status_open)
    @ticket.transition_to!(:status_solved)
    assert @ticket.status_solved?

    assert_difference("Comment.count", 1) do
      post portal_reply_url(@ticket), params: {
        comment: {
          body: "Çok teşekkür ederim, elinize sağlık her şey harika oldu!"
        }
      }
    end

    assert_redirected_to portal_ticket_url(@ticket)
    assert @ticket.reload.status_solved?, "Gratitude Guard bilet durumunu çözüldü tutmalı"
    assert_equal 1, @ticket.gratitude_count
  end

  test "müşteri /musteri adresi üzerinden bilet sorgulayabilir" do
    get customer_lookup_url, params: { ticket_id: @ticket.id.to_s }
    assert_redirected_to portal_ticket_url(@ticket)
  end
end
