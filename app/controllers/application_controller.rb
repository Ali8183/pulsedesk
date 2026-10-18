class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_agent, :agent_signed_in?, :current_agent_title,
                :current_customer_email, :current_customer_name, :customer_signed_in?

  # Temsilci Yetkilendirme
  def current_agent
    session[:agent_name]
  end

  def current_agent_title
    session[:agent_title] || "Destek Temsilcisi"
  end

  def agent_signed_in?
    current_agent.present?
  end

  def require_agent!
    unless agent_signed_in?
      redirect_to temsilci_path, alert: "Temsilci masasına erişebilmek için yetkili girişi yapmalısınız."
    end
  end

  # Müşteri Yetkilendirme
  def current_customer_email
    session[:customer_email]
  end

  def current_customer_name
    session[:customer_name] || (current_customer_email.present? ? current_customer_email.split("@").first.titleize : nil)
  end

  def customer_signed_in?
    current_customer_email.present?
  end

  def require_customer!
    unless customer_signed_in?
      redirect_to musteri_path, alert: "Taleplerinizi görüntülemek için lütfen müşteri girişi yapın."
    end
  end
end
