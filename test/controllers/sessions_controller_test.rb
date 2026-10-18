# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "temsilci giriş formu başarıyla açılır" do
    get agent_login_url
    assert_response :success
    assert_select "h1", text: /Yetkili Temsilci Girişi/
  end

  test "geçerli bilgilerle temsilci girişi yapılır" do
    post agent_login_url, params: { email: "ahmet@pulsedesk.com", password: "admin" }
    assert_redirected_to tickets_url
    follow_redirect!
    assert_response :success
    assert_select "header", text: /Ahmet Kaya/
  end

  test "geçersiz bilgilerle giriş reddedilir" do
    post agent_login_url, params: { email: "yanlis@pulsedesk.com", password: "wrong" }
    assert_response :unprocessable_entity
    assert_select ".flash-alert-danger", text: /Geçersiz temsilci/
  end

  test "çıkış yapıldığında oturum kapatılır ve ana sayfaya yönlendirilir" do
    post agent_login_url, params: { email: "ahmet@pulsedesk.com", password: "admin" }
    delete agent_logout_url
    assert_redirected_to root_url
  end

  test "/temsilci adresi yetkili temsilci giriş sayfasını açar" do
    get agent_portal_url
    assert_response :success
    assert_select "h1", text: /Yetkili Temsilci Girişi/
  end
end
