# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "ziyaretçi ana sayfaya girdiğinde doğrudan müşteri destek portalına yönlendirilir" do
    get root_url
    assert_redirected_to musteri_path
  end

  test "temsilci oturum açtığında ana sayfaya girdiğinde doğrudan temsilci masasına yönlendirilir" do
    post temsilci_giris_url, params: { email: "ahmet@pulsedesk.com", password: "admin" }
    get root_url
    assert_redirected_to temsilci_path
  end
end
