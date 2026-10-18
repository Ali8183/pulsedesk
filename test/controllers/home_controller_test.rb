# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "ana giriş sayfası ziyaretçilere müşteri ve yetkili giriş bağlantılarını gösterir" do
    get root_url
    assert_response :success
    assert_select "h1", text: /Müşteri Desteğinde Hız/
    assert_select "a[href=?]", musteri_path
    assert_select "a[href=?]", temsilci_path
  end

  test "temsilci oturum açtığında ana sayfada temsilci masası erişimi görünür" do
    post temsilci_giris_url, params: { email: "ahmet@pulsedesk.com", password: "admin" }
    get root_url
    assert_response :success
    assert_select "a[href=?]", temsilci_path
  end
end
