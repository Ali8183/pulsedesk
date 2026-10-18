# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "temsilci giriş formu /temsilci adresinde başarıyla açılır" do
    get temsilci_url
    assert_response :success
    assert_select "h1", text: /Yetkili Temsilci Girişi/
  end

  test "geçerli bilgilerle temsilci girişi yapılır ve /temsilci masasına yönlendirilir" do
    post temsilci_giris_url, params: { email: "ahmet@pulsedesk.com", password: "admin" }
    assert_redirected_to temsilci_url
    follow_redirect!
    assert_response :success
    assert_select "header", text: /Ahmet Kaya/
    assert_select "h1", text: /Müşteri Destek Masası/
  end

  test "geçersiz bilgilerle giriş reddedilir" do
    post temsilci_giris_url, params: { email: "yanlis@pulsedesk.com", password: "wrong" }
    assert_response :unprocessable_entity
    assert_select ".flash-alert-danger", text: /Geçersiz temsilci/
  end

  test "çıkış yapıldığında oturum kapatılır ve /temsilci giriş ekranına yönlendirilir" do
    post temsilci_giris_url, params: { email: "ahmet@pulsedesk.com", password: "admin" }
    delete temsilci_cikis_url
    assert_redirected_to temsilci_url
  end

  test "eski agent/login adresi /temsilci adresine yönlendirir" do
    get agent_login_url
    assert_redirected_to "/temsilci"
  end
end
