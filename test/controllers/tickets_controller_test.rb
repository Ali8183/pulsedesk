# frozen_string_literal: true

require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket = Ticket.create!(
      title: "Test Bilet Başlığı",
      description: "Test açıklaması",
      customer_name: "Ali Veli",
      customer_email: "ali@example.com",
      priority: :medium
    )
  end

  test "index sayfası başarıyla yüklenir" do
    get tickets_url
    assert_response :success
    assert_select "h1", text: /Müşteri Destek Masası/
  end

  test "show sayfası bilet detaylarını ve SLA panelini gösterir" do
    get ticket_url(@ticket)
    assert_response :success
    assert_select "h1", text: /#{@ticket.title}/
    assert_select ".sla-panel"
  end

  test "new sayfası bilet oluşturma formunu gösterir" do
    get new_ticket_url
    assert_response :success
    assert_select "form"
  end

  test "yeni bilet oluşturulabilir ve show sayfasına yönlendirilir" do
    assert_difference("Ticket.count", 1) do
      post tickets_url, params: {
        ticket: {
          title: "Yeni Talep",
          description: "Yeni talep açıklaması",
          customer_name: "Ayşe Yılmaz",
          customer_email: "ayse@example.com",
          priority: "urgent"
        }
      }
    end

    new_ticket = Ticket.last
    assert_redirected_to ticket_url(new_ticket)
    assert_equal 2, new_ticket.sla_hours
  end

  test "durum geçişi (transition) aksiyonu başarıyla çalışır" do
    patch transition_ticket_url(@ticket), params: { target_status: "status_open" }
    assert_redirected_to ticket_url(@ticket)
    assert @ticket.reload.status_open?
  end

  test "temsilci atama (assign) aksiyonu bileti açık duruma geçirir" do
    patch assign_ticket_url(@ticket), params: { agent_name: "Selin Yılmaz" }
    assert_redirected_to ticket_url(@ticket)
    assert_equal "Selin Yılmaz", @ticket.reload.assigned_agent
    assert @ticket.status_open?
  end

  test "zaman makinesi (simulate_time_travel) SLA aşımını tetikler" do
    post simulate_time_travel_ticket_url(@ticket)
    assert_redirected_to ticket_url(@ticket)
    assert @ticket.reload.sla_breached?
  end
end
