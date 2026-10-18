# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "ziyaretçi ana sayfaya (/) girdiğinde doğrudan müşteri destek portalı açılır" do
    get root_url
    assert_response :success
    assert_select "h1", text: /Müşteri Destek Portalı/
    assert_select "button#tab-btn-login", text: /Giriş Yap/
    assert_select "button#tab-btn-register", text: /Kayıt Ol/
  end

  test "ziyaretçi /temsilci adresine girdiğinde doğrudan temsilci giriş sayfası açılır" do
    get temsilci_url
    assert_response :success
    assert_select "h1", text: /Yetkili Temsilci Girişi/
    assert_select "form[action=?]", temsilci_giris_path
  end
end
