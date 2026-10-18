# frozen_string_literal: true

require "test_helper"

class PortalRoutesTest < ActionDispatch::IntegrationTest
  test "ziyaretçi ana sayfaya (/) girdiğinde doğrudan müşteri destek portalı açılır" do
    get root_url
    assert_response :success
    assert_select "h1", text: /Müşteri Destek Portalı/
    assert_select "button#tab-btn-login", text: /Giriş Yap/
    assert_select "button#tab-btn-register", text: /Kayıt Ol/
  end

  test "müşteri giriş sayfasında temsilci menüsü, temsilci adı veya temsilci linkleri ASLA görünmez" do
    # Temsilci olarak giriş yapılmış olsa bile ana sayfaya gidildiğinde temsilci menüsü sızmamalı
    post temsilci_giris_url, params: { email: "selin@pulsedesk.com", password: "admin" }

    get root_url
    assert_response :success
    assert_select "header .brand-tag", text: "Müşteri Portalı"
    assert_select "header", text: /Tüm Talepler/, count: 0
    assert_select "header", text: /Açık Kuyruk/, count: 0
    assert_select "header", text: /SLA Alarmları/, count: 0
    assert_select "header", text: /Selin Yılmaz/, count: 0
    assert_select "header", text: /Temsilci Masası/, count: 0
  end

  test "müşteri portalı ziyaret edildikten sonra /temsilci adresine gidildiğinde doğrudan temsilci giriş ekranı açılır" do
    get root_url
    get temsilci_url
    assert_response :success
    assert_select "h1", text: /Yetkili Temsilci Girişi/
    assert_select "form[action=?]", temsilci_giris_path
  end
end
