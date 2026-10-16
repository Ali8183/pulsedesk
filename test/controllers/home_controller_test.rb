# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "ana giriş sayfası (landing page) başarıyla yüklenir" do
    get root_url
    assert_response :success
    assert_select "h1", text: /Müşteri Desteğinde Hız/
    assert_select "a[href=?]", portal_path
    assert_select "a[href=?]", tickets_path
  end
end
