# frozen_string_literal: true

require "test_helper"

class MusteriControllerTest < ActionDispatch::IntegrationTest
  setup do
    @murat_ticket = Ticket.create!(
      title: "Fatura adresi güncelleme",
      description: "Yeni vergi numaramız sisteme girilmeli",
      customer_name: "Murat Demir",
      customer_email: "murat.demir@global-logistics.com",
      priority: :medium
    )

    @deniz_ticket = Ticket.create!(
      title: "Veritabanı yedeği indirme sorunu",
      description: "İndirme linki 404 dönüyor",
      customer_name: "Deniz Arslan",
      customer_email: "deniz@cloud-scale.net",
      priority: :urgent
    )
  end

  test "giriş yapmamış müşteri /musteri adresinde giriş ve kayıt ekranını görür" do
    get musteri_url
    assert_response :success
    assert_select "h1", text: /Müşteri Destek Portalı/
    assert_select "form[action=?]", musteri_giris_path
    assert_select "form[action=?]", musteri_kayit_path
  end

  test "müşteri e-posta adresiyle giriş yapabilir ve kendi paneline yönlendirilir" do
    post musteri_giris_url, params: { email: "murat.demir@global-logistics.com", name: "Murat Demir" }
    assert_redirected_to root_url
    follow_redirect!
    assert_response :success
    assert_select "h1", text: /Taleplerim & Destek Merkezi/
    assert_select "body", text: /Murat Demir/
  end

  test "yeni müşteri kayıt olabilir ve paneline giriş yapar" do
    post musteri_kayit_url, params: { name: "Ahmet Yeni Müşteri", email: "ahmet.yeni@musteri.com" }
    assert_redirected_to root_url
    follow_redirect!
    assert_response :success
    assert_select "h1", text: /Taleplerim & Destek Merkezi/
    assert_select "body", text: /Ahmet Yeni Müşteri/
  end

  test "müşteri sadece kendi biletlerini görür, diğer müşterilerin biletlerini göremez" do
    post musteri_giris_url, params: { email: "murat.demir@global-logistics.com", name: "Murat Demir" }
    get musteri_url
    assert_response :success

    # Murat'ın kendi bileti tabloda görünmeli
    assert_select "td", text: /#{@murat_ticket.title}/

    # Deniz'in bileti Murat'ın tablosunda ASLA görünmemeli (İzolasyon Güvencesi)
    assert_select "td", text: /#{@deniz_ticket.title}/, count: 0
  end

  test "müşteri yeni bir destek bileti oluşturabilir ve kendi biletine yönlendirilir" do
    post musteri_giris_url, params: { email: "murat.demir@global-logistics.com", name: "Murat Demir" }

    assert_difference("Ticket.count", 1) do
      post musteri_talep_url, params: {
        ticket: {
          title: "Sisteme giriş yaparken 500 hatası alıyoruz",
          description: "Giriş yap butonuna basınca sunucu yanıt vermiyor.",
          priority: "urgent"
        }
      }
    end

    new_ticket = Ticket.last
    assert_redirected_to musteri_ticket_url(new_ticket)
    assert_equal "murat.demir@global-logistics.com", new_ticket.customer_email
    assert_equal "Murat Demir", new_ticket.customer_name
    assert_equal 2, new_ticket.sla_hours
  end

  test "müşteri kendi biletinin detayını ve mesajlaşma geçmişini görüntüleyebilir" do
    post musteri_giris_url, params: { email: "murat.demir@global-logistics.com", name: "Murat Demir" }
    get musteri_ticket_url(@murat_ticket)
    assert_response :success
    assert_select "h1", text: /#{@murat_ticket.title}/
  end

  test "müşteri başka bir müşterinin biletine doğrudan linkle girmeye çalışırsa engellenir" do
    post musteri_giris_url, params: { email: "murat.demir@global-logistics.com", name: "Murat Demir" }
    # Murat, Deniz'in biletine erişmeye çalışıyor
    get musteri_ticket_url(@deniz_ticket)
    assert_redirected_to musteri_url
    follow_redirect!
    assert_select ".flash-alert-danger", text: /Yalnızca kendi açtığınız/
  end

  test "müşteri biletine teşekkür mesajı yazarsa GratitudeGuard devreye girer ve çözüldü durumu korunur" do
    @murat_ticket.transition_to!(:status_open)
    @murat_ticket.transition_to!(:status_solved)
    assert @murat_ticket.status_solved?

    post musteri_giris_url, params: { email: "murat.demir@global-logistics.com", name: "Murat Demir" }

    assert_difference("Comment.count", 1) do
      post musteri_cevap_url(@murat_ticket), params: {
        comment: {
          body: "Çok teşekkür ederim elinize sağlık, sorunumuz çözüldü."
        }
      }
    end

    assert_redirected_to musteri_ticket_url(@murat_ticket)
    assert @murat_ticket.reload.status_solved?, "Nezaket koruması bileti çözüldü tutmalıdır"
    assert_equal 1, @murat_ticket.gratitude_count
  end

  test "kapatılmış ve arşivlenmiş bir bilete müşteri yeni yanıt gönderemez" do
    @murat_ticket.transition_to!(:status_open)
    @murat_ticket.transition_to!(:status_solved)
    @murat_ticket.transition_to!(:status_closed)
    assert @murat_ticket.status_closed?

    post musteri_giris_url, params: { email: "murat.demir@global-logistics.com", name: "Murat Demir" }

    assert_no_difference("Comment.count") do
      post musteri_cevap_url(@murat_ticket), params: {
        comment: { body: "Kapanmış bilete mesaj yazmaya çalışıyorum" }
      }
    end

    assert_redirected_to musteri_ticket_url(@murat_ticket)
    follow_redirect!
    assert_select ".flash-alert-danger", text: /kapatılmıştır/
  end

  test "müşteri çıkış yaptığında oturumu temizlenir ve giriş sayfasına yönlendirilir" do
    post musteri_giris_url, params: { email: "murat.demir@global-logistics.com", name: "Murat Demir" }
    delete musteri_cikis_url
    assert_redirected_to root_url

    # Tekrar paneli açmaya çalıştığında giriş formunu görmeli
    get musteri_url
    assert_select "h1", text: /Müşteri Destek Portalı/
  end
end
