# frozen_string_literal: true

require "test_helper"

class TicketTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      title: "Ödeme sayfasında 500 hatası alıyorum",
      description: "Müşteri kart bilgilerini girdikten sonra sunucu hatası oluşuyor.",
      customer_name: "Canan Dağ",
      customer_email: "canan@example.com",
      priority: :urgent
    }
  end

  # ==========================================
  # 1. ZAMAN KURALI TESTLERİ (travel_to İLE)
  # ==========================================

  test "yeni bilet oluşturulduğunda önceliğe göre SLA süresi belirlenir" do
    ticket = Ticket.create!(@valid_attributes)

    assert_equal 2, ticket.sla_hours # Urgent için 2 saat
    assert ticket.sla_due_at.present?
    assert_not ticket.sla_breached?
  end

  test "SLA süresi dolmadan önce ticket.sla_breached? false döner" do
    ticket = Ticket.create!(@valid_attributes)

    # 1 saat sonraya gidelim (SLA: 2 saat)
    travel_to 1.hour.from_now do
      assert_not ticket.sla_breached?
      assert_not ticket.check_sla_breach!
      assert_equal :normal, ticket.sla_urgency_level
    end
  end

  test "travel_to ile SLA süresi aşıldığında sla_breached? true döner ve alarm verir" do
    ticket = Ticket.create!(@valid_attributes)

    # SLA 2 saatti; 3 saat sonraya gidelim
    travel_to 3.hours.from_now do
      assert ticket.sla_breached?
      assert ticket.check_sla_breach!
      assert ticket.reload.sla_breached
      assert_equal :breached, ticket.sla_urgency_level
    end
  end

  test "çözülmüş biletlerde zaman geçse bile SLA durur ve breach gerçekleşmez" do
    ticket = Ticket.create!(@valid_attributes)
    ticket.transition_to!(:status_open)
    ticket.transition_to!(:status_solved)

    # 5 saat sonraya gitsek bile çözülmüş bilet breached olmamalı
    travel_to 5.hours.from_now do
      assert_not ticket.sla_breached?
      assert_equal :resolved, ticket.sla_urgency_level
    end
  end

  # ==========================================
  # 2. DURUM GEÇİŞİ TESTLERİ (STATE TRANSITIONS)
  # ==========================================

  test "aort dilimi durum akışı başarılı bir şekilde ilerler: new -> open -> pending -> solved -> closed" do
    ticket = Ticket.create!(@valid_attributes)
    assert ticket.status_new?

    assert ticket.transition_to!(:status_open)
    assert ticket.status_open?

    assert ticket.transition_to!(:status_pending)
    assert ticket.status_pending?

    assert ticket.transition_to!(:status_solved)
    assert ticket.status_solved?
    assert ticket.resolved_at.present?

    assert ticket.transition_to!(:status_closed)
    assert ticket.status_closed?
  end

  test "geçersiz durum geçişi engellenir ve validation hatası eklenir" do
    ticket = Ticket.create!(@valid_attributes)

    # 'new' durumundaki bir bilet doğrudan 'closed' yapılamaz
    assert_not ticket.can_transition_to?(:status_closed)
    assert_not ticket.transition_to!(:status_closed)
    assert ticket.errors[:status].present?
    assert ticket.reload.status_new?
  end

  test "kapatılmış (closed) bilet başka bir duruma geçirilemez" do
    ticket = Ticket.create!(@valid_attributes)
    ticket.transition_to!(:status_open)
    ticket.transition_to!(:status_solved)
    ticket.transition_to!(:status_closed)

    assert_not ticket.can_transition_to?(:status_open)
    assert_not ticket.transition_to!(:status_open)
    assert ticket.reload.status_closed?
  end
end
