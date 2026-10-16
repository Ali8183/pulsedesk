class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_agent, :agent_signed_in?, :current_agent_title

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
      redirect_to agent_login_path, alert: "Temsilci masasına erişebilmek için yetkili girişi yapmalısınız."
    end
  end
end
