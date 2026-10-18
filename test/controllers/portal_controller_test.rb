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

  test "eski portal adresi doğrudan /musteri adresine yönlendirir" do
    get portal_url
    assert_redirected_to "/musteri"
  end

  test "eski portal bilet takip adresi /musteri/talep/:id adresine yönlendirir" do
    get portal_ticket_url(@ticket)
    assert_redirected_to "/musteri/talep/#{@ticket.id}"
  end

  test "eski musteri/sorgula adresi /musteri adresine yönlendirir" do
    get customer_lookup_url
    assert_redirected_to "/musteri"
  end
end
